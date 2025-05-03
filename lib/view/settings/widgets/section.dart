import 'package:flutter/material.dart';

import '../../../common/utils.dart';

class SectionHeader extends StatelessWidget {
  final String title;

  const SectionHeader({
    super.key, required this.title
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Utils.mobileTextStyle['bodyHighlight'],
      ),
    );
  }
}

class ParamSection extends StatelessWidget {
  final String title;
  final Widget child;

  const ParamSection({
    super.key,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
            title: title
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: child,
        )
      ],
    );
  }
}