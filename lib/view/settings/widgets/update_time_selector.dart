import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../common/utils.dart';
import '../../../providers/params.dart';

class UpdateTimeSelector extends StatelessWidget {
  const UpdateTimeSelector({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final paramsProvider = Provider.of<ParamsProvider>(context);
    final textStyle = Utils.getTextStyle(MediaQuery.of(context).size.width);

    return DropdownButtonFormField<int>(
        value: paramsProvider.updateTimeLimit!,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
        ),
        onChanged: (int? newValue) {
          paramsProvider.updateTimeLimit = newValue;
        },
        style: textStyle['body']!.copyWith(color: Utils.white),
        items: [
          ...Utils.supportedUpdateTimeLimit.map((int minutes) {
            return DropdownMenuItem<int>(
              value: Utils.supportedUpdateTimeLimit.indexOf(minutes),
              child: Text(
                "$minutes minutes",
              ),
            );
          })
        ]
    );
  }
}
