import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Future<T?> pushScreen<T>(BuildContext context, Widget screen) {
  return Navigator.of(context).push<T>(
    Platform.isIOS
        ? CupertinoPageRoute(builder: (_) => screen)
        : MaterialPageRoute(builder: (_) => screen),
  );
}
