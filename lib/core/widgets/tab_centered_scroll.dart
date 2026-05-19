import 'package:flutter/material.dart';

/// Centers [child] in a scroll view for tabs inside [NestedScrollView].
Widget tabCenteredScroll(Widget child) {
  return CustomScrollView(
    physics: const AlwaysScrollableScrollPhysics(),
    slivers: [
      SliverFillRemaining(
        hasScrollBody: false,
        child: Center(child: child),
      ),
    ],
  );
}
