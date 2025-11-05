import 'package:flutter/material.dart';
import 'layouts/mobile.dart';
import 'layouts/desktop.dart';

class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return const MobileLayout();
        } else {
          return const DesktopLayout();
        }
      },
    );
  }
}
