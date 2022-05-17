// ignore_for_file: avoid_print

import 'package:cdm_clients/Authentification/login.dart';
import 'package:cdm_clients/classes/data.dart';
import 'package:cdm_clients/classes/details_spec.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:awesome_dialog/awesome_dialog.dart';

class ListDetailSpecialite extends StatefulWidget {
  final int idSpecialite;
  final String desSpecialite;
  const ListDetailSpecialite(
      {Key? key, required this.idSpecialite, required this.desSpecialite})
      : super(key: key);

  @override
  State<ListDetailSpecialite> createState() => _ListDetailSpecialiteState();
}

class _ListDetailSpecialiteState extends State<ListDetailSpecialite> {
  late int idSpecialite;
  late String desSpecialite;
  bool loading = true, error = false;
  List<DetailsSpec> specs = [];

  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized(); //all widgets are rendered here
    idSpecialite = widget.idSpecialite;
    desSpecialite = widget.desSpecialite;
    getDetailSpecialite();
    super.initState();
  }

  getDetailSpecialite() async {
    setState(() {
      loading = true;
      error = false;
    });
    specs.clear();
    String serverDir = Data.getServerDirectory();
    var url = "$serverDir/GET_DETAILS_SPECIALITIES.php";
    print("url=$url");
    Uri myUri = Uri.parse(url);
    http
        .post(myUri, body: {"ID_SPECIALITE": idSpecialite.toString()})
        .timeout(Duration(seconds: Data.timeOut))
        .then((response) async {
          if (response.statusCode == 200) {
            var responsebody = jsonDecode(response.body);
            DetailsSpec e;
            for (var m in responsebody) {
              e = DetailsSpec(
                  adress: m['ADRESSE'],
                  photo: m['PHOTO'],
                  email: m['EMAIL'],
                  facebook: m['FACEBOOK'],
                  tel: m['TEL'],
                  nom: m['NOM'],
                  designation: m['DESIGNATION'],
                  idPerson: int.parse(m['ID_PERSON']),
                  idSpecialite: int.parse(m['ID_SPECIALITE']),
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
    return Scaffold(
        appBar: AppBar(title: Text(desSpecialite), centerTitle: true, actions: [
          !Data.isAdmin
              ? TextButton.icon(
                  label: const Text("Connecter",
                      style: TextStyle(color: Colors.white)),
                  onPressed: () {
                    var route =
                        MaterialPageRoute(builder: (context) => const Login());
                    Navigator.of(context)
                        .push(route)
                        .then((value) => setState(() {}));
                  },
                  icon: const Icon(Icons.assignment_ind_outlined,
                      color: Colors.white))
              : TextButton.icon(
                  label: const Text("Déconnecter",
                      style: TextStyle(color: Colors.white)),
                  onPressed: () {
                    setState(() {
                      Data.isAdmin = false;
                    });
                  },
                  icon: const Icon(Icons.person_off_outlined,
                      color: Colors.white))
        ]),
        floatingActionButton: !Data.isAdmin
            ? null
            : FloatingActionButton(
                child: const Icon(Icons.add), onPressed: () {}),
        body: ListView.builder(
            itemCount: specs.length,
            itemBuilder: (context, i) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Card(
                    elevation: 8,
                    child: ListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 6),
                        minLeadingWidth: 0,
                        leading: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 3),
                            child: SizedBox(
                                width: 60,
                                child: (specs[i].photo == "")
                                    ? Image.asset("images/noPhoto.png")
                                    : CachedNetworkImage(
                                        errorWidget: (context, url, error) =>
                                            const Icon(Icons.error),
                                        fit: BoxFit.contain,
                                        placeholder: (context, url) => Center(
                                            child: CircularProgressIndicator(
                                                color: Data.darkColor[
                                                    Random().nextInt(Data.darkColor.length - 1) +
                                                        1])),
                                        imageUrl: Data.getImage(
                                            specs[i].photo, "PERSON")))),
                        title: Text(specs[i].nom, style: const TextStyle(fontWeight: FontWeight.bold)),
                        trailing: Visibility(
                            visible: specs[i].tel.isNotEmpty,
                            child: Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, children: [
                              Text(specs[i].tel,
                                  style: const TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(width: 10),
                              InkWell(
                                  onTap: () => Data.makeExternalRequest(
                                      "tel:${specs[i].tel}"),
                                  child: const Icon(Icons.call,
                                      color: Colors.green))
                            ])),
                        subtitle: Column(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [
                          if (specs[i].email.isNotEmpty)
                            Row(children: [
                              const Icon(Icons.email,
                                  color: Color.fromARGB(255, 110, 80, 35)),
                              const SizedBox(width: 5),
                              Text(specs[i].email,
                                  style: const TextStyle(
                                      color: Color.fromARGB(255, 110, 80, 35))),
                              const SizedBox(width: 20)
                            ]),
                          if (specs[i].adress.isNotEmpty)
                            Row(children: [
                              const Icon(Icons.home, color: Colors.black54),
                              const SizedBox(width: 5),
                              Text(specs[i].adress,
                                  style:
                                      const TextStyle(color: Colors.black54)),
                              const SizedBox(width: 20)
                            ]),
                          if (specs[i].facebook.isNotEmpty)
                            Row(children: [
                              const Icon(Icons.facebook,
                                  color: Color.fromARGB(255, 20, 39, 146)),
                              const SizedBox(width: 5),
                              Text(specs[i].facebook,
                                  style: const TextStyle(
                                      color: Color.fromARGB(255, 20, 39, 146)))
                            ])
                        ]))))));
  }
}
