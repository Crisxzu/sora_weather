import 'package:flutter/material.dart';

import '../../../common/utils.dart';

class Panel extends StatelessWidget {
  const Panel({
    super.key,
    required this.child,
    this.height,
    this.radius = 25,
    this.padding = 8
  });
  final Widget child;
  final double? height;
  final double radius;
  final double padding;

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(padding),
        child: Container(
          height: height,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(radius)),
              color: Utils.fadeDarkBlue
          ),
          clipBehavior: Clip.hardEdge,
          child: child,
        )
    );
  }
}
