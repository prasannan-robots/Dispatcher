import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/handset_provider.dart';
import 'screens/tactical_display_simple.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => HandsetProvider())],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ground System Dispatcher',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF44FF44),
        scaffoldBackgroundColor: const Color(0xFF0A0E1A),
        fontFamily: 'monospace',
      ),
      home: const TacticalDisplay(),
      debugShowCheckedModeBanner: false,
    );
  }
}
