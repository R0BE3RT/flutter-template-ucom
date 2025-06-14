// ignore_for_file: deprecated_member_use

import 'package:finpay/api/local.db.service.dart';
import 'package:finpay/config/images.dart';
import 'package:finpay/config/textstyle.dart';
import 'package:finpay/Alumnos/model/sistema_reservas.dart';
import 'package:finpay/model/transaction_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  List<TransactionModel> transactionList = List<TransactionModel>.empty().obs;
  RxBool isWeek = true.obs;
  RxBool isMonth = false.obs;
  RxBool isYear = false.obs;
  RxBool isAdd = false.obs;
  RxList<Pago> pagosPrevios = <Pago>[].obs;
  
  // New variables for monthly summary
  RxInt pagosRealizadosMes = 0.obs;
  RxInt pagosPendientes = 0.obs;
  RxInt cantidadAutos = 0.obs;

  // Stream controllers for real-time updates
  final db = LocalDBService();

  @override
  void onInit() {
    super.onInit();
    customInit();
    // Iniciar la escucha de cambios
    ever(pagosPrevios, (_) => _actualizarResumen());
    ever(cantidadAutos, (_) => _actualizarResumen());
  }

  customInit() async {
    await cargarPagosPrevios();
    await cargarResumenMensual();
    await cargarCantidadAutos();
    isWeek.value = true;
    isMonth.value = false;
    isYear.value = false;
    transactionList = [
      TransactionModel(
        Theme.of(Get.context!).textTheme.titleLarge!.color,
        DefaultImages.transaction4,
        "Apple Store",
        "iPhone 12 Case",
        "- \$120,90",
        "09:39 AM",
      ),
      TransactionModel(
        HexColor(AppTheme.primaryColorString!).withOpacity(0.10),
        DefaultImages.transaction3,
        "Ilya Vasil",
        "Wise • 5318",
        "- \$50,90",
        "05:39 AM",
      ),
      TransactionModel(
        Theme.of(Get.context!).textTheme.titleLarge!.color,
        "",
        "Burger King",
        "Cheeseburger XL",
        "- \$5,90",
        "09:39 AM",
      ),
      TransactionModel(
        HexColor(AppTheme.primaryColorString!).withOpacity(0.10),
        DefaultImages.transaction1,
        "Claudia Sarah",
        "Finpay Card • 5318",
        "- \$50,90",
        "04:39 AM",
      ),
    ];
  }

  Future<void> cargarPagosPrevios() async {
    final data = await db.getAll("pagos.json");
    pagosPrevios.value = data.map((json) => Pago.fromJson(json)).toList();
  }

  Future<void> cargarResumenMensual() async {
    await _actualizarResumen();
  }

  Future<void> _actualizarResumen() async {
    // Get current month's start and end dates
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);
    
    // Count completed payments for current month
    pagosRealizadosMes.value = pagosPrevios.where((pago) {
      return pago.fechaPago.isAfter(startOfMonth) && 
             pago.fechaPago.isBefore(endOfMonth.add(const Duration(days: 1)));
    }).length;
    
    // Get pending reservations
    final reservas = await db.getAll("reservas.json");
    pagosPendientes.value = reservas.where((r) => r['estadoReserva'] == "PENDIENTE").length;
  }

  Future<void> cargarCantidadAutos() async {
    final data = await db.getAll("autos.json");
    cantidadAutos.value = data.length;
  }

  // Método para actualizar los pagos previos y el resumen
  Future<void> actualizarPagos() async {
    await cargarPagosPrevios();
    await _actualizarResumen();
  }

  // Método para actualizar la cantidad de autos
  Future<void> actualizarAutos() async {
    await cargarCantidadAutos();
  }
}
