import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/common/utils.dart';
import 'package:weather_app/controller/weather_data.dart' show ApiException;
import 'package:weather_app/providers/location.dart';
import 'package:weather_app/providers/params.dart';
import 'package:weather_app/providers/weather_data.dart';
import 'package:weather_app/view/global/error.dart';
import 'package:weather_app/view/global/loading_indicator.dart';
import 'package:weather_app/view/home/widgets/current_weather.dart';
import 'package:weather_app/view/home/widgets/daily_forecast.dart';
import 'package:weather_app/view/home/widgets/footer.dart';

import '../../common/app_logger.dart';
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

  int? _lastActiveIndex;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locationProvider = Provider.of<LocationProvider>(context);
    if (locationProvider.isReady && locationProvider.activeIndex != _lastActiveIndex) {
      _lastActiveIndex = locationProvider.activeIndex;
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadWeatherData());
    }
  }

  void _loadWeatherData() {
    final weatherDataProvider = Provider.of<WeatherDataProvider>(context, listen: false);
    final paramsProvider = Provider.of<ParamsProvider>(context, listen: false);
    final locationProvider = Provider.of<LocationProvider>(context, listen: false);

    weatherDataProvider.getData(
      paramsProvider.locale!.languageCode,
      paramsProvider.tempUnit!,
      locationProvider.activeLocation,
      Utils.supportedUpdateTimeLimit[paramsProvider.updateTimeLimit!],
    );
  }

  int? _errorStatusCode(Object error) {
    if (error is ApiException) return error.statusCode;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ParamsProvider>(
      builder: (context, paramsProvider, child) {
        return GradientBackground(
          child: SafeArea(
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                return RefreshIndicator(
                  key: paramsProvider.refreshIndicatorKey,
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
                              child: Consumer<WeatherDataProvider>(
                                builder: (context, weatherProvider, _) {
                                  if (weatherProvider.data != null) {
                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            CurrentWeatherView(data: weatherProvider.data!.current),
                                            HourlyForecastView(data: weatherProvider.data!.next24h),
                                            DailyForecastView(data: weatherProvider.data!.nextDays),
                                          ],
                                        ),
                                        Footer(data: weatherProvider.data!),
                                      ],
                                    );
                                  } else if (weatherProvider.error != null) {
                                    AppLogger.instance.e("Error when fetching weather data: ${weatherProvider.error}");
                                    return ErrorMessage(statusCode: _errorStatusCode(weatherProvider.error!));
                                  } else {
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
