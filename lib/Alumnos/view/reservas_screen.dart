import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:finpay/Alumnos/controller/reserva_controller.dart';
import 'package:finpay/Alumnos/model/sistema_reservas.dart';
import 'package:finpay/utils/utiles.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class ReservaScreen extends StatelessWidget {
  final controller = Get.put(ReservaController());

  ReservaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reserva de Estacionamiento"),
        elevation: 0,
      ),
      body: Builder(
        builder: (context) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Obx(() {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Seleccionar auto",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white,
                      ),
                      child: Obx(() {
                        return DropdownButton<Auto>(
                          isExpanded: true,
                          value: controller.autoSeleccionado.value,
                          hint: Row(
                            children: [
                              Icon(Icons.directions_car, color: Theme.of(context).colorScheme.primary),
                              const SizedBox(width: 8),
                              const Text("Seleccionar auto"),
                            ],
                          ),
                          underline: const SizedBox(),
                          onChanged: (auto) {
                            controller.autoSeleccionado.value = auto;
                          },
                          items: controller.autosCliente.map((a) {
                            final nombre = "${a.chapa} - ${a.marca} ${a.modelo}";
                            return DropdownMenuItem(
                              value: a,
                              child: Row(
                                children: [
                                  Icon(Icons.directions_car, color: Theme.of(context).colorScheme.primary),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      nombre,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        );
                      }),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "Seleccionar piso",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 60,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: controller.pisos.length,
                        itemBuilder: (context, index) {
                          final piso = controller.pisos[index];
                          final isSelected = piso == controller.pisoSeleccionado.value;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ElevatedButton(
                              onPressed: () => controller.seleccionarPiso(piso),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isSelected
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.grey.shade200,
                                foregroundColor: isSelected
                                    ? Colors.white
                                    : Colors.black87,
                                elevation: isSelected ? 4 : 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                piso.descripcion,
                                style: TextStyle(
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "Seleccionar lugar",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (controller.pisoSeleccionado.value != null) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Piso ${controller.pisoSeleccionado.value!.descripcion}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 200,
                              child: GridView.count(
                                crossAxisCount: 5,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                                children: controller.lugaresDisponibles
                                    .where((l) =>
                                        l.codigoPiso ==
                                        controller.pisoSeleccionado.value?.codigo)
                                    .map((lugar) {
                                  final seleccionado =
                                      lugar == controller.lugarSeleccionado.value;
                                  final color = lugar.estado == "RESERVADO"
                                      ? Colors.red
                                      : seleccionado
                                          ? Colors.green
                                          : Colors.grey.shade300;

                                  return GestureDetector(
                                    onTap: lugar.estado == "DISPONIBLE"
                                        ? () =>
                                            controller.lugarSeleccionado.value = lugar
                                        : null,
                                    child: Container(
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: color,
                                        border: Border.all(
                                            color: seleccionado
                                                ? Colors.green.shade700
                                                : Colors.black12),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        lugar.codigoLugar,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: lugar.estado == "RESERVADO"
                                              ? Colors.white
                                              : Colors.black87,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    const Text(
                      "Seleccionar horarios",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate:
                                    DateTime.now().add(const Duration(days: 30)),
                              );
                              if (date == null) return;
                              final time = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                              );
                              if (time == null) return;
                              controller.horarioInicio.value = DateTime(
                                date.year,
                                date.month,
                                date.day,
                                time.hour,
                                time.minute,
                              );
                            },
                            icon: const Icon(Icons.access_time),
                            label: Obx(() => Text(
                                  controller.horarioInicio.value == null
                                      ? "Inicio"
                                      : "${UtilesApp.formatearFechaDdMMAaaa(controller.horarioInicio.value!)} ${TimeOfDay.fromDateTime(controller.horarioInicio.value!).format(context)}",
                                )),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: controller.horarioInicio.value ??
                                    DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate:
                                    DateTime.now().add(const Duration(days: 30)),
                              );
                              if (date == null) return;
                              final time = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                              );
                              if (time == null) return;
                              controller.horarioSalida.value = DateTime(
                                date.year,
                                date.month,
                                date.day,
                                time.hour,
                                time.minute,
                              );
                            },
                            icon: const Icon(Icons.timer_off),
                            label: Obx(() => Text(
                                  controller.horarioSalida.value == null
                                      ? "Salida"
                                      : "${UtilesApp.formatearFechaDdMMAaaa(controller.horarioSalida.value!)} ${TimeOfDay.fromDateTime(controller.horarioSalida.value!).format(context)}",
                                )),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "Duración rápida",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: [1, 2, 4, 6, 8].map((horas) {
                        final seleccionada =
                            controller.duracionSeleccionada.value == horas;
                        return ChoiceChip(
                          label: Text("$horas h"),
                          selected: seleccionada,
                          selectedColor: Theme.of(context).colorScheme.primary,
                          onSelected: (_) {
                            controller.duracionSeleccionada.value = horas;
                            final inicio =
                                controller.horarioInicio.value ?? DateTime.now();
                            controller.horarioInicio.value = inicio;
                            controller.horarioSalida.value =
                                inicio.add(Duration(hours: horas));
                          },
                        );
                      }).toList(),
                    ),
                    Obx(() {
                      final inicio = controller.horarioInicio.value;
                      final salida = controller.horarioSalida.value;

                      if (inicio == null || salida == null) return const SizedBox();

                      final minutos = salida.difference(inicio).inMinutes;
                      final horas = minutos / 60;
                      final monto = (horas * 10000).round();

                      return Container(
                        margin: const EdgeInsets.only(top: 24, bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Monto estimado:",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              "₲${UtilesApp.formatearGuaranies(monto)}",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          final confirmada = await controller.confirmarReserva();

                          if (confirmada) {
                            // Crear el resumen de la reserva
                            final auto = controller.autoSeleccionado.value!;
                            final piso = controller.pisoSeleccionado.value!;
                            final lugar = controller.lugarSeleccionado.value!;
                            final inicio = controller.horarioInicio.value!;
                            final salida = controller.horarioSalida.value!;
                            final duracionEnHoras = salida.difference(inicio).inMinutes / 60;
                            final monto = (duracionEnHoras * 10000).round();

                            // Mostrar diálogo de confirmación
                            await Get.dialog(
                              AlertDialog(
                                title: Row(
                                  children: [
                                    Icon(Icons.check_circle, color: Colors.green, size: 28),
                                    SizedBox(width: 8),
                                    Text("Reserva Confirmada"),
                                  ],
                                ),
                                content: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      _buildResumenItem(
                                        "Vehículo",
                                        "${auto.marca} ${auto.modelo} (${auto.chapa})",
                                      ),
                                      _buildResumenItem(
                                        "Ubicación",
                                        "Piso ${piso.descripcion} - Lugar ${lugar.codigoLugar}",
                                      ),
                                      _buildResumenItem(
                                        "Fecha",
                                        "${UtilesApp.formatearFechaDdMMAaaa(inicio)}",
                                      ),
                                      _buildResumenItem(
                                        "Desde",
                                        TimeOfDay.fromDateTime(inicio).format(context),
                                      ),
                                      _buildResumenItem(
                                        "Hasta",
                                        TimeOfDay.fromDateTime(salida).format(context),
                                      ),
                                      _buildResumenItem(
                                        "Duración",
                                        "${duracionEnHoras.toStringAsFixed(1)} horas",
                                      ),
                                      Divider(height: 24),
                                      _buildResumenItem(
                                        "Monto Total",
                                        "₲${UtilesApp.formatearGuaranies(monto)}",
                                        isBold: true,
                                      ),
                                    ],
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Get.back();
                                      Get.back(); // Volver a la pantalla anterior
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
                          } else {
                            Get.snackbar(
                              "Error",
                              "Verificá que todos los campos estén completos",
                              snackPosition: SnackPosition.TOP,
                              backgroundColor: Colors.red.shade100,
                              colorText: Colors.red.shade900,
                            );
                          }
                        },
                        child: const Text(
                          "Confirmar Reserva",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ),
          );
        },
      ),
    );
  }

  Widget _buildResumenItem(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                fontSize: isBold ? 16 : 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 