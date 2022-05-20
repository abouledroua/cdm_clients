// ignore_for_file: avoid_print

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cdm_clients/classes/data.dart';
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController txtPassword =
      TextEditingController(text: "*CDM_Admin*");
  String password = "";
  bool showPassword = false;
  int nbTry = 0;

  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized(); //all widgets are rendered here
    nbTry = 0;
    Data.isAdmin = false;
    if (Data.production) {
      txtPassword.text = "";
      password = "";
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Data.setSizeScreen(context);
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
                title: const Text("Authentification"), centerTitle: true),
            body: Center(
                child: Container(
              constraints: BoxConstraints(maxWidth: Data.maxWidth),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    Center(child: Image.asset("images/CDM.jpg")),
                    const SizedBox(height: 20),
                    Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                            controller: txtPassword,
                            onChanged: (value) => password = value,
                            obscureText: !showPassword,
                            textInputAction: TextInputAction.done,
                            keyboardType: TextInputType.visiblePassword,
                            decoration: InputDecoration(
                                suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        showPassword = !showPassword;
                                      });
                                    },
                                    icon: const Icon(Icons.remove_red_eye,
                                        color: Colors.black)),
                                hintText: "Code d'accées",
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always))),
                    const SizedBox(height: 20),
                    Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: Data.widthScreen / 8),
                        alignment: Alignment.center,
                        child: ElevatedButton(
                            style: ButtonStyle(backgroundColor:
                                MaterialStateProperty.resolveWith<Color>(
                                    (Set<MaterialState> states) {
                              if (states.contains(MaterialState.pressed)) {
                                return Colors.blue;
                              } else if (states
                                  .contains(MaterialState.disabled)) {
                                return Colors.grey;
                              }
                              return Colors
                                  .blue; // Use the component's default.
                            }), minimumSize:
                                MaterialStateProperty.resolveWith<Size>(
                                    (Set<MaterialState> states) {
                              return const Size.fromHeight(72);
                            }), shape: MaterialStateProperty.resolveWith<
                                OutlinedBorder>((Set<MaterialState> states) {
                              return const StadiumBorder();
                            }), textStyle:
                                MaterialStateProperty.resolveWith<TextStyle>(
                                    (Set<MaterialState> states) {
                              return const TextStyle(
                                  fontSize: 24, color: Colors.white);
                            })),
                            child: const Text("Connecter"),
                            onPressed: () {
                              if (txtPassword.text == Data.codeaccess) {
                                Data.isAdmin = true;
                                // Navigator.pop(context);
                                Navigator.of(context).pushNamedAndRemoveUntil(
                                    'AccueilAdmin',
                                    (Route<dynamic> route) => false);
                              } else {
                                Data.isAdmin = false;
                                nbTry++;
                                AwesomeDialog(
                                        context: context,
                                        dialogType: DialogType.ERROR,
                                        showCloseIcon: true,
                                        title: 'Erreur',
                                        desc: "Code d'accées incorrecte !!!")
                                    .show()
                                    .then((value) {
                                  if (nbTry == 3) {
                                    Navigator.pop(context);
                                  } else {
                                    setState(() {
                                      txtPassword.text = "";
                                      password = "";
                                    });
                                  }
                                });
                              }
                            }))
                  ]),
            ))));
  }
}
