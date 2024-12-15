import 'package:flutter/material.dart';
import 'screens/joke_types_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lab2: Random Joke App',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        colorScheme: const ColorScheme.light(
          secondary: Colors.purple,
        ),
        buttonTheme: const ButtonThemeData(buttonColor: Colors.blueAccent),
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
          bodyLarge: TextStyle(fontSize: 16, color: Colors.black),
        ),
        scaffoldBackgroundColor: Colors.yellow[50],
      ),
      home: const JokeTypesScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
