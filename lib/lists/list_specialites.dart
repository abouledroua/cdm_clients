// ignore_for_file: avoid_print

import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cdm_clients/Authentification/login.dart';
import 'package:cdm_clients/classes/data.dart';
import 'package:cdm_clients/classes/specialite.dart';
import 'package:cdm_clients/fiches/fiche_specialite.dart';
import 'package:cdm_clients/lists/list_details_specialite.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:awesome_dialog/awesome_dialog.dart';

class ListSpecialite extends StatefulWidget {
  const ListSpecialite({Key? key}) : super(key: key);

  @override
  State<ListSpecialite> createState() => _ListSpecialiteState();
}

class _ListSpecialiteState extends State<ListSpecialite> {
  bool loading = true, error = false;
  List<Specialite> specs = [];

  Future<bool> _onWillPop() async {
    if (Data.isAdmin) {
      return true;
    } else {
      return (await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                      title: Row(children: const [
                        Icon(Icons.exit_to_app_sharp, color: Colors.red),
                        Padding(
                            padding: EdgeInsets.only(left: 8.0),
                            child: Text('Etes-vous sur ?'))
                      ]),
                      content: const Text(
                          "Voulez-vous vraiment quitter l'application ?"),
                      actions: <Widget>[
                        TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Non',
                                style: TextStyle(color: Colors.red))),
                        TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text('Oui',
                                style: TextStyle(color: Colors.green)))
                      ]))) ??
          false;
    }
  }

  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized(); //all widgets are rendered here
    getListSpecialite();
    super.initState();
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
                  etat: int.parse(m['ETAT']),
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
    Data.myContext = context;
    Data.setSizeScreen(context);
    double minSize = min(Data.heightScreen, Data.widthScreen) / 2;
    return GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SafeArea(
            child: WillPopScope(
                onWillPop: _onWillPop,
                child: Scaffold(
                    endDrawer: Drawer(
                        child: SafeArea(
                            child: Material(
                                color: const Color.fromARGB(255, 32, 99, 162),
                                child: Column(children: [
                                  const SizedBox(height: 16),
                                  ListTile(
                                      onTap: () {
                                        getListSpecialite();
                                        Navigator.pop(context);
                                      },
                                      title: const Text('Actualiser',
                                          style:
                                              TextStyle(color: Colors.white)),
                                      leading: const Icon(Icons.refresh,
                                          color: Colors.white)),
                                  const SizedBox(height: 8),
                                  const Divider(color: Colors.white),
                                  const SizedBox(height: 8),
                                  ListTile(
                                      onTap: () {
                                        if (!Data.isAdmin) {
                                          var route = MaterialPageRoute(
                                              builder: (context) =>
                                                  const Login());
                                          Navigator.of(context)
                                              .push(route)
                                              .then((value) {
                                            Navigator.pop(context);
                                          });
                                        } else {
                                          AwesomeDialog(
                                                  context: context,
                                                  dialogType:
                                                      DialogType.QUESTION,
                                                  showCloseIcon: true,
                                                  btnOkText: "Oui",
                                                  btnOkOnPress: () {
                                                    Data.isAdmin = false;
                                                    Navigator.of(context)
                                                        .pushNamedAndRemoveUntil(
                                                            'ListSpecialite',
                                                            (Route<dynamic>
                                                                    route) =>
                                                                false);
                                                  },
                                                  btnCancelText: "Non",
                                                  btnCancelOnPress: () {},
                                                  title: '',
                                                  desc:
                                                      "Voulez vous vraiment déconnecter ???")
                                              .show();
                                        }
                                      },
                                      title: Text(
                                          !Data.isAdmin
                                              ? 'Connecter'
                                              : 'Déonnecter',
                                          style: const TextStyle(
                                              color: Colors.white)),
                                      leading: Icon(
                                          !Data.isAdmin
                                              ? Icons.login
                                              : Icons.logout,
                                          color: Colors.white))
                                ])))),
                    appBar: AppBar(
                        centerTitle: true,
                        title: Text("Spécialités", style: GoogleFonts.laila()),
                        leading: Navigator.canPop(context)
                            ? IconButton(
                                onPressed: () {
                                  if (Navigator.canPop(context)) {
                                    Navigator.pop(context);
                                  }
                                },
                                icon: const Icon(Icons.arrow_back))
                            : null),
                    floatingActionButton: !Data.isAdmin
                        ? null
                        : FloatingActionButton(
                            child: const Icon(Icons.add),
                            onPressed: () {
                              var route = MaterialPageRoute(
                                  builder: (context) =>
                                      const FicheSpecialite(idSpecialite: 0));
                              Navigator.of(context)
                                  .push(route)
                                  .then((value) => getListSpecialite());
                            }),
                    body: loading
                        ? const Center(
                            child: CircularProgressIndicator.adaptive())
                        : bodyContent(minSize)))));
  }

  updateEtatSpecialite({required int idSpecialite, required int pEtat}) async {
    String serverDir = Data.getServerDirectory();
    var url = "$serverDir/UPDATE_ETAT_SPECIALITE.php";
    print(url);
    Uri myUri = Uri.parse(url);
    http.post(myUri, body: {
      "ID_SPECIALITE": idSpecialite.toString(),
      "ETAT": pEtat.toString()
    }).then((response) async {
      if (response.statusCode == 200) {
        var responsebody = response.body;
        print("Response=$responsebody");
        if (responsebody != "0") {
          Data.showSnack(
              msg: 'Information mis à jours ...', color: Colors.green);
          getListSpecialite();
        } else {
          setState(() {});
          AwesomeDialog(
                  context: context,
                  dialogType: DialogType.ERROR,
                  showCloseIcon: true,
                  title: 'Erreur',
                  desc: 'Probleme lors de la mise a jour des informations !!!')
              .show();
        }
      } else {
        setState(() {});
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
      setState(() {});
      AwesomeDialog(
              context: context,
              dialogType: DialogType.ERROR,
              showCloseIcon: true,
              title: 'Erreur',
              desc: 'Probleme de Connexion avec le serveur !!!')
          .show();
    });
  }

  ListView bodyContent(double minSize) => ListView(children: [
        Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
                child: Wrap(
                    spacing: 32,
                    runSpacing: 32,
                    children: specs
                        .map((item) {
                          return Material(
                              elevation: 8,
                              color: item.etat == 1 ? Colors.blue : Colors.grey,
                              borderRadius: BorderRadius.circular(28),
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              child: Visibility(
                                  visible: Data.isAdmin || item.etat == 1,
                                  child: Container(
                                      color: item.etat == 1
                                          ? Colors.transparent
                                          : Colors.grey.shade300
                                              .withOpacity(0.5),
                                      child: InkWell(
                                          onTap: () {
                                            print(
                                                "click on ${item.designation}");
                                            var route = MaterialPageRoute(
                                                builder: (context) =>
                                                    ListDetailSpecialite(
                                                        idSpecialite: item.id,
                                                        desSpecialite:
                                                            item.designation));
                                            Navigator.of(context)
                                                .push(route)
                                                .then(
                                                    (value) => setState(() {}));
                                          },
                                          splashColor: Colors.black26,
                                          child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                item.image.isEmpty
                                                    ? Ink.image(
                                                        height: minSize,
                                                        width: minSize,
                                                        fit: BoxFit.cover,
                                                        image: const AssetImage(
                                                            "images/noImages.jpg"))
                                                    : Ink.image(
                                                        height: minSize,
                                                        width: minSize,
                                                        fit: BoxFit.cover,
                                                        image: CachedNetworkImageProvider(
                                                            Data.getImage(
                                                                item.image,
                                                                "SPECIALITE"))),
                                                const SizedBox(height: 6),
                                                SizedBox(
                                                    width: minSize,
                                                    child: Row(children: [
                                                      if (!Data.isAdmin)
                                                        const Spacer(),
                                                      if (Data.isAdmin)
                                                        const SizedBox(
                                                            width: 6),
                                                      Text(item.designation,
                                                          textAlign:
                                                              TextAlign.center,
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 16,
                                                                  color: Colors
                                                                      .white)),
                                                      const Spacer(),
                                                      if (Data.isAdmin)
                                                        Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .end,
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              IconButton(
                                                                  onPressed:
                                                                      () {
                                                                    var route = MaterialPageRoute(
                                                                        builder:
                                                                            (context) =>
                                                                                FicheSpecialite(idSpecialite: item.id));
                                                                    Navigator.of(
                                                                            context)
                                                                        .push(
                                                                            route)
                                                                        .then((value) =>
                                                                            getListSpecialite());
                                                                  },
                                                                  icon: const Icon(
                                                                      Icons
                                                                          .edit,
                                                                      color: Colors
                                                                          .white)),
                                                              const SizedBox(
                                                                  width: 6),
                                                              IconButton(
                                                                  onPressed:
                                                                      () {
                                                                    AwesomeDialog(
                                                                            context:
                                                                                context,
                                                                            dialogType: DialogType
                                                                                .QUESTION,
                                                                            showCloseIcon:
                                                                                true,
                                                                            btnOkText:
                                                                                "Oui",
                                                                            btnOkOnPress:
                                                                                () {
                                                                              updateEtatSpecialite(idSpecialite: item.id, pEtat: item.etat == 1 ? 0 : 1);
                                                                            },
                                                                            btnCancelText:
                                                                                "Non",
                                                                            btnCancelOnPress:
                                                                                () {},
                                                                            title:
                                                                                '',
                                                                            desc: item.etat == 1
                                                                                ? "Voulez vous vraiment cacher cette specialité ???"
                                                                                : "Voulez vous vraiment afficher cette specialité ???")
                                                                        .show();
                                                                  },
                                                                  icon: Icon(
                                                                      item.etat == 1
                                                                          ? Icons
                                                                              .visibility_off_outlined
                                                                          : Icons
                                                                              .remove_red_eye_outlined,
                                                                      color: Colors
                                                                          .red))
                                                            ])
                                                    ])),
                                                const SizedBox(height: 6)
                                              ])))));
                        })
                        .toList()
                        .cast<Widget>())))
      ]);
}
