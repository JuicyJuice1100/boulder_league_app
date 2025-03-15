import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

class ToastNotification {
  static void success(String description, String? title) {
    toastification.show(
      type: ToastificationType.success,
      style: ToastificationStyle.fillColored,
      title: Text(title ?? "Success"),
      description: Text(description),
      alignment: Alignment.topCenter,
      autoCloseDuration: const Duration(seconds: 4),
      borderRadius: BorderRadius.circular(12.0),
      applyBlurEffect: true,
    );
  }

  static void error(String description, String? title) {
    toastification.show(
      type: ToastificationType.error,
      style: ToastificationStyle.fillColored,
      title: Text(title ?? "Error"),
      description: Text(description),
      alignment: Alignment.topCenter,
      autoCloseDuration: const Duration(seconds: 4),
      borderRadius: BorderRadius.circular(12.0),
      applyBlurEffect: true,
    );
  }
}