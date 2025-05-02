import 'package:flutter/material.dart';

import '../../common/utils.dart';

class GradientBackground extends StatelessWidget {
  const GradientBackground({
    super.key,
    this.child
  });
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: Utils.blueGradientColors
          )
      ),
      child: child,
    );
  }
}