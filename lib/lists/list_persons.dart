// ignore_for_file: avoid_print

import 'package:cdm_clients/classes/data.dart';
import 'package:cdm_clients/classes/info_person.dart';
import 'package:cdm_clients/classes/person.dart';
import 'package:cdm_clients/fiches/fiche_person.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cdm_clients/Authentification/login.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:awesome_dialog/awesome_dialog.dart';

class ListPersons extends StatefulWidget {
  const ListPersons({Key? key}) : super(key: key);

  @override
  State<ListPersons> createState() => _ListPersonsState();
}

class _ListPersonsState extends State<ListPersons> {
  bool loading = true, error = false;
  List<Person> persons = [];
  TextEditingController txtRecherche = TextEditingController(text: "");

  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized(); //all widgets are rendered here
    getListPersons();
    super.initState();
  }

  getListPersons() async {
    setState(() {
      loading = true;
      error = false;
    });
    persons.clear();
    String serverDir = Data.getServerDirectory();
    var url = "$serverDir/GET_PERSONS.php";
    print("url=$url");
    Uri myUri = Uri.parse(url);
    http
        .post(myUri, body: {})
        .timeout(Duration(seconds: Data.timeOut))
        .then((response) async {
          if (response.statusCode == 200) {
            var responsebody = jsonDecode(response.body);
            Person e;
            for (var m in responsebody) {
              e = Person(
                  nom: m['NOM'],
                  email: m['EMAIL'],
                  facebook: m['FACEBOOK'],
                  tel: m['TEL'],
                  photo: m['PHOTO'],
                  etat: int.parse(m['ETAT']),
                  id: int.parse(m['ID_PERSON']),
                  nbSpec: int.parse(m['NB']),
                  adress: m['ADRESSE']);
              persons.add(e);
            }
            setState(() {
              loading = false;
            });
          } else {
            setState(() {
              persons.clear();
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
            persons.clear();
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
            child: Scaffold(
                resizeToAvoidBottomInset: true,
                endDrawer: Drawer(
                    child: SafeArea(
                        child: Material(
                            color: const Color.fromARGB(255, 32, 99, 162),
                            child: Column(children: [
                              const SizedBox(height: 16),
                              ListTile(
                                  onTap: () {
                                    getListPersons();
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
                                      style:
                                          const TextStyle(color: Colors.white)),
                                  leading: Icon(
                                      !Data.isAdmin
                                          ? Icons.login
                                          : Icons.logout,
                                      color: Colors.white))
                            ])))),
                appBar: AppBar(
                    centerTitle: true,
                    title:
                        Text("Liste des Clients", style: GoogleFonts.laila()),
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
                                  const FichePerson(idPerson: 0));
                          Navigator.of(context)
                              .push(route)
                              .then((value) => getListPersons());
                        }),
                body: loading
                    ? const Center(child: CircularProgressIndicator.adaptive())
                    : bodyContent(minSize))));
  }

  Widget bodyContent(double minSize) => Center(
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
                        borderSide:
                            BorderSide(color: Colors.transparent, width: 2.0)),
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
                child: ListView(shrinkWrap: true, primary: true, children: [
              Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                      child: Wrap(
                          spacing: 32,
                          runSpacing: 32,
                          children: persons
                              .map((item) {
                                return Material(
                                    elevation: 8,
                                    color: item.etat == 1
                                        ? Colors.blue
                                        : Colors.grey,
                                    borderRadius: BorderRadius.circular(28),
                                    clipBehavior: Clip.antiAliasWithSaveLayer,
                                    child: Visibility(
                                        visible: (Data.isAdmin ||
                                                item.etat == 1) &&
                                            (txtRecherche.text.isEmpty ||
                                                item.nom.toUpperCase().contains(
                                                    txtRecherche.text
                                                        .toUpperCase())),
                                        child: Container(
                                            color: item.etat == 1
                                                ? Colors.transparent
                                                : Colors.grey.shade300
                                                    .withOpacity(0.5),
                                            child: InkWell(
                                                onTap: () {
                                                  print("click on ${item.nom}");
                                                  showModalBottomSheet(
                                                      context: context,
                                                      elevation: 5,
                                                      enableDrag: true,
                                                      isScrollControlled: true,
                                                      backgroundColor:
                                                          Colors.transparent,
                                                      builder: (context) {
                                                        return InfoPerson(
                                                            personne: item);
                                                      }).then((value) {
                                                    getListPersons();
                                                  });
                                                },
                                                splashColor: Colors.black26,
                                                child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      item.photo.isEmpty
                                                          ? Ink.image(
                                                              height: minSize,
                                                              width: minSize,
                                                              fit: BoxFit.cover,
                                                              image: const AssetImage(
                                                                  "images/noPhoto.png"))
                                                          : Ink.image(
                                                              height: minSize,
                                                              width: minSize,
                                                              fit: BoxFit.cover,
                                                              image: CachedNetworkImageProvider(
                                                                  Data.getImage(
                                                                      item.photo,
                                                                      "PERSON"))),
                                                      const SizedBox(height: 6),
                                                      SizedBox(
                                                          width: minSize,
                                                          child: Text(item.nom,
                                                              overflow:
                                                                  TextOverflow
                                                                      .clip,
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: GoogleFonts.laila(
                                                                  fontSize: 16,
                                                                  color: Colors
                                                                      .white))),
                                                      const SizedBox(height: 6)
                                                    ])))));
                              })
                              .toList()
                              .cast<Widget>())))
            ]))
          ])));
}
