import 'package:alarmapp/core/app_theme/app_colors.dart';
import 'package:alarmapp/core/app_theme/app_texts_styles.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class CustomElevatedButton extends ConsumerWidget {
  final VoidCallback onPressed;

  final IconData icon;
  final String? labelText;
  final Color color;
  final Color iconColor;

  const CustomElevatedButton({
    super.key,
    required this.onPressed,
    this.icon = Icons.play_arrow,
    this.labelText,
    this.color = AppColors.primaryBlueLight,
    this.iconColor = AppColors.redColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AnimatedContainer(
      curve: Curves.easeInOut,
      duration: Duration(milliseconds: 17),

      child: labelText != null
          ? ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                elevation: 0.0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
              ),
              onPressed: onPressed,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(icon),
                  SizedBox(width: 8),
                  Text(
                    labelText!,
                    style: AppTextStyles.labelLarge.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          : Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                color: iconColor,
                onPressed: onPressed,
                icon: Icon(icon),
              ),
            ),
    );
  }
}
