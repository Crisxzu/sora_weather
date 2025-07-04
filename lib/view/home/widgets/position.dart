import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../common/utils.dart';
import '../../../providers/weather_data.dart';

class PositionView extends StatelessWidget {
  const PositionView({
    super.key,
  });


  @override
  Widget build(BuildContext context) {
    final weatherProvider = Provider.of<WeatherDataProvider>(context);
    final textStyle = Utils.getTextStyle(MediaQuery.of(context).size.width);


    return Row(
      children: [
        ...[
          if(weatherProvider.data != null)
            Text(
              weatherProvider.data!.location.name,
              overflow: TextOverflow.ellipsis,
              style: textStyle['title2'],
            )
        ]
      ],
    );
  }
}
