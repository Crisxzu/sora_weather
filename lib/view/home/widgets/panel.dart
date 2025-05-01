import 'package:flutter/material.dart';

import '../../../common/utils.dart';

class Panel extends StatelessWidget {
  const Panel({
    super.key,
    required this.child,
    this.height
  });
  final Widget child;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(8),
        child: Container(
          height: height,
          decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(25)),
              color: Utils.fadeDarkBlue
          ),
          child: child,
        )
    );
  }
}
