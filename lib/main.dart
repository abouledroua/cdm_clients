import 'package:cdm_clients/lists/list_specialites.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'CDM Clients',
        theme: ThemeData(
            primarySwatch: Colors.blue,
            scaffoldBackgroundColor: Colors.white,
            appBarTheme: const AppBarTheme(
                backgroundColor: Color.fromARGB(255, 32, 99, 162),
                titleTextStyle: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w500)),
            inputDecorationTheme: const InputDecorationTheme(
                border: OutlineInputBorder(borderSide: BorderSide(width: 1))),
            textTheme: const TextTheme(
                caption: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.black),
                headline4: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.black))),
        home: const ListSpecialite());
  }
}
