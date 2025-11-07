import 'package:flutter/material.dart';
import '../styles/app_styles.dart';

class MenuButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Icon icon;
  final TextStyle? textStyle;

  const MenuButton({
    super.key,
    required this.label,
    required this.onPressed,
    required this.icon,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: AppStyles.menuButtonStyle,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon,
          SizedBox(height: 8),
          Text(label, style: textStyle),
        ],
      ),
    );
  }
}
