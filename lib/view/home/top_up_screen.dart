// ignore_for_file: deprecated_member_use

import 'package:finpay/config/images.dart';
import 'package:finpay/config/textstyle.dart';
import 'package:finpay/view/home/topup_dialog.dart';
import 'package:finpay/view/home/widget/amount_container.dart';
import 'package:finpay/Alumnos/model/sistema_reservas.dart';
import 'package:finpay/api/local.db.service.dart';
import 'package:finpay/utils/utiles.dart';
import 'package:finpay/Alumnos/controller/reserva_controller.dart';
import 'package:finpay/controller/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:swipe/swipe.dart';

class TopUpSCreen extends StatefulWidget {
  const TopUpSCreen({Key? key}) : super(key: key);

  @override
  State<TopUpSCreen> createState() => _TopUpSCreenState();
}

class _TopUpSCreenState extends State<TopUpSCreen> {
  final db = LocalDBService();
  RxList<Reserva> reservasPendientes = <Reserva>[].obs;
  Rx<Reserva?> reservaSeleccionada = Rx<Reserva?>(null);

  @override
  void initState() {
    super.initState();
    cargarReservasPendientes();
  }

  Future<void> cargarReservasPendientes() async {
    final reservas = await db.getAll("reservas.json");
    reservasPendientes.value = reservas
        .map((e) => Reserva.fromJson(e))
        .where((r) => r.estadoReserva == "PENDIENTE")
        .toList();
  }

  Future<void> procesarPago() async {
    if (reservaSeleccionada.value == null) {
      Get.snackbar(
        "Error",
        "Por favor selecciona una reserva para pagar",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
      return;
    }

    // Crear el pago
    final nuevoPago = Pago(
      codigoPago: "PAGO-${DateTime.now().millisecondsSinceEpoch}",
      codigoReservaAsociada: reservaSeleccionada.value!.codigoReserva,
      montoPagado: reservaSeleccionada.value!.monto,
      fechaPago: DateTime.now(),
    );

    try {
      // Guardar el pago
      final pagos = await db.getAll("pagos.json");
      pagos.add(nuevoPago.toJson());
      await db.saveAll("pagos.json", pagos);

      // Actualizar estado de la reserva
      final reservas = await db.getAll("reservas.json");
      final index = reservas.indexWhere(
        (r) => r['codigoReserva'] == reservaSeleccionada.value!.codigoReserva,
      );
      if (index != -1) {
        reservas[index]['estadoReserva'] = "PAGADO";
        await db.saveAll("reservas.json", reservas);

        // Obtener el código del lugar de la reserva
        final codigoLugar = reservas[index]['codigoLugar'];
        
        // Liberar el lugar de estacionamiento
        final lugares = await db.getAll("lugares.json");
        final lugarIndex = lugares.indexWhere(
          (l) => l['codigoLugar'] == codigoLugar,
        );
        if (lugarIndex != -1) {
          lugares[lugarIndex]['estado'] = "DISPONIBLE";
          await db.saveAll("lugares.json", lugares);
        }

        // Actualizar la lista de reservas pendientes
        await cargarReservasPendientes();

        // Actualizar el resumen en HomeController
        final homeController = Get.find<HomeController>();
        await homeController.actualizarPagos();
        await homeController.actualizarAutos();

        // Mostrar confirmación
        Get.dialog(
          AlertDialog(
            title: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 28),
                SizedBox(width: 8),
                Text("Pago Exitoso"),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Reserva: ${reservaSeleccionada.value!.codigoReserva}"),
                Text("Monto: ₲${UtilesApp.formatearGuaranies(reservaSeleccionada.value!.monto)}"),
                Text("Fecha: ${UtilesApp.formatearFechaDdMMAaaa(DateTime.now())}"),
                Text("Lugar liberado exitosamente", style: TextStyle(color: Colors.green)),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Get.back();
                  Get.back();
                  // Recargar la pantalla de reservas para actualizar el estado de los lugares
                  Get.find<ReservaController>().cargarPisosYLugares();
                },
                child: Text(
                  "Aceptar",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Error al procesar el pago",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    }
  }

  Future<void> cancelarReserva() async {
    if (reservaSeleccionada.value == null) {
      Get.snackbar(
        "Error",
        "Por favor selecciona una reserva para cancelar",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
      return;
    }

    // Mostrar diálogo de confirmación
    final confirmar = await Get.dialog<bool>(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.orange, size: 28),
            SizedBox(width: 8),
            Text("Confirmar Cancelación"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("¿Estás seguro que deseas cancelar la reserva?"),
            SizedBox(height: 8),
            Text("Reserva: ${reservaSeleccionada.value!.codigoReserva}"),
            Text("Esta acción no se puede deshacer."),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(
              "No, mantener",
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text(
              "Sí, cancelar",
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      try {
        final cancelada = await Get.find<ReservaController>().cancelarReserva(
          reservaSeleccionada.value!.codigoReserva,
        );

        if (cancelada) {
          // Actualizar la lista de reservas pendientes
          await cargarReservasPendientes();
          reservaSeleccionada.value = null;

          // Mostrar confirmación
          Get.dialog(
            AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 28),
                  SizedBox(width: 8),
                  Text("Reserva Cancelada"),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("La reserva ha sido cancelada exitosamente."),
                  Text("El lugar ha sido liberado."),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Get.back();
                    Get.back();
                  },
                  child: Text(
                    "Aceptar",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      } catch (e) {
        Get.snackbar(
          "Error",
          "Error al cancelar la reserva",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade900,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.isLightTheme == false
          ? HexColor('#15141f')
          : HexColor(AppTheme.primaryColorString!),
      body: Stack(
        children: [
          // Fondo con gradiente
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Theme.of(context).colorScheme.primary.withOpacity(0.8),
                  Theme.of(context).colorScheme.primary.withOpacity(0.4),
                ],
              ),
            ),
          ),
          // Contenido principal
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Botón de regreso
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(height: 20),
                    // Título y subtítulo
                    Text(
                      "Pagar Reserva",
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Selecciona una reserva para pagar",
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 40),
                    // Lista de reservas pendientes
                    Obx(() {
                      if (reservasPendientes.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: Text(
                              "No hay reservas pendientes de pago",
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                          ),
                        );
                      }

                      return Column(
                        children: reservasPendientes.map((reserva) {
                          final isSelected = reserva == reservaSeleccionada.value;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 15),
                            child: InkWell(
                              onTap: () {
                                reservaSeleccionada.value = reserva;
                              },
                              child: Container(
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.grey.shade200
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    color: isSelected
                                        ? Colors.grey.shade400
                                        : Colors.grey.shade300,
                                    width: isSelected ? 2 : 1,
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: Colors.grey.shade400.withOpacity(0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Reserva #${reserva.codigoReserva}",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        Text(
                                          "₲${UtilesApp.formatearGuaranies(reserva.monto)}",
                                          style: TextStyle(
                                            color: Theme.of(context).colorScheme.primary,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "Fecha: ${UtilesApp.formatearFechaDdMMAaaa(reserva.horarioInicio)}",
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    Text(
                                      "Auto: ${reserva.chapaAuto}",
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    }),
                    const SizedBox(height: 30),
                    // Botones de acción
                    Obx(() {
                      if (reservasPendientes.isEmpty) return const SizedBox();
                      
                      return Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: procesarPago,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                reservaSeleccionada.value == null
                                    ? "Selecciona una reserva"
                                    : "Pagar Reserva",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: cancelarReserva,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                reservaSeleccionada.value == null
                                    ? "Selecciona una reserva"
                                    : "Cancelar Reserva",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                    const SizedBox(height: 20),
                    // Información de seguridad
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.security,
                            color: Colors.white,
                            size: 24,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "Tu información está segura y encriptada",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
