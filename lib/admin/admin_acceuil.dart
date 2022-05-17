import 'package:flutter/material.dart';

class AcceuilAdmin extends StatefulWidget {
  const AcceuilAdmin({Key? key}) : super(key: key);

  @override
  State<AcceuilAdmin> createState() => _AcceuilAdminState();
}

class _AcceuilAdminState extends State<AcceuilAdmin> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Espace Admin"), centerTitle: true),
        body:
            Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          InkWell(
              onTap: () {},
              child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Ink(
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
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
              onTap: () {},
              child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Ink(
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                        Icon(Icons.bookmarks, color: Colors.amber, size: 38),
                        SizedBox(width: 20),
                        Text("Spécialités",
                            style: TextStyle(
                                color: Colors.amber,
                                fontSize: 32,
                                fontWeight: FontWeight.bold))
                      ])))),
          InkWell(
              onTap: () {},
              child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Ink(
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                        Icon(Icons.post_add_rounded,
                            color: Colors.purple, size: 38),
                        SizedBox(width: 20),
                        Text("Inscrire",
                            style: TextStyle(
                                color: Colors.purple,
                                fontSize: 32,
                                fontWeight: FontWeight.bold))
                      ]))))
        ]));
  }
}
