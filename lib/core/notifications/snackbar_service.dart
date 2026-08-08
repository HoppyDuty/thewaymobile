import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../theme/app_theme_extension.dart';

part 'snackbar_service.g.dart';

/// The single entry point for showing snackbars (`uiuxrules.md` §12 —
/// "never trigger snackbars directly from business logic" / "must be
/// centralized"). Notifiers and services hold a reference to this instead
/// of needing a [BuildContext], so a Riverpod notifier can surface
/// "Course saved" or "You're offline, changes will sync automatically"
/// without reaching into the widget tree.
///
/// Wired up via [SnackbarService.scaffoldMessengerKey], which must be
/// passed to `MaterialApp.router(scaffoldMessengerKey: ...)`.
class SnackbarService {
  final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  void showSuccess(String message) => _show(message, isError: false);

  void showError(String message) => _show(message, isError: true);

  void _show(String message, {required bool isError}) {
    final messenger = scaffoldMessengerKey.currentState;
    if (messenger == null) return;

    final context = scaffoldMessengerKey.currentContext;
    final appColors = context?.appColors;

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? appColors?.danger : null,
        ),
      );
  }
}

@Riverpod(keepAlive: true)
SnackbarService snackbarService(SnackbarServiceRef ref) => SnackbarService();
