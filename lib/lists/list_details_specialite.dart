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
  TextEditingController txtRecherche = TextEditingController(text: "");

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
    Data.myContext = context;
    Data.setSizeScreen(context);
    return SafeArea(
        child: Scaffold(
            endDrawer: Drawer(
                child: SafeArea(
                    child: Material(
                        color: const Color.fromARGB(255, 32, 99, 162),
                        child: Column(children: [
                          const SizedBox(height: 16),
                          ListTile(
                              onTap: () {
                                getDetailSpecialite();
                                Navigator.pop(context);
                              },
                              title: const Text('Actualiser',
                                  style: TextStyle(color: Colors.white)),
                              leading: const Icon(Icons.refresh,
                                  color: Colors.white)),
                          const SizedBox(height: 8),
                          const Divider(color: Colors.white),
                          const SizedBox(height: 8),
                          ListTile(
                              onTap: () {
                                if (!Data.isAdmin) {
                                  var route = MaterialPageRoute(
                                      builder: (context) => const Login());
                                  Navigator.of(context)
                                      .push(route)
                                      .then((value) {
                                    Navigator.pop(context);
                                  });
                                } else {
                                  AwesomeDialog(
                                          context: context,
                                          dialogType: DialogType.QUESTION,
                                          showCloseIcon: true,
                                          btnOkText: "Oui",
                                          btnOkOnPress: () {
                                            Data.isAdmin = false;
                                            Navigator.of(context)
                                                .pushNamedAndRemoveUntil(
                                                    'ListSpecialite',
                                                    (Route<dynamic> route) =>
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
                                  !Data.isAdmin ? 'Connecter' : 'Déonnecter',
                                  style: const TextStyle(color: Colors.white)),
                              leading: Icon(
                                  !Data.isAdmin ? Icons.login : Icons.logout,
                                  color: Colors.white))
                        ])))),
            appBar: AppBar(title: Text(desSpecialite), centerTitle: true),
            floatingActionButton: !Data.isAdmin
                ? null
                : FloatingActionButton(
                    child: const Icon(Icons.add), onPressed: () {}),
            body: loading
                ? const Center(child: CircularProgressIndicator.adaptive())
                : bodyContent()));
  }

  Widget bodyContent() => specs.isEmpty
      ? Center(
          child: Container(
              constraints: BoxConstraints(maxWidth: Data.maxWidth),
              padding: const EdgeInsets.all(8.0),
              width: double.infinity,
              child: const FittedBox(
                  child:
                      Text("Aucune Personne inscrit dans cette spécialité"))))
      : Center(
          child: Container(
              padding: const EdgeInsets.all(8.0),
              constraints: BoxConstraints(maxWidth: Data.maxWidth),
              child: Column(children: [
                TextField(
                    onChanged: (value) {
                      if (!loading) {
                        setState(() {});
                      }
                    },
                    autofocus: true,
                    maxLines: 1,
                    controller: txtRecherche,
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.text,
                    style: const TextStyle(fontSize: 16, color: Colors.black),
                    decoration: InputDecoration(
                        focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.transparent, width: 2.0)),
                        fillColor: Colors.grey.withOpacity(0.2),
                        filled: true,
                        prefixIcon: const Padding(
                            padding: EdgeInsets.only(right: 4),
                            child: Icon(Icons.search, color: Colors.black)),
                        contentPadding: const EdgeInsets.only(bottom: 3),
                        labelStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                        hintText: "Recherche",
                        hintStyle:
                            const TextStyle(fontSize: 14, color: Colors.grey),
                        floatingLabelBehavior: FloatingLabelBehavior.always)),
                Expanded(
                    child: ListView.builder(
                        shrinkWrap: true,
                        primary: true,
                        itemCount: specs.length,
                        itemBuilder: (context, i) => !(txtRecherche
                                    .text.isEmpty ||
                                specs[i]
                                    .nom
                                    .toUpperCase()
                                    .contains(txtRecherche.text.toUpperCase()))
                            ? Container()
                            : Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 3),
                                child: Card(
                                    elevation: 8,
                                    child: ListTile(
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 6),
                                        leading: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 3),
                                            child: SizedBox(
                                                width: 60,
                                                child: (specs[i].photo == "")
                                                    ? Image.asset(
                                                        "images/noPhoto.png")
                                                    : CachedNetworkImage(
                                                        errorWidget: (context,
                                                                url, error) =>
                                                            const Icon(Icons.error),
                                                        fit: BoxFit.contain,
                                                        placeholder: (context, url) => Center(child: CircularProgressIndicator(color: Data.darkColor[Random().nextInt(Data.darkColor.length - 1) + 1])),
                                                        imageUrl: Data.getImage(specs[i].photo, "PERSON")))),
                                        title: Padding(padding: const EdgeInsets.only(bottom: 8.0), child: Text(specs[i].nom, style: const TextStyle(fontWeight: FontWeight.bold))),
                                        subtitle: Column(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [
                                          if (specs[i].tel.isNotEmpty)
                                            Row(children: [
                                              const Icon(Icons.phone,
                                                  color: Colors.green),
                                              const SizedBox(width: 5),
                                              Text(specs[i].tel,
                                                  style: const TextStyle(
                                                      color: Colors.green)),
                                              const SizedBox(width: 20)
                                            ]),
                                          if (specs[i].email.isNotEmpty)
                                            Row(children: [
                                              const Icon(Icons.email,
                                                  color: Color.fromARGB(
                                                      255, 110, 80, 35)),
                                              const SizedBox(width: 5),
                                              Text(specs[i].email,
                                                  style: const TextStyle(
                                                      color: Color.fromARGB(
                                                          255, 110, 80, 35))),
                                              const SizedBox(width: 20)
                                            ]),
                                          if (specs[i].adress.isNotEmpty)
                                            Row(children: [
                                              const Icon(Icons.home,
                                                  color: Colors.black54),
                                              const SizedBox(width: 5),
                                              Text(specs[i].adress,
                                                  style: const TextStyle(
                                                      color: Colors.black54)),
                                              const SizedBox(width: 20)
                                            ]),
                                          if (specs[i].facebook.isNotEmpty)
                                            Row(children: [
                                              const Icon(Icons.facebook,
                                                  color: Color.fromARGB(
                                                      255, 20, 39, 146)),
                                              const SizedBox(width: 5),
                                              Text(specs[i].facebook,
                                                  style: const TextStyle(
                                                      color: Color.fromARGB(
                                                          255, 20, 39, 146)))
                                            ])
                                        ]))))))
              ])));
}
