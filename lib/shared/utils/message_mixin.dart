import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

mixin MessageMixin {
  void showSuccess(BuildContext context, String message, {int seconds = 5}) {
    _showSnackbar(
      context,
      message,
      type: _MessageType.success,
      seconds: seconds,
    );
  }

  void showError(BuildContext context, String message, {int seconds = 5}) {
    _showSnackbar(context, message, type: _MessageType.error, seconds: seconds);
  }

  void showInfo(BuildContext context, String message, {int seconds = 5}) {
    _showSnackbar(context, message, type: _MessageType.info, seconds: seconds);
  }

  void _showSnackbar(
    BuildContext context,
    String message, {
    int seconds = 5,
    required _MessageType type,
  }) {
    final backgroundColor = switch (type) {
      _MessageType.success => Colors.green,
      _MessageType.info => AppColors.darkPrimary100,
      _MessageType.error => AppColors.darkAccent100,
    };

    final fontColor = switch (type) {
      _MessageType.success => AppColors.darkBg100,
      _MessageType.info => AppColors.darkBg100,
      _MessageType.error => AppColors.darkBg100,
    };

    final icon = switch (type) {
      _MessageType.success => Icons.check_circle_outline,
      _MessageType.info => Icons.info_outline_rounded,
      _MessageType.error => Icons.warning_amber_rounded,
    };

    final snackBar = SnackBar(
      content: Row(
        spacing: 8,
        children: [
          Icon(icon, color: fontColor),
          Expanded(child: Text(message, style: TextStyle(color: fontColor))),
        ],
      ),
      duration: Duration(seconds: seconds),
      backgroundColor: backgroundColor,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}

enum _MessageType { success, info, error }
