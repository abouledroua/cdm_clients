import 'package:cdm_clients/classes/data.dart';
import 'package:cdm_clients/classes/details_spec.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cdm_clients/lists/list_details_specialite.dart';
import 'package:flutter/material.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: Text(desSpecialite),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: specs.length,
        itemBuilder: (context, i) => Card(
          elevation: 8,
          child: ListTile(
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
                                    color: Data.darkColor[Random().nextInt(
                                            Data.darkColor.length - 1) +
                                        1])),
                            imageUrl: specs[i].photo))),
            title: Text(specs[i].nom,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Wrap(
              children: [
                if (specs[i].tel.isNotEmpty) Text(specs[i].tel),
                if (specs[i].tel.isNotEmpty) const SizedBox(width: 10),
                if (specs[i].email.isNotEmpty) Text(specs[i].tel),
                if (specs[i].email.isNotEmpty) const SizedBox(width: 10),
                if (specs[i].adress.isNotEmpty) Text(specs[i].tel),
                if (specs[i].adress.isNotEmpty) const SizedBox(width: 10),
                if (specs[i].facebook.isNotEmpty) Text(specs[i].tel),
                if (specs[i].facebook.isNotEmpty) const SizedBox(width: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
