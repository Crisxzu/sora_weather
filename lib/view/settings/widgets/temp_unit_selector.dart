import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/utils.dart';
import '../../../controller/params.dart';

class TempUnitSelector extends StatelessWidget {
  const TempUnitSelector({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final ParamsController paramsController = Get.find();
    final textStyle = Utils.getTextStyle(MediaQuery.of(context).size.width);

    return Obx(() =>
        DropdownButtonFormField<TempUnit>(
            value: paramsController.tempUnit!,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
            onChanged: (TempUnit? newUnit) {
              paramsController.tempUnit = newUnit;
            },
            style: textStyle['body']!.copyWith(color: Utils.white),
            items: [
              ...Utils.tempUnits.values.toList().map((TempUnit unit) {
                return DropdownMenuItem<TempUnit>(
                  value: unit,
                  child: Text(
                    "${unit.unit} (${Utils.makeTitle(unit.name)})",
                  ),
                );
              })
            ]
        )
    );
  }
}
