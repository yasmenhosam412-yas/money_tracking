import 'package:flutter/material.dart';

class TabRefreshOverlay extends StatelessWidget {
  final bool isRefreshing;
  final Color indicatorColor;
  final Widget child;

  const TabRefreshOverlay({
    super.key,
    required this.isRefreshing,
    required this.indicatorColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isRefreshing)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: LinearProgressIndicator(
              color: indicatorColor,
              backgroundColor: indicatorColor.withValues(alpha: 0.15),
            ),
          ),
      ],
    );
  }
}
