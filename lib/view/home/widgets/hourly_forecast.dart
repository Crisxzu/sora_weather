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
  final double moveOffset = 200;
  final int moveDuration = 300;

  @override
  Widget build(BuildContext context) {
    return Panel(
      height: MediaQuery.of(context).size.width < Utils.lgBreakpoint ? 175 : 210,
      padding: 0,
      child: Row(
        children: [
          if(kIsWeb || Utils.checkIfDesktop())
            ...[
              SizedBox(
                height: double.infinity,
                child: IconButton(
                    onPressed: (){
                      // Don't scroll on max left position
                      if(controller.offset > 10) {
                        controller.animateTo(
                            controller.offset - moveOffset,
                            duration: Duration(milliseconds: moveDuration),
                            curve: Curves.easeInOut
                        );
                      }
                    },
                    style: const ButtonStyle(
                        shape: WidgetStatePropertyAll(ContinuousRectangleBorder())
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 50),
                    icon: const Icon(Icons.arrow_back)
                ),
              ),
              VerticalDivider(
                color: Utils.white.withValues(alpha: 0.2),
                width: 0,
              ),
            ],
          Expanded(
            child: ShaderMask(
              shaderCallback: (Rect bounds) {
                return LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.0),
                    Colors.white,
                    Colors.white,
                    Colors.white.withValues(alpha: 0.0),
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
          ),
          VerticalDivider(
            color: Utils.white.withValues(alpha: 0.2),
            width: 0,
          ),
          if(kIsWeb || Utils.checkIfDesktop())
            ...[
              VerticalDivider(
                color: Utils.white.withValues(alpha: 0.2),
                width: 0,
              ),
              SizedBox(
                height: double.infinity,
                child: IconButton(
                    onPressed: (){
                      // Don't scroll on max right position
                      if(controller.offset < controller.position.maxScrollExtent) {
                        controller.animateTo(
                            controller.offset + moveOffset,
                            duration: Duration(milliseconds: moveDuration),
                            curve: Curves.easeInOut
                        );
                      }
                    },
                    style: const ButtonStyle(
                        shape: WidgetStatePropertyAll(ContinuousRectangleBorder())
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 50),
                    icon: const Icon(Icons.arrow_forward)
                ),
              ),
            ]
        ],
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
