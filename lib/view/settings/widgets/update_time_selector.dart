import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../common/utils.dart';
import '../../../providers/params.dart';
import '../../../providers/weather_data.dart';

class UpdateTimeSelector extends StatelessWidget {
  const UpdateTimeSelector({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final paramsProvider = Provider.of<ParamsProvider>(context);

    return DropdownButtonFormField<int>(
        value: paramsProvider.updateTimeLimit!,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
        ),
        onChanged: (int? newValue) {
          paramsProvider.updateTimeLimit = newValue;
        },
        items: [
          ...Utils.supportedUpdateTimeLimit.map((int minutes) {
            return DropdownMenuItem<int>(
              value: Utils.supportedUpdateTimeLimit.indexOf(minutes),
              child: Text(
                "$minutes minutes",
                style: Utils.mobileTextStyle['body'],
              ),
            );
          })
        ]
    );
  }
}
