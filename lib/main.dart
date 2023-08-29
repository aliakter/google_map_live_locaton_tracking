import 'package:flutter/material.dart';
import 'package:google_map_live_locaton_tracking/screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Live Location',
      home: HomeScreen(),
    );
  }
}
