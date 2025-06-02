import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/view/home/widgets/panel.dart';

import '../../../common/utils.dart';
import '../../../model/hourly_forecast.dart';
import '../../../providers/params.dart';
import 'humidity.dart';
import 'weather_icon.dart';

class HourlyForecastView extends StatefulWidget {
  const HourlyForecastView({
    super.key,
    required this.data
  });

  final List<HourlyForecast> data;

  @override
  State<HourlyForecastView> createState() => _HourlyForecastViewState();
}

class _HourlyForecastViewState extends State<HourlyForecastView> {
  ScrollController controller = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Panel(
      height: MediaQuery.of(context).size.width < Utils.lgBreakpoint ? 175 : 210,
      child: ShaderMask(
        shaderCallback: (Rect bounds) {
          return LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Colors.white.withOpacity(0.0),
              Colors.white,
              Colors.white,
              Colors.white.withOpacity(0.0),
            ],
            stops: const [0.0, 0.1, 0.9, 1.0],
          ).createShader(bounds);
        },
        blendMode: BlendMode.dstIn,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Scrollbar(
            thumbVisibility: kIsWeb || Utils.checkIfDesktop(),
            controller: controller,
            child: ListView.builder(
              controller: controller,
              scrollDirection: Axis.horizontal,
              itemCount: widget.data.length,
              itemBuilder: (BuildContext context, int index) {
                return HourForecast(
                    data: widget.data[index]
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class HourForecast extends StatelessWidget {
  const HourForecast({
    super.key,
    required this.data,
  });

  final HourlyForecast data;

  @override
  Widget build(BuildContext context) {
    final paramsProvider = Provider.of<ParamsProvider>(context);
    final textStyle = Utils.getTextStyle(MediaQuery.of(context).size.width);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8),
      child: Column(
        children: [
          Text(
            Utils.getHour(data.timestamp, paramsProvider.locale!),
            style: textStyle['body']!.copyWith(color: Utils.gray),
          ),
          WeatherIcon(
            iconCode: "${data.condition.iconCode}",
            isDay: data.isDay,
          ),
          Text(
            paramsProvider.tempUnit!.toStr(data.temp),
            style: textStyle['bodyHighlight'],
          ),
          HumidityView(humidity: data.humidity)
        ],
      ),
    );
  }
}
