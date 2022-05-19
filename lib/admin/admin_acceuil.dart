import 'package:cdm_clients/lists/list_specialites.dart';
import 'package:flutter/material.dart';

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
                appBar: AppBar(
                    title: const Text("Espace Admin"), centerTitle: true),
                body: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      InkWell(
                          onTap: () {},
                          child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Ink(
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: const [
                                    Icon(Icons.person_outline,
                                        color: Colors.blue, size: 38),
                                    SizedBox(width: 20),
                                    Text("Clients",
                                        style: TextStyle(
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
                                      children: const [
                                    Icon(Icons.bookmarks,
                                        color: Colors.amber, size: 38),
                                    SizedBox(width: 20),
                                    Text("Spécialités",
                                        style: TextStyle(
                                            color: Colors.amber,
                                            fontSize: 32,
                                            fontWeight: FontWeight.bold))
                                  ]))))
                    ]))));
  }
}
