import 'package:flutter/material.dart';

class CustomSnackbar extends SnackBar {
  CustomSnackbar({super.key, required String content})
      : super(
          content: Text(
            content,
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.black.withOpacity(0.85),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding:
              const EdgeInsets.only(top: 10, right: 20, bottom: 10, left: 24),
          duration: const Duration(seconds: 2),
          // showCloseIcon: true
        );
}
