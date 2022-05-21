import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cdm_clients/Authentification/login.dart';
import 'package:cdm_clients/classes/data.dart';
import 'package:cdm_clients/lists/list_persons.dart';
import 'package:cdm_clients/lists/list_specialites.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AcceuilAdmin extends StatefulWidget {
  const AcceuilAdmin({Key? key}) : super(key: key);

  @override
  State<AcceuilAdmin> createState() => _AcceuilAdminState();
}

class _AcceuilAdminState extends State<AcceuilAdmin> {
  Future<bool> _onWillPop() async {
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: WillPopScope(
            onWillPop: _onWillPop,
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
                    title: Text("Espace Admin", style: GoogleFonts.laila()),
                    centerTitle: true),
                body: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      InkWell(
                          onTap: () {
                            var route = MaterialPageRoute(
                                builder: (context) => const ListPersons(
                                    pSelect: false, selPersons: []));
                            Navigator.of(context)
                                .push(route)
                                .then((value) => setState(() {}));
                          },
                          child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Ink(
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                    const Icon(Icons.person_outline,
                                        color: Colors.blue, size: 38),
                                    const SizedBox(width: 20),
                                    Text("Clients",
                                        style: GoogleFonts.laila(
                                            color: Colors.blue,
                                            fontSize: 32,
                                            fontWeight: FontWeight.bold))
                                  ])))),
                      InkWell(
                          onTap: () {
                            var route = MaterialPageRoute(
                                builder: (context) => const ListSpecialite());
                            Navigator.of(context)
                                .push(route)
                                .then((value) => setState(() {}));
                          },
                          child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Ink(
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                    const Icon(Icons.bookmarks,
                                        color: Colors.amber, size: 38),
                                    const SizedBox(width: 20),
                                    Text("Spécialités",
                                        style: GoogleFonts.laila(
                                            color: Colors.amber,
                                            fontSize: 32,
                                            fontWeight: FontWeight.bold))
                                  ]))))
                    ]))));
  }
}
