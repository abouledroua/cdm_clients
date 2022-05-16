// ignore_for_file: avoid_print

import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cdm_clients/classes/data.dart';
import 'package:cdm_clients/classes/specialite.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ListSpecialite extends StatefulWidget {
  const ListSpecialite({Key? key}) : super(key: key);

  @override
  State<ListSpecialite> createState() => _ListSpecialiteState();
}

class _ListSpecialiteState extends State<ListSpecialite> {
  bool loading = true, error = false;
  List<Specialite> specs = [];
  late SharedPreferences prefs;

  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized(); //all widgets are rendered here
    getSharedPrefs();
    super.initState();
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

    loading = true;
    getListSpecialite();
  }

  getListSpecialite() async {
    setState(() {
      loading = true;
      error = false;
    });
    specs.clear();
    String serverDir = Data.getServerDirectory();
    var url = "$serverDir/GET_SPECIALITIES.php";
    print("url=$url");
    Uri myUri = Uri.parse(url);
    http
        .post(myUri, body: {})
        .timeout(Duration(seconds: Data.timeOut))
        .then((response) async {
          if (response.statusCode == 200) {
            var responsebody = jsonDecode(response.body);
            Specialite e;
            for (var m in responsebody) {
              e = Specialite(
                  designation: m['DESIGNATION'],
                  id: int.parse(m['ID_SPECIALITE']),
                  image: m['IMAGE']);
              specs.add(e);
            }
            setState(() {
              loading = false;
            });
          } else {
            setState(() {
              specs.clear();
              loading = false;
              error = true;
            });
            AwesomeDialog(
                    context: context,
                    dialogType: DialogType.ERROR,
                    showCloseIcon: true,
                    title: 'Erreur',
                    desc: 'Probleme de Connexion avec le serveur !!!')
                .show();
          }
        })
        .catchError((error) {
          print("erreur : $error");
          setState(() {
            specs.clear();
            loading = false;
            error = true;
          });
          AwesomeDialog(
                  context: context,
                  dialogType: DialogType.ERROR,
                  showCloseIcon: true,
                  title: 'Erreur',
                  desc: 'Probleme de Connexion avec le serveur !!!')
              .show();
        });
  }

  @override
  Widget build(BuildContext context) {
    Data.setSizeScreen(context);
    double minSize = min(Data.heightScreen, Data.widthScreen) / 2;
    print("Data.heightScreen=${Data.heightScreen}");
    print("Data.widthScreen=${Data.widthScreen}");
    print("minSize=$minSize");
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text("Liste des Spécialités"),
          actions: [
            IconButton(onPressed: () {}, icon: const Icon(Icons.login))
          ],
        ),
        body: ListView(children: [
          Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                  child: Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: specs
                          .map((item) {
                            return Material(
                                elevation: 8,
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(28),
                                clipBehavior: Clip.antiAliasWithSaveLayer,
                                child: InkWell(
                                    onTap: () {},
                                    splashColor: Colors.black26,
                                    child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Ink.image(
                                              height: minSize,
                                              width: minSize,
                                              fit: BoxFit.cover,
                                              image: CachedNetworkImageProvider(
                                                  Data.getImage(item.image,
                                                      "SPECIALITE"))),
                                          const SizedBox(height: 6),
                                          Text(item.designation,
                                              style: const TextStyle(
                                                  fontSize: 32,
                                                  color: Colors.white)),
                                          const SizedBox(height: 6)
                                        ])));
                          })
                          .toList()
                          .cast<Widget>())))
        ]));
  }
}
