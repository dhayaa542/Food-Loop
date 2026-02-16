import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/auth_screens.dart';

void main() {
  runApp(const FoodLoopApp());
}

class FoodLoopApp extends StatelessWidget {
  const FoodLoopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FoodLoop',
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
