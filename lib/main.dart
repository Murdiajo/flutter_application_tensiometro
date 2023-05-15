import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import 'model/bluetooth.dart';
import 'screens/scan_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScopedModel<FlutterBleApp>(
      model: FlutterBleApp(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'APP Tensiometro',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const ScanPage(),
      ),
    );
  }
}
