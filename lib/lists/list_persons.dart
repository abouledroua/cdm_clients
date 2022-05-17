import 'package:cdm_clients/classes/data.dart';
import 'package:flutter/material.dart';

class ListPersons extends StatefulWidget {
  const ListPersons({Key? key}) : super(key: key);

  @override
  State<ListPersons> createState() => _ListPersonsState();
}

class _ListPersonsState extends State<ListPersons> {
  @override
  Widget build(BuildContext context) {
    Data.setSizeScreen(context);
    return Scaffold(body: Container());
  }
}
