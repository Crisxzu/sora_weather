import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/utils.dart';
import '../../../controller/params.dart';

class UpdateTimeSelector extends StatelessWidget {
  const UpdateTimeSelector({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final ParamsController paramsController = Get.find();
    final textStyle = Utils.getTextStyle(MediaQuery.of(context).size.width);

    return Obx(() =>
        DropdownButtonFormField<int>(
            value: paramsController.updateTimeLimit!,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
            onChanged: (int? newValue) {
              paramsController.updateTimeLimit = newValue;
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
        )
    );
  }
}
