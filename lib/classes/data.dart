// ignore_for_file: avoid_print

import 'dart:math';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Data {
  static bool production = true;
  static String serverIP = "";
  static String localIP = "";
  static String internetIP = "";
  static int networkMode = 1;
  static int nbArticle = 0;
  static bool _loadingEnfant = false,
      canPop = false,
      loadingAdmin = false,
      _errorEnfant = false,
      errorAdmin = false,
      isLandscape = false,
      isPortrait = false,
      updList = false;
  static int timeOut = 0;
  static int specId = -1;
  static double minTablet = 450;
  static double widthScreen = double.infinity;
  static late double heightScreen;
  static late double heightmyAppBar;
  static String www = "CDM";
  static int index = 0;
  static late BuildContext myContext;
  static late int? adminId;
  static List<bool> selections = [];
  static const MaterialColor white = MaterialColor(
    0xFFFFFFFF,
    <int, Color>{
      50: Color(0xFFFFFFFF),
      100: Color(0xFFFFFFFF),
      200: Color(0xFFFFFFFF),
      300: Color(0xFFFFFFFF),
      400: Color(0xFFFFFFFF),
      500: Color(0xFFFFFFFF),
      600: Color(0xFFFFFFFF),
      700: Color(0xFFFFFFFF),
      800: Color(0xFFFFFFFF),
      900: Color(0xFFFFFFFF),
    },
  );
  static List<Color> lightColor = [
    Colors.blue.shade50,
    Colors.red.shade50,
    Colors.amber.shade50,
    Colors.blueGrey.shade50,
    Colors.blue.shade50,
    Colors.green.shade50,
    Colors.deepPurple.shade50,
    Colors.cyan.shade50,
    Colors.brown.shade50,
    Colors.deepOrange.shade50,
    Colors.deepPurple.shade50,
    Colors.lightBlue.shade50,
    Colors.lime.shade50,
    Colors.orange.shade50,
    Colors.teal.shade50,
    Colors.pink.shade50,
    Colors.indigo.shade50,
    Colors.grey.shade50,
    Colors.yellow.shade50,
    Colors.black12,
    Colors.amberAccent.shade100,
    Colors.blueAccent.shade100,
    Colors.purpleAccent.shade100,
    Colors.cyanAccent.shade100,
    Colors.tealAccent.shade100,
    Colors.greenAccent.shade100,
    Colors.deepPurpleAccent.shade100,
    Colors.tealAccent.shade100
  ];
  static List<Color> darkColor = [
    Colors.amberAccent,
    Colors.blue,
    Colors.red,
    Colors.amber,
    Colors.blueGrey,
    Colors.blue,
    Colors.green,
    Colors.deepPurple,
    Colors.greenAccent,
    Colors.cyan,
    Colors.blueAccent,
    Colors.brown,
    Colors.cyanAccent,
    Colors.deepOrange,
    Colors.deepPurple,
    Colors.lightBlue,
    Colors.lime,
    Colors.orange,
    Colors.purpleAccent,
    Colors.tealAccent,
    Colors.deepPurpleAccent,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
    Colors.grey,
    Colors.yellow,
    Colors.black12
  ];

  static int getTimeOut() => timeOut;

  static int getNbArticle() => nbArticle;

  static int getNetworkMode() => networkMode;

  static String getServerIP() => serverIP;

  static String getLocalIP() => localIP;

  static String getInternetIP() => internetIP;

  static String getFile(pFile) => getServerDirectory("80") + "/FILES/$pFile";

  static String getServerDirectory([port = "80"]) => ((serverIP == "")
      ? ""
      : "https://$serverIP" +
          (port != "" && networkMode == 1 ? ":" + port : "") +
          "/" +
          www);

  static String getImage(pImage, pType) =>
      getServerDirectory("80") + "/IMAGE/$pType/$pImage";

  static setNbArticle(nb) {
    nbArticle = nb;
  }

  static setServerIP(ip) async {
    serverIP = ip;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('ServerIp', serverIP);
  }

  static setLocalIP(ip) async {
    localIP = ip;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('LocalIP', ip);
  }

  static setInternetIP(ip) async {
    internetIP = ip;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('InternetIP', ip);
  }

  static setNetworkMode(mode) async {
    networkMode = mode;
    (mode == 1) ? timeOut = 5 : timeOut = 7;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('NetworkMode', mode);
    prefs.setInt('TIMEOUT', timeOut);
  }

  static showSnack({required String msg, required Color color}) {
    ScaffoldMessenger.of(myContext)
        .showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  static setSizeScreen(context) {
    widthScreen = MediaQuery.of(context).size.width;
    heightScreen = MediaQuery.of(context).size.height;
    isLandscape = widthScreen > heightScreen;
    isPortrait = !isLandscape;
    heightmyAppBar = heightScreen * 0.2;
  }

  static Widget _drawerButton(
      {required String text,
      required IconData icon,
      required Color? color,
      required onTap}) {
    return InkWell(
        onTap: onTap,
        child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            margin: EdgeInsets.symmetric(
                horizontal: min(heightScreen, widthScreen) / 14, vertical: 4),
            decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.all(Radius.circular(20))),
            child: Ink(
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(icon, color: Colors.black, size: 26),
              const SizedBox(width: 10),
              Text(text,
                  style: GoogleFonts.laila(
                      color: Colors.black,
                      fontSize: 17,
                      fontWeight: FontWeight.bold))
            ]))));
  }

  static makeExternalRequest(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
