import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/model/weather_data.dart';
import 'package:weather_app/providers/params.dart';
import 'package:weather_app/providers/weather_data.dart';
import 'package:weather_app/view/global/error.dart';
import 'package:weather_app/view/global/loading_indicator.dart';
import 'package:weather_app/view/home/widgets/current_weather.dart';
import 'package:weather_app/view/home/widgets/daily_forecast.dart';
import 'package:weather_app/view/home/widgets/footer.dart';

import '../../common/app_logger.dart';
import '../../common/utils.dart';
import '../global/gradient_background.dart';
import 'widgets/hourly_forecast.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final appBarHeight = kToolbarHeight;
  Future<WeatherData>? _weatherData;
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
    final weatherDataProvider = Provider.of<WeatherDataProvider>(context, listen: false);
    final paramsProvider = Provider.of<ParamsProvider>(context, listen: false);

    setState(() {
      _weatherData = weatherDataProvider.getData(paramsProvider.locale!.languageCode);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ParamsProvider>(
      builder: (context, provider, child) {
        return GradientBackground(
          child: SafeArea(
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                return RefreshIndicator(
                  key: provider.refreshIndicatorKey,
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
                      slivers: [
                        SliverToBoxAdapter(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                                minHeight: constraints.maxHeight
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: FutureBuilder<WeatherData>(
                                future: _weatherData,
                                builder: (context, snapshot) {
                                  if(snapshot.hasData) {
                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            CurrentWeatherView(data: snapshot.data!.current),
                                            HourlyForecastView(data: snapshot.data!.next24h),
                                            DailyForecastView(data: snapshot.data!.nextDays),
                                          ],
                                        ),
                                        Footer(data: snapshot.data!),
                                      ],
                                    );
                                  }
                                  else if(snapshot.hasError) {
                                    AppLogger.instance.e("Error when fetching weather data: ${snapshot.error}");

                                    return const ErrorMessage(message: null);
                                  }
                                  else {
                                    return const LoadingIndicator();
                                  }
                                },
                              ),
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
      },
    );
  }
}









