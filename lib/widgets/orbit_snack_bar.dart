import 'package:flutter/material.dart';

/// Shows a short message at the bottom of the screen (replacing any message
/// that is still showing).
void showOrbitSnackBar(BuildContext context, String message) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
  );
}
