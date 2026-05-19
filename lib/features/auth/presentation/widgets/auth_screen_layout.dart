import 'package:flutter/material.dart';
import 'package:imrpo/core/theme/app_decorations.dart';
import 'package:imrpo/core/utils/app_colors.dart';

/// Shared auth shell: gradient header + elevated form card (matches home header).
class AuthScreenLayout extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget child;
  final Widget? footer;
  final VoidCallback? onBack;

  const AuthScreenLayout({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.child,
    this.footer,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _AuthGradientHeader(
              icon: icon,
              title: title,
              subtitle: subtitle,
              topPadding: topPadding,
              onBack: onBack,
            ),
            Expanded(
              child: Transform.translate(
                offset: const Offset(0, -28),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          decoration: AppDecorations.card().copyWith(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(22, 28, 22, 24),
                            keyboardDismissBehavior:
                                ScrollViewKeyboardDismissBehavior.onDrag,
                            child: child,
                          ),
                        ),
                      ),
                      if (footer != null) ...[
                        const SizedBox(height: 12),
                        footer!,
                        SizedBox(height: MediaQuery.paddingOf(context).bottom + 8),
                      ] else
                        SizedBox(height: MediaQuery.paddingOf(context).bottom + 8),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AuthGradientHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final double topPadding;
  final VoidCallback? onBack;

  const _AuthGradientHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.topPadding,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: AppDecorations.gradientHeader(
        start: AppColors.primary,
        end: AppColors.secondary,
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, topPadding + 8, 20, 44),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (onBack != null)
              IconButton(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                color: Colors.white,
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.16),
                  padding: const EdgeInsets.all(10),
                ),
              )
            else
              const SizedBox(height: 8),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 56,
                  width: 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.28),
                    ),
                  ),
                  child: Icon(icon, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.4,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.88),
                          fontSize: 15,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
