import 'package:flutter/material.dart';

/// Hidden — app uses EGP only.
class DisplayCurrencySelector extends StatelessWidget {
  final bool lightStyle;

  const DisplayCurrencySelector({super.key, this.lightStyle = false});

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
