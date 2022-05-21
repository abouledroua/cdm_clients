// ignore_for_file: avoid_print

import 'dart:io';
import 'dart:math';
import 'package:cdm_clients/classes/data.dart';
import 'package:cdm_clients/lists/list_specialites.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  late SharedPreferences prefs;

  @override
  initState() {
    WidgetsFlutterBinding.ensureInitialized();
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        if (Data.production) {
          secureScreen();
        } else {
          unsecureScreen();
        }
      }
    } catch (e) {
      print("error : $e");
    }
    getSharedPrefs();
    super.initState();
  }

  secureScreen() async {
    // DISABLE SCREEN CAPTURE
    await FlutterWindowManager.addFlags(
        FlutterWindowManager.FLAG_KEEP_SCREEN_ON);
    await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
  }

  unsecureScreen() async {
    // DISABLE SCREEN CAPTURE
    await FlutterWindowManager.addFlags(
        FlutterWindowManager.FLAG_KEEP_SCREEN_ON);
    await FlutterWindowManager.clearFlags(FlutterWindowManager.FLAG_SECURE);
  }

  void onClose() {
    Navigator.pushReplacement(
        context,
        PageRouteBuilder(
            maintainState: true,
            opaque: true,
            pageBuilder: (context, _, __) => const ListSpecialite(),
            transitionDuration: const Duration(seconds: 2),
            transitionsBuilder: (context, anim1, anim2, child) {
              return FadeTransition(opacity: anim1, child: child);
            }));
  }

  getSharedPrefs() async {
    prefs = await SharedPreferences.getInstance();
    String? serverIP = prefs.getString('ServerIp');
    var local = prefs.getString('LocalIP');
    var intenet = prefs.getString('InternetIP');
    var mode = prefs.getInt('NetworkMode');
    mode ??= 2;
    Data.setNetworkMode(mode);
    local ??= "192.168.1.152";
    intenet ??= "atlasschool.dz";
    serverIP ??= mode == 1 ? local : intenet;
    if (serverIP != "") Data.setServerIP(serverIP);
    if (local != "") Data.setLocalIP(local);
    if (intenet != "") Data.setInternetIP(intenet);
    print("serverIP=$serverIP");
    Timer(const Duration(seconds: 3), onClose);
  }

  @override
  Widget build(BuildContext context) {
    Data.setSizeScreen(context);
    return SafeArea(
        child: Scaffold(
            resizeToAvoidBottomInset: true,
            body: Center(
                child: Container(
                    padding: const EdgeInsets.all(16),
                    width: min(Data.heightScreen, Data.widthScreen),
                    height: min(Data.heightScreen, Data.widthScreen),
                    child: Center(
                        child: Image.asset("images/CDM.png",
                            fit: BoxFit.cover))))));
  }
}
