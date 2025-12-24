import 'package:flutter/material.dart';

// A global notifier that holds a boolean (true = dark, false = light)
final ValueNotifier<bool> themeNotifier = ValueNotifier(false);