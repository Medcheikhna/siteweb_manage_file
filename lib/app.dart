import 'package:flutter/material.dart';
import 'package:upload_file_site_web/const/app_theme.dart';
import 'package:upload_file_site_web/views/home_secreen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'File Manager',
      theme: AppTheme.lightTheme,
      home: const HomeScreen(),
    );
  }
}
