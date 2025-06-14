// ignore_for_file: deprecated_member_use

import 'package:card_swiper/card_swiper.dart';
import 'package:finpay/config/images.dart';
import 'package:finpay/config/textstyle.dart';
import 'package:finpay/controller/home_controller.dart';
import 'package:finpay/utils/utiles.dart';
import 'package:finpay/view/home/top_up_screen.dart';
import 'package:finpay/view/home/transfer_screen.dart';
import 'package:finpay/view/home/widget/circle_card.dart';
import 'package:finpay/view/home/widget/custom_card.dart';
import 'package:finpay/view/home/widget/transaction_list.dart';
import 'package:finpay/Alumnos/view/reservas_screen.dart';
import 'package:finpay/Alumnos/controller/reserva_controller.dart' as alumnos;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:finpay/Alumnos/model/sistema_reservas.dart';

class HomeView extends StatelessWidget {
  final HomeController homeController;

  const HomeView({Key? key, required this.homeController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.isLightTheme == false
          ? const Color(0xff15141F)
          : Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 50),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Good morning",
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            fontWeight: FontWeight.w400,
                            color: Theme.of(context).textTheme.bodySmall!.color,
                          ),
                    ),
                    Text(
                      "Good morning",
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 24,
                          ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      height: 28,
                      width: 69,
                      decoration: BoxDecoration(
                        color: const Color(0xffF6A609).withOpacity(0.10),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            DefaultImages.ranking,
                          ),
                          Text(
                            "Gold",
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                  color: const Color(0xffF6A609),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      height: 50,
                      width: 50,
                      child: Image.asset(
                        DefaultImages.avatar,
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
          Expanded(
            child: ListView(
              physics: const ClampingScrollPhysics(),
              padding: EdgeInsets.zero,
              children: [
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: AppTheme.isLightTheme == false
                              ? HexColor('#15141f')
                              : Theme.of(context).appBarTheme.backgroundColor,
                          border: Border.all(
                            color: HexColor(AppTheme.primaryColorString!)
                                .withOpacity(0.05),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Row(
                            children: [
                              customContainer(
                                title: "USD",
                                background: AppTheme.primaryColorString,
                                textColor: Colors.white,
                              ),
                              const SizedBox(width: 5),
                              customContainer(
                                title: "IDR",
                                background: AppTheme.isLightTheme == false
                                    ? '#211F32'
                                    : "#FFFFFF",
                                textColor: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .color,
                              )
                            ],
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.add,
                            color: HexColor(AppTheme.primaryColorString!),
                            size: 20,
                          ),
                          Text(
                            "Add Currency",
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                  color: HexColor(AppTheme.primaryColorString!),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: SizedBox(
                    height: 180,
                    width: Get.width,
                    child: Swiper(
                      itemBuilder: (BuildContext context, int index) {
                        return SvgPicture.asset(
                          DefaultImages.debitcard,
                          fit: BoxFit.fill,
                        );
                      },
                      itemCount: 3,
                      viewportFraction: 1,
                      scale: 0.9,
                      autoplay: true,
                      itemWidth: Get.width,
                      itemHeight: 180,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    InkWell(
                      focusColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      onTap: () {
                        Get.to(const TopUpSCreen(),
                            transition: Transition.downToUp,
                            duration: const Duration(milliseconds: 500));
                      },
                      child: circleCard(
                        image: DefaultImages.topup,
                        title: "Pagar",
                      ),
                    ),
                    InkWell(
                      focusColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      onTap: () {},
                      child: circleCard(
                        image: DefaultImages.withdraw,
                        title: "Withdraw",
                      ),
                    ),
                    InkWell(
                      focusColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      onTap: () {
                        Get.to(
                          () => ReservaScreen(),
                          binding: BindingsBuilder(() {
                            Get.delete<alumnos.ReservaController>(); // 🔥 elimina instancia previa
                            Get.create(() => alumnos.ReservaController());
                          }),
                          transition: Transition.downToUp,
                          duration: const Duration(milliseconds: 500),
                        );
                      },
                      child: circleCard(
                        image: DefaultImages.transfer,
                        title: "Reservar",
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 30),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 10, right: 10, bottom: 50),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.isLightTheme == false
                          ? const Color(0xff211F32)
                          : const Color(0xffFFFFFF),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xff000000).withOpacity(0.10),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 16, right: 16, top: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Pagos previos",
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge!
                                    .copyWith(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Obx(() {
                          return Column(
                            children: homeController.pagosPrevios.map((pago) {
                              final pagoObj = pago as Pago;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: ListTile(
                                  leading: const Icon(Icons.payments_outlined),
                                  title: Text(
                                      "Reserva: ${pagoObj.codigoReservaAsociada}"),
                                  subtitle: Text(
                                      "Fecha: ${UtilesApp.formatearFechaDdMMAaaa(pagoObj.fechaPago)}"),
                                  trailing: Text(
                                    "- ${UtilesApp.formatearGuaranies(pagoObj.montoPagado)}",
                                    style: const TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                ),
                              );
                            }).toList(),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.isLightTheme == false
                          ? const Color(0xff211F32)
                          : const Color(0xffFFFFFF),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xff000000).withOpacity(0.10),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Resumen del Mes",
                            style: Theme.of(context).textTheme.titleLarge!.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildSummaryCard(
                                context,
                                "Pagos Realizados",
                                homeController.pagosRealizadosMes.toString(),
                                Icons.payments_outlined,
                                Colors.green,
                              ),
                              _buildSummaryCard(
                                context,
                                "Pagos Pendientes",
                                homeController.pagosPendientes.toString(),
                                Icons.pending_actions_outlined,
                                Colors.orange,
                              ),
                              _buildSummaryCard(
                                context,
                                "Autos Registrados",
                                homeController.cantidadAutos.toString(),
                                Icons.directions_car_outlined,
                                Colors.blue,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      width: (Get.width - 60) / 3,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
              color: Theme.of(context).textTheme.bodySmall!.color,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
