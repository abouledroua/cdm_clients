// ignore_for_file: avoid_print

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cdm_clients/classes/data.dart';
import 'package:cdm_clients/classes/specialite.dart';
import 'package:cdm_clients/fiches/fiche_specialite.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class InfoSpecialite extends StatefulWidget {
  final Specialite spec;
  const InfoSpecialite({Key? key, required this.spec}) : super(key: key);

  @override
  State<InfoSpecialite> createState() => _InfoSpecialiteState();
}

class _InfoSpecialiteState extends State<InfoSpecialite> {
  late int idSpecialite;
  late Specialite item;

  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized();
    item = widget.spec;
    Data.upData = false;
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
                      Text(item.designation.toUpperCase(),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.laila(
                              fontSize: 20, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.clip),
                      circularPhoto(),
                      Wrap(alignment: WrapAlignment.spaceEvenly, children: [
                        ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                                primary: Colors.green, onPrimary: Colors.white),
                            onPressed: () {
                              var route = MaterialPageRoute(
                                  builder: (context) =>
                                      FicheSpecialite(idSpecialite: item.id));
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
                              if (item.nbPersons == 0) {
                                AwesomeDialog(
                                        context: context,
                                        dialogType: DialogType.QUESTION,
                                        showCloseIcon: true,
                                        btnOkText: "Oui",
                                        btnOkOnPress: () async {
                                          await deleteSpecialite();
                                        },
                                        btnCancelText: "Non",
                                        btnCancelOnPress: () {},
                                        title: '',
                                        desc:
                                            "Voulez vous vraiment supprimer cette specialité ???")
                                    .show();
                              } else {
                                AwesomeDialog(
                                        context: context,
                                        dialogType: DialogType.ERROR,
                                        showCloseIcon: true,
                                        title: 'Erreur',
                                        desc:
                                            'Vous ne pouvez pas supprimer cette specialité !!!')
                                    .show();
                              }
                            },
                            icon: const Icon(Icons.delete),
                            label: const Text("Supprimer"))
                      ])
                    ])))));
  }

  deleteSpecialite() async {
    String serverDir = Data.getServerDirectory();
    var url = "$serverDir/DELETE_SPECIALITE.php";
    print(url);
    Uri myUri = Uri.parse(url);
    http
        .post(myUri, body: {"ID_SPECIALITE": item.id.toString()})
        .timeout(Duration(seconds: Data.timeOut))
        .then((response) async {
          if (response.statusCode == 200) {
            var result = response.body;
            if (result != "0") {
              Data.showSnack(
                  msg: 'Spécialité supprimée ...', color: Colors.green);
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
    if (item.image == "") {
      return const AssetImage("images/noPhoto.png");
    } else {
      return CachedNetworkImageProvider(
          Data.getImage(item.image, "SPECIALITE"));
    }
  }
}
