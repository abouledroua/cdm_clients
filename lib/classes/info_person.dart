// ignore_for_file: avoid_print

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cdm_clients/classes/data.dart';
import 'package:cdm_clients/classes/person.dart';
import 'package:cdm_clients/fiches/fiche_person.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class InfoPerson extends StatefulWidget {
  final int idSpec;
  final Person personne;
  const InfoPerson({Key? key, required this.personne, required this.idSpec})
      : super(key: key);

  @override
  State<InfoPerson> createState() => _InfoPersonState();
}

class _InfoPersonState extends State<InfoPerson> {
  late int idSpecialite;
  late Person item;

  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized();
    item = widget.personne;
    Data.upData = false;
    idSpecialite = widget.idSpec;
    super.initState();
  }

  Widget makeDismissible({required Widget child}) => GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.of(context).pop(),
      child: GestureDetector(onTap: () {}, child: child));

  @override
  Widget build(BuildContext context) {
    return makeDismissible(
        child: DraggableScrollableSheet(
            initialChildSize: 0.5,
            minChildSize: 0.5,
            maxChildSize: 0.9,
            builder: (_, controller) => SafeArea(
                child: Container(
                    decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(25))),
                    padding: const EdgeInsets.all(10),
                    child: ListView(controller: controller, children: [
                      Text(item.nom.toUpperCase(),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.laila(
                              fontSize: 20, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.clip),
                      circularPhoto(),
                      Visibility(
                          visible: (item.adress != ""),
                          child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(children: [
                                const Icon(Icons.gps_fixed),
                                const SizedBox(width: 20),
                                Text(item.adress)
                              ]))),
                      Visibility(
                          visible: (item.tel != ""),
                          child: InkWell(
                              onTap: () =>
                                  Data.makeExternalRequest("tel:${item.tel}"),
                              child: Ink(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(children: [
                                    const Icon(Icons.phone,
                                        color: Colors.green),
                                    const SizedBox(width: 20),
                                    Text(item.tel,
                                        style: const TextStyle(
                                            color: Colors.green))
                                  ])))),
                      Visibility(
                          visible: (item.email != ""),
                          child: InkWell(
                              onTap: () {
                                final Uri params = Uri(
                                    scheme: 'mailto',
                                    path: item.email,
                                    query:
                                        'subject=App Feedback&body=App Version 3.23');
                                var url = params.toString();
                                Data.makeExternalRequest(url);
                              },
                              child: Ink(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(children: [
                                    const Icon(Icons.email_outlined,
                                        color: Colors.brown),
                                    const SizedBox(width: 20),
                                    Text(item.email,
                                        style: const TextStyle(
                                            color: Colors.brown))
                                  ])))),
                      Visibility(
                          visible: (item.facebook != ""),
                          child: InkWell(
                              onTap: () {
                                Data.makeExternalRequest(
                                    "https://facebook.com/${item.facebook}");
                              },
                              child: Ink(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(children: [
                                    Icon(Icons.facebook,
                                        color: Colors.blue.shade600),
                                    const SizedBox(width: 20),
                                    Text(item.facebook,
                                        style: const TextStyle(
                                            color: Color.fromARGB(
                                                255, 58, 63, 66)))
                                  ])))),
                      if (Data.isAdmin) const Divider(),
                      if (Data.isAdmin)
                        Wrap(alignment: WrapAlignment.spaceEvenly, children: [
                          ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                  primary: Colors.green,
                                  onPrimary: Colors.white),
                              onPressed: () {
                                var route = MaterialPageRoute(
                                    builder: (context) =>
                                        FichePerson(idPerson: item.id));
                                Navigator.of(context)
                                    .push(route)
                                    .then((value) => Navigator.pop(context));
                              },
                              icon: const Icon(Icons.edit),
                              label: const Text("Modifier")),
                          ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                  primary: Colors.red, onPrimary: Colors.white),
                              onPressed: () {
                                if (item.nbSpec == 0 || idSpecialite != 0) {
                                  if (idSpecialite != 0) {
                                    AwesomeDialog(
                                            context: context,
                                            dialogType: DialogType.QUESTION,
                                            showCloseIcon: true,
                                            btnOkText: "Oui",
                                            btnOkOnPress: () async {
                                              await deleteClientSpecialite();
                                            },
                                            btnCancelText: "Non",
                                            btnCancelOnPress: () {},
                                            title: '',
                                            desc:
                                                "Voulez vous vraiment supprimer ce client de cette spécialité ???")
                                        .show();
                                  } else {
                                    AwesomeDialog(
                                            context: context,
                                            dialogType: DialogType.QUESTION,
                                            showCloseIcon: true,
                                            btnOkText: "Oui",
                                            btnOkOnPress: () async {
                                              await deleteClient();
                                            },
                                            btnCancelText: "Non",
                                            btnCancelOnPress: () {},
                                            title: '',
                                            desc:
                                                "Voulez vous vraiment supprimer ce client ???")
                                        .show();
                                  }
                                } else {
                                  AwesomeDialog(
                                          context: context,
                                          dialogType: DialogType.ERROR,
                                          showCloseIcon: true,
                                          title: 'Erreur',
                                          desc:
                                              'Vous ne pouvez pas supprimer ce client !!!')
                                      .show();
                                }
                              },
                              icon: const Icon(Icons.delete),
                              label: const Text("Supprimer"))
                        ])
                    ])))));
  }

  deleteClient() async {
    String serverDir = Data.getServerDirectory();
    var url = "$serverDir/DELETE_PERSON.php";
    print(url);
    Uri myUri = Uri.parse(url);
    http
        .post(myUri, body: {"ID_PERSON": item.id.toString()})
        .timeout(Duration(seconds: Data.timeOut))
        .then((response) async {
          if (response.statusCode == 200) {
            var result = response.body;
            if (result != "0") {
              Data.showSnack(msg: 'Client supprimé ...', color: Colors.green);
              Data.upData = true;
              Navigator.of(context).pop();
            } else {
              AwesomeDialog(
                      context: context,
                      dialogType: DialogType.ERROR,
                      showCloseIcon: true,
                      title: 'Erreur',
                      desc: "Probleme lors de la suppression !!!")
                  .show();
            }
          } else {
            AwesomeDialog(
                    context: context,
                    dialogType: DialogType.ERROR,
                    showCloseIcon: true,
                    title: 'Erreur',
                    desc: 'Probleme de Connexion avec le serveur 5!!!')
                .show();
          }
        })
        .catchError((error) {
          print("erreur : $error");
          AwesomeDialog(
                  context: context,
                  dialogType: DialogType.ERROR,
                  showCloseIcon: true,
                  title: 'Erreur',
                  desc: 'Probleme de Connexion avec le serveur 6!!!')
              .show();
        });
  }

  deleteClientSpecialite() async {
    String serverDir = Data.getServerDirectory();
    var url = "$serverDir/DELETE_PERSON_SPECIALITE.php";
    print(url);
    Uri myUri = Uri.parse(url);
    http
        .post(myUri, body: {
          "ID_PERSON": item.id.toString(),
          "ID_SPECIALITE": idSpecialite.toString()
        })
        .timeout(Duration(seconds: Data.timeOut))
        .then((response) async {
          if (response.statusCode == 200) {
            var result = response.body;
            if (result != "0") {
              Data.showSnack(msg: 'Client supprimé ...', color: Colors.green);
              Data.upData = true;
              Navigator.of(context).pop();
            } else {
              AwesomeDialog(
                      context: context,
                      dialogType: DialogType.ERROR,
                      showCloseIcon: true,
                      title: 'Erreur',
                      desc: "Probleme lors de la suppression !!!")
                  .show();
            }
          } else {
            AwesomeDialog(
                    context: context,
                    dialogType: DialogType.ERROR,
                    showCloseIcon: true,
                    title: 'Erreur',
                    desc: 'Probleme de Connexion avec le serveur 5!!!')
                .show();
          }
        })
        .catchError((error) {
          print("erreur : $error");
          AwesomeDialog(
                  context: context,
                  dialogType: DialogType.ERROR,
                  showCloseIcon: true,
                  title: 'Erreur',
                  desc: 'Probleme de Connexion avec le serveur 6!!!')
              .show();
        });
  }

  Widget circularPhoto() {
    return Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        width: 130,
        height: 130,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(image: showPhoto(), fit: BoxFit.contain)));
  }

  showPhoto() {
    if (item.photo == "") {
      return const AssetImage("images/noPhoto.png");
    } else {
      return CachedNetworkImageProvider(Data.getImage(item.photo, "PERSON"));
    }
  }
}
