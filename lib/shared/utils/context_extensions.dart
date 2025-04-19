import 'dart:async';

import 'package:flutter/material.dart';

extension SizeExtension on BuildContext {
  double get height => MediaQuery.sizeOf(this).height;
  double get width => MediaQuery.sizeOf(this).width;
}

extension DialogExtension on BuildContext {
  FutureOr<T?> openDialog<T>(
    Widget child, {
    bool barrierDismissible = true,
  }) async {
    return await showDialog<T>(
      context: this,
      barrierDismissible: barrierDismissible,
      builder: (context) => child,
    );
  }

  FutureOr<T?> openBottomSheet<T>(
    Widget child, {
    bool barrierDismissible = true,
  }) async {
    return showModalBottomSheet(
      context: this,
      builder: (context) => child,
      isDismissible: barrierDismissible,
    );
  }
}
