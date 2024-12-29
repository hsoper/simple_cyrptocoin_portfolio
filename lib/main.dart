import 'dart:io';
import 'package:simple_cyrptocoin_portfolio/views/mainpage.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter/material.dart';

void main() async {
  if (Platform.isWindows) {
    sqfliteFfiInit(); // this is only for windows
    databaseFactory = databaseFactoryFfi;
  }
  runApp(MaterialApp(
    theme: ThemeData(useMaterial3: false),
    debugShowCheckedModeBanner: false,
    home: const MainPageLoader(),
  ));
}
