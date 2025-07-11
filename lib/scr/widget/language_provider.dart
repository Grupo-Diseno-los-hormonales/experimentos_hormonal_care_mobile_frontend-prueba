import 'package:flutter/material.dart';

class LanguageProvider extends InheritedWidget {
  final Locale locale;
  final Function(Locale) onLanguageChanged;

  const LanguageProvider({
    Key? key,
    required this.locale,
    required this.onLanguageChanged,
    required Widget child,
  }) : super(key: key, child: child);

  static LanguageProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<LanguageProvider>();
  }

  @override
  bool updateShouldNotify(LanguageProvider oldWidget) {
    return locale != oldWidget.locale;
  }
}
