// ignore_for_file: avoid_print, depend_on_referenced_packages

import 'dart:io';
import 'dart:math';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cdm_clients/classes/data.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:path/path.dart' as p;

class FicheSpecialite extends StatefulWidget {
  final int idSpecialite;
  const FicheSpecialite({Key? key, required this.idSpecialite})
      : super(key: key);

  @override
  State<FicheSpecialite> createState() => _FicheSpecialiteState();
}

class _FicheSpecialiteState extends State<FicheSpecialite> {
  late int idSpecialite;
  bool loading = false,
      valDes = false,
      isSwitched = true,
      valider = false,
      selectPhoto = false;
  TextEditingController txtDes = TextEditingController(text: "");
  String myPhoto = "";
  final picker = ImagePicker();
  FocusNode focusNode = FocusNode();

  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized(); //all widgets are rendered here
    idSpecialite = widget.idSpecialite;
    loading = false;
    valider = false;
    myPhoto = "";
    selectPhoto = false;
    getSpecialiteInfo();
    if (idSpecialite == 0) {
      setState(() {
        loading = false;
      });
    }
    super.initState();
  }

  getSpecialiteInfo() async {
    setState(() {
      loading = true;
    });
    String serverDir = Data.getServerDirectory();
    var url = "$serverDir/GET_INFO_SPECIALITES.php";
    print("url=$url");
    Uri myUri = Uri.parse(url);
    http
        .post(myUri, body: {"ID_SPECIALITE": idSpecialite.toString()})
        .timeout(Duration(seconds: Data.timeOut))
        .then((response) async {
          if (response.statusCode == 200) {
            var responsebody = jsonDecode(response.body);
            for (var m in responsebody) {
              txtDes.text = m['DESIGNATION'];
              myPhoto = m['IMAGE'];
              int petat = int.parse(m['ETAT']);
              isSwitched = (petat == 1);
            }
            setState(() {
              loading = false;
            });
          } else {
            setState(() {
              loading = false;
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
          setState(() {
            loading = false;
          });
          print("erreur : $error");
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
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Data.setSizeScreen(context);
    double minSize = min(Data.heightScreen, Data.widthScreen) / 2;
    // focusNode.requestFocus();
    return SafeArea(
      child: Scaffold(
          resizeToAvoidBottomInset: true,
          appBar:
              AppBar(title: const Text("Fiche Spécialité"), centerTitle: true),
          body: loading
              ? const Center(child: CircularProgressIndicator.adaptive())
              : bodyContent(minSize)),
    );
  }

  ListView bodyContent(double minSize) => ListView(children: [
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 30),
            child: TextField(
                autofocus: true,
                focusNode: focusNode,
                enabled: !valider,
                controller: txtDes,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.text,
                style: const TextStyle(fontSize: 16, color: Colors.black),
                decoration: InputDecoration(
                    errorText: valDes ? 'Champs Obligatoire' : null,
                    prefixIcon: const Padding(
                        padding: EdgeInsets.only(right: 4),
                        child: Icon(Icons.supervised_user_circle_outlined,
                            color: Colors.black)),
                    contentPadding: const EdgeInsets.only(bottom: 3),
                    labelText: "Désignation de la Spécialité",
                    labelStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                    hintText: "Désignation de la Spécialité",
                    hintStyle:
                        const TextStyle(fontSize: 14, color: Colors.grey),
                    floatingLabelBehavior: FloatingLabelBehavior.always))),
        Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
                child: InkWell(
                    onTap: () async {
                      await pickPhoto();
                    },
                    splashColor: Colors.black26,
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      selectPhoto
                          ? Ink.image(
                              height: minSize,
                              width: minSize,
                              fit: BoxFit.cover,
                              image: FileImage(File(myPhoto)))
                          : myPhoto.isEmpty
                              ? Ink.image(
                                  height: minSize,
                                  width: minSize,
                                  fit: BoxFit.cover,
                                  image:
                                      const AssetImage("images/noImages.jpg"))
                              : Ink.image(
                                  height: minSize,
                                  width: minSize,
                                  fit: BoxFit.cover,
                                  image: NetworkImage(
                                      Data.getImage(myPhoto, "SPECIALITE")))
                    ])))),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Switch(
              value: isSwitched,
              onChanged: (value) {
                if (!valider) {
                  setState(() {
                    isSwitched = !isSwitched;
                  });
                }
              }),
          const SizedBox(width: 5),
          Text(isSwitched ? "Actif" : "Inactif",
              style: const TextStyle(color: Colors.black))
        ]),
        const SizedBox(height: 16),
        Row(children: [
          const Spacer(flex: 2),
          Container(
              decoration: BoxDecoration(
                  color: Colors.green, borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              child: TextButton.icon(
                  onPressed: fnValider,
                  icon: const Icon(Icons.verified_rounded, color: Colors.white),
                  label: const Text("Valider",
                      style: TextStyle(color: Colors.white)))),
          const Spacer(flex: 1),
          Container(
              decoration: BoxDecoration(
                  color: Colors.red, borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              child: TextButton.icon(
                  onPressed: () {
                    AwesomeDialog(
                            context: context,
                            dialogType: DialogType.QUESTION,
                            showCloseIcon: true,
                            btnOkText: "Oui",
                            btnOkOnPress: () {
                              Navigator.pop(context);
                            },
                            btnCancelText: "Non",
                            btnCancelOnPress: () {},
                            title: '',
                            desc: "Voulez vous vraiment annuler ???")
                        .show();
                  },
                  icon: const Icon(Icons.cancel_outlined, color: Colors.white),
                  label: const Text("Annuler",
                      style: TextStyle(color: Colors.white)))),
          const Spacer(flex: 2)
        ])
      ]);

  fnValider() async {
    bool continuer = true;
    setState(() {
      valDes = txtDes.text.isEmpty;
    });
    if (txtDes.text.isEmpty) {
      AwesomeDialog(
              context: context,
              dialogType: DialogType.ERROR,
              showCloseIcon: true,
              title: 'Erreur',
              desc: 'Veuillez saisir la designation !!!')
          .show();
      continuer = false;
    } else if (!selectPhoto && myPhoto.isEmpty) {
      await AwesomeDialog(
              context: context,
              dialogType: DialogType.QUESTION,
              showCloseIcon: true,
              btnOkText: "Oui",
              btnOkOnPress: () {},
              btnCancelText: "Non",
              btnCancelOnPress: () {
                continuer = false;
              },
              title: '',
              desc: "Voulez vous vraiment continuer sans image ???")
          .show();
    }
    if (continuer) {
      print("valider");
      existSpecialite();
    }
  }

  existSpecialite() async {
    String serverDir = Data.getServerDirectory();
    var url = "$serverDir/EXIST_SPECIALITE.php";
    print(url);
    Uri myUri = Uri.parse(url);
    http
        .post(myUri, body: {
          "DESIGNATION": txtDes.text,
          "ID_SPECIALITE": idSpecialite.toString(),
        })
        .timeout(Duration(seconds: Data.timeOut))
        .then((response) async {
          if (response.statusCode == 200) {
            var responsebody = jsonDecode(response.body);
            int result = 0;
            for (var m in responsebody) {
              result = int.parse(m['ID_SPECIALITE']);
            }
            if (result == 0) {
              if (idSpecialite == 0) {
                insertSpecialite();
              } else {
                updateSpecialite();
              }
            } else {
              setState(() {
                valider = false;
              });
              AwesomeDialog(
                  context: context,
                  dialogType: DialogType.ERROR,
                  showCloseIcon: true,
                  title: 'Erreur',
                  desc: "Cette Spécialité existe déjà !!!");
            }
          } else {
            setState(() {
              valider = false;
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
            valider = false;
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

  updateSpecialite() async {
    String serverDir = Data.getServerDirectory();
    var url = "$serverDir/UPDATE_SPECIALITE.php";
    print(url);
    int petat = isSwitched ? 1 : 2;
    Uri myUri = Uri.parse(url);
    http.post(myUri, body: {
      "ID_SPECIALITE": idSpecialite.toString(),
      "DESIGNATION": txtDes.text.toUpperCase(),
      "ETAT": petat.toString(),
      "EXT": selectPhoto ? p.extension(myPhoto) : "",
      "DATA": selectPhoto ? base64Encode(File(myPhoto).readAsBytesSync()) : ""
    }).then((response) async {
      if (response.statusCode == 200) {
        var responsebody = response.body;
        print("Response=$responsebody");
        if (responsebody != "0") {
          Data.showSnack(
              msg: 'Information mis à jours ...', color: Colors.green);
          Navigator.of(context).pop();
        } else {
          setState(() {
            valider = false;
          });
          AwesomeDialog(
                  context: context,
                  dialogType: DialogType.ERROR,
                  showCloseIcon: true,
                  title: 'Erreur',
                  desc: 'Probleme lors de la mise a jour des informations !!!')
              .show();
        }
      } else {
        setState(() {
          valider = false;
        });
        AwesomeDialog(
                context: context,
                dialogType: DialogType.ERROR,
                showCloseIcon: true,
                title: 'Erreur',
                desc: 'Probleme de Connexion avec le serveur !!!')
            .show();
      }
    }).catchError((error) {
      print("erreur : $error");
      setState(() {
        valider = false;
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

  insertSpecialite() async {
    String serverDir = Data.getServerDirectory();
    var url = "$serverDir/INSERT_SPECIALITE.php";
    print(url);
    int petat = isSwitched ? 1 : 2;
    Uri myUri = Uri.parse(url);
    String ext = selectPhoto ? p.extension(myPhoto) : "";
    http.post(myUri, body: {
      "DESIGNATION": txtDes.text.toUpperCase(),
      "ETAT": petat.toString(),
      "EXT": ext,
      "DATA": selectPhoto ? base64Encode(File(myPhoto).readAsBytesSync()) : ""
    }).then((response) async {
      if (response.statusCode == 200) {
        var responsebody = response.body;
        print("Response=$responsebody");
        if (responsebody != "0") {
          Data.showSnack(msg: 'Spécialité Ajoutée ...', color: Colors.green);
          Navigator.of(context).pop();
        } else {
          setState(() {
            valider = false;
          });
          AwesomeDialog(
                  context: context,
                  dialogType: DialogType.ERROR,
                  showCloseIcon: true,
                  title: 'Erreur',
                  desc: "Probleme lors de l'ajout !!!")
              .show();
        }
      } else {
        setState(() {
          valider = false;
        });
        AwesomeDialog(
                context: context,
                dialogType: DialogType.ERROR,
                showCloseIcon: true,
                title: 'Erreur',
                desc: 'Probleme de Connexion avec le serveur !!!')
            .show();
      }
    }).catchError((error) {
      print("erreur : $error");
      setState(() {
        valider = false;
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

  pickPhoto() async {
    final ImagePicker picker = ImagePicker();
    final ximage = await picker.pickImage(source: ImageSource.gallery);
    if (ximage == null) return;
    setState(() {
      myPhoto = ximage.path;
      selectPhoto = true;
    });
  }
}
