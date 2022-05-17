import 'package:flutter/material.dart';

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

  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized(); //all widgets are rendered here
    idSpecialite = widget.idSpecialite;
    desSpecialite = widget.desSpecialite;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(desSpecialite),
        centerTitle: true,
      ),
      body: Container(child: Text(idSpecialite.toString())),
    );
  }
}
