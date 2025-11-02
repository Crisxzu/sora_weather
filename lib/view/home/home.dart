import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:weather_app/controller/weather_data.dart';
import 'package:weather_app/view/global/error.dart';
import 'package:weather_app/view/global/loading_indicator.dart';
import 'package:weather_app/view/home/widgets/current_weather.dart';
import 'package:weather_app/view/home/widgets/daily_forecast.dart';
import 'package:weather_app/view/home/widgets/footer.dart';

import '../../common/app_logger.dart';
import '../../common/utils.dart';
import '../../controller/params.dart';
import '../global/gradient_background.dart';
import 'widgets/hourly_forecast.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final appBarHeight = kToolbarHeight;
  ScrollController controller = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadWeatherData();
  }

  Future<void> _loadWeatherData() async {
    final WeatherDataController weatherDataController = Get.find();
    final ParamsController paramsController = Get.find();
    
    await weatherDataController.fetchData(paramsController.locale!.languageCode);
  }

  @override
  Widget build(BuildContext context) {
    final ParamsController paramsController = Get.find();
    final WeatherDataController weatherDataController = Get.find();

    return GradientBackground(
      child: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return RefreshIndicator(
              key: paramsController.refreshIndicatorKey,
              color: Utils.white,
              backgroundColor: Utils.darkBlue,
              strokeWidth: 4.0,
              onRefresh: () async {
                _loadWeatherData();
                return await Future.delayed(const Duration(seconds: 3));
              },
              child: Scrollbar(
                thumbVisibility: kIsWeb || Utils.checkIfDesktop(),
                controller: controller,
                child: CustomScrollView(
                  controller: controller,
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                            minHeight: constraints.maxHeight
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Obx(() {
                            if(weatherDataController.isLoading) {
                              return const LoadingIndicator();
                            }

                            if(weatherDataController.error.isNotEmpty) {
                              AppLogger.instance.e("Error when fetching weather data: ${weatherDataController.error}");

                              return const ErrorMessage(message: null);
                            }

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CurrentWeatherView(data: weatherDataController.data!.current),
                                    HourlyForecastView(data: weatherDataController.data!.next24h),
                                    DailyForecastView(data: weatherDataController.data!.nextDays),
                                  ],
                                ),
                                Footer(data: weatherDataController.data!),
                              ],
                            );
                          }),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}









