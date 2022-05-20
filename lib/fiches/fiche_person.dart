// ignore_for_file: avoid_print, depend_on_referenced_packages

import 'dart:io';
import 'dart:math';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cdm_clients/classes/data.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:path/path.dart' as p;

class FichePerson extends StatefulWidget {
  final int idPerson;
  const FichePerson({Key? key, required this.idPerson}) : super(key: key);

  @override
  State<FichePerson> createState() => _FichePersonState();
}

class _FichePersonState extends State<FichePerson> {
  late int idPerson;
  bool loading = false,
      valNom = false,
      valTel = false,
      valider = false,
      valAdresse = false,
      isSwitched = true,
      selectPhoto = false;
  TextEditingController txtNom = TextEditingController(text: "");
  TextEditingController txtTel = TextEditingController(text: "");
  TextEditingController txtAdresse = TextEditingController(text: "");
  TextEditingController txtEmail = TextEditingController(text: "");
  TextEditingController txtFacebook = TextEditingController(text: "");
  String myPhoto = "";
  final picker = ImagePicker();
  FocusNode focusNode = FocusNode();

  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized(); //all widgets are rendered here
    idPerson = widget.idPerson;
    loading = false;
    valider = false;
    Data.upData = false;
    myPhoto = "";
    selectPhoto = false;
    getPersonInfo();
    if (idPerson == 0) {
      setState(() {
        loading = false;
      });
    }
    super.initState();
  }

  getPersonInfo() async {
    setState(() {
      loading = true;
    });
    String serverDir = Data.getServerDirectory();
    var url = "$serverDir/GET_INFO_PERSON.php";
    print("url=$url");
    Uri myUri = Uri.parse(url);
    http
        .post(myUri, body: {"ID_PERSON": idPerson.toString()})
        .timeout(Duration(seconds: Data.timeOut))
        .then((response) async {
          if (response.statusCode == 200) {
            var responsebody = jsonDecode(response.body);
            for (var m in responsebody) {
              txtNom.text = m['NOM'];
              txtAdresse.text = m['ADRESSE'];
              txtEmail.text = m['EMAIL'];
              txtFacebook.text = m['FACEBOOK'];
              txtTel.text = m['TEL'];
              myPhoto = m['PHOTO'];
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
            appBar: AppBar(
                title: Text("Fiche Client", style: GoogleFonts.laila()),
                centerTitle: true),
            body: loading
                ? const Center(child: CircularProgressIndicator.adaptive())
                : bodyContent(minSize)));
  }

  Widget bodyContent(double minSize) => valider
      ? Center(
          child:
              Row(mainAxisAlignment: MainAxisAlignment.center, children: const [
          Text("Validation en cours ..."),
          SizedBox(width: 10),
          CircularProgressIndicator.adaptive()
        ]))
      : ListView(children: [
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
                                        const AssetImage("images/noPhoto.png"))
                                : Ink.image(
                                    height: minSize,
                                    width: minSize,
                                    fit: BoxFit.cover,
                                    image: NetworkImage(
                                        Data.getImage(myPhoto, "PERSON")))
                      ])))),
          Padding(
              padding: const EdgeInsets.only(left: 10, right: 10, top: 30),
              child: TextField(
                  autofocus: true,
                  focusNode: focusNode,
                  enabled: !valider,
                  controller: txtNom,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.text,
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                  decoration: InputDecoration(
                      errorText: valNom ? 'Champs Obligatoire' : null,
                      prefixIcon: const Padding(
                          padding: EdgeInsets.only(right: 4),
                          child: Icon(Icons.supervised_user_circle_outlined,
                              color: Colors.black)),
                      contentPadding: const EdgeInsets.only(bottom: 3),
                      labelText: "Nom",
                      labelStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                      hintText: "Nom",
                      hintStyle:
                          const TextStyle(fontSize: 14, color: Colors.grey),
                      floatingLabelBehavior: FloatingLabelBehavior.always))),
          Padding(
              padding: const EdgeInsets.only(left: 10, right: 10, top: 30),
              child: TextField(
                  enabled: !valider,
                  controller: txtTel,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.phone,
                  style: TextStyle(fontSize: 16, color: Colors.green.shade600),
                  decoration: InputDecoration(
                      errorText: valTel ? 'Champs Obligatoire' : null,
                      prefixIcon: Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child:
                              Icon(Icons.phone, color: Colors.green.shade600)),
                      contentPadding: const EdgeInsets.only(bottom: 3),
                      labelText: "Télephone",
                      labelStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade600),
                      hintText: "Télephone",
                      hintStyle:
                          const TextStyle(fontSize: 14, color: Colors.grey),
                      floatingLabelBehavior: FloatingLabelBehavior.always))),
          Padding(
              padding: const EdgeInsets.only(left: 10, right: 10, top: 30),
              child: TextField(
                  enabled: !valider,
                  controller: txtAdresse,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.text,
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                  decoration: InputDecoration(
                      errorText: valAdresse ? 'Champs Obligatoire' : null,
                      prefixIcon: const Padding(
                          padding: EdgeInsets.only(right: 4),
                          child: Icon(Icons.gps_fixed, color: Colors.black)),
                      contentPadding: const EdgeInsets.only(bottom: 3),
                      labelText: "Adresse",
                      labelStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                      hintText: "Adresse",
                      hintStyle:
                          const TextStyle(fontSize: 14, color: Colors.grey),
                      floatingLabelBehavior: FloatingLabelBehavior.always))),
          Padding(
              padding: const EdgeInsets.only(left: 10, right: 10, top: 30),
              child: TextField(
                  enabled: !valider,
                  controller: txtEmail,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(fontSize: 16, color: Colors.brown),
                  decoration: const InputDecoration(
                      prefixIcon: Padding(
                          padding: EdgeInsets.only(right: 4),
                          child:
                              Icon(Icons.email_outlined, color: Colors.brown)),
                      contentPadding: EdgeInsets.only(bottom: 3),
                      labelText: "Email",
                      labelStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.brown),
                      hintText: "Email",
                      hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
                      floatingLabelBehavior: FloatingLabelBehavior.always))),
          Padding(
              padding: const EdgeInsets.only(left: 10, right: 10, top: 30),
              child: TextField(
                  enabled: !valider,
                  controller: txtFacebook,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.text,
                  style: TextStyle(fontSize: 16, color: Colors.blue.shade600),
                  decoration: InputDecoration(
                      prefixIcon: Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Icon(Icons.supervised_user_circle_outlined,
                              color: Colors.blue.shade600)),
                      contentPadding: const EdgeInsets.only(bottom: 3),
                      labelText: "Facebook",
                      labelStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade600),
                      hintText: "Facebook",
                      hintStyle:
                          const TextStyle(fontSize: 14, color: Colors.grey),
                      floatingLabelBehavior: FloatingLabelBehavior.always))),
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
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(20)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                child: TextButton.icon(
                    onPressed: fnValider,
                    icon:
                        const Icon(Icons.verified_rounded, color: Colors.white),
                    label: const Text("Valider",
                        style: TextStyle(color: Colors.white)))),
            const Spacer(flex: 1),
            Container(
                decoration: BoxDecoration(
                    color: Colors.red, borderRadius: BorderRadius.circular(20)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                    icon:
                        const Icon(Icons.cancel_outlined, color: Colors.white),
                    label: const Text("Annuler",
                        style: TextStyle(color: Colors.white)))),
            const Spacer(flex: 2)
          ]),
          const SizedBox(height: 16)
        ]);

  fnValider() async {
    bool continuer = true;
    setState(() {
      valider = true;
      valAdresse = txtAdresse.text.isEmpty;
      valNom = txtNom.text.isEmpty;
      valTel = txtTel.text.isEmpty;
    });
    if (valAdresse || valNom || valTel) {
      AwesomeDialog(
              context: context,
              dialogType: DialogType.ERROR,
              showCloseIcon: true,
              title: 'Erreur',
              desc: 'Veuillez saisir les champs obligatoire !!!')
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
      existPerson();
    } else {
      setState(() {
        valider = false;
      });
    }
  }

  existPerson() async {
    String serverDir = Data.getServerDirectory();
    var url = "$serverDir/EXIST_PERSON.php";
    print(url);
    Uri myUri = Uri.parse(url);
    http
        .post(myUri, body: {
          "NOM": txtNom.text,
          "ID_PERSON": idPerson.toString(),
        })
        .timeout(Duration(seconds: Data.timeOut))
        .then((response) async {
          if (response.statusCode == 200) {
            var responsebody = jsonDecode(response.body);
            int result = 0;
            for (var m in responsebody) {
              result = int.parse(m['ID_PERSON']);
            }
            if (result == 0) {
              if (idPerson == 0) {
                insertPerson();
              } else {
                updatePerson();
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
                  desc: "Ce Client existe déjà !!!");
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

  updatePerson() async {
    String serverDir = Data.getServerDirectory();
    var url = "$serverDir/UPDATE_PERSON.php";
    print(url);
    int petat = isSwitched ? 1 : 2;
    String ext = selectPhoto ? p.extension(myPhoto) : "";
    String data =
        selectPhoto ? base64Encode(File(myPhoto).readAsBytesSync()) : "";
    Uri myUri = Uri.parse(url);
    http.post(myUri, body: {
      "ID_PERSON": idPerson.toString(),
      "NOM": txtNom.text.toUpperCase(),
      "TEL": txtTel.text.toUpperCase(),
      "ADRESSE": txtAdresse.text.toUpperCase(),
      "EMAIL": txtEmail.text.toUpperCase(),
      "FACEBOOK": txtFacebook.text.toUpperCase(),
      "ETAT": petat.toString(),
      "EXT": ext,
      "DATA": data
    }).then((response) async {
      if (response.statusCode == 200) {
        var responsebody = response.body;
        print("Response=$responsebody");
        if (responsebody != "0") {
          Data.showSnack(
              msg: 'Information mis à jours ...', color: Colors.green);
          Data.upData = true;
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

  insertPerson() async {
    String serverDir = Data.getServerDirectory();
    var url = "$serverDir/INSERT_PERSON.php";
    print(url);
    int petat = isSwitched ? 1 : 2;
    Uri myUri = Uri.parse(url);
    String ext = selectPhoto ? p.extension(myPhoto) : "";
    String data =
        selectPhoto ? base64Encode(File(myPhoto).readAsBytesSync()) : "";
    http.post(myUri, body: {
      "NOM": txtNom.text.toUpperCase(),
      "TEL": txtTel.text.toUpperCase(),
      "ADRESSE": txtAdresse.text.toUpperCase(),
      "EMAIL": txtEmail.text.toUpperCase(),
      "FACEBOOK": txtFacebook.text.toUpperCase(),
      "ETAT": petat.toString(),
      "EXT": ext,
      "DATA": data
    }).then((response) async {
      if (response.statusCode == 200) {
        var responsebody = response.body;
        print("Response=$responsebody");
        if (responsebody != "0") {
          Data.showSnack(msg: 'Client Ajouté ...', color: Colors.green);
          Data.upData = true;
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
