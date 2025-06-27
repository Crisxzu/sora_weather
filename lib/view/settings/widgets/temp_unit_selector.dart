import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../common/utils.dart';
import '../../../providers/params.dart';

class TempUnitSelector extends StatelessWidget {
  const TempUnitSelector({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final paramsProvider = Provider.of<ParamsProvider>(context);
    final textStyle = Utils.getTextStyle(MediaQuery.of(context).size.width);

    return DropdownButtonFormField<TempUnit>(
        value: paramsProvider.tempUnit!,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
        ),
        onChanged: (TempUnit? newUnit) {
          paramsProvider.tempUnit = newUnit;
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
    );
  }
}
