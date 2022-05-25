import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:numeric_keyboard/numeric_keyboard.dart';
import 'package:sohal_kutuphane/backend/request.dart';
import 'package:sohal_kutuphane/frontend/panel/panel.dart';

class PanelAUTH extends StatefulWidget {
  const PanelAUTH({Key? key}) : super(key: key);

  @override
  _PanelAUTHState createState() => _PanelAUTHState();
}

class _PanelAUTHState extends State<PanelAUTH> {
  String inputtext = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Developer Console </>"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text("${'*' * inputtext.length} (${inputtext.length})"),
          NumericKeyboard(
            textColor: Colors.white,
            rightIcon: Icon(Icons.backspace),
            rightButtonFn: () {
              if (inputtext.isEmpty) {
                return;
              }
              setState(() {
                inputtext = inputtext.substring(0, inputtext.length - 1);
              });
            },
            leftIcon: Icon(Icons.send),
            leftButtonFn: () async {
              if (inputtext.length < 6) return;

              await requestAPIJson("/yetkili/getMe", headers: {"PW": inputtext})
                  .then((value) {
                if (value["error"] != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(value["error"].toString())));
                  return;
                }

                Navigator.pop(context);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Panel(
                        pw: inputtext, isim: value["isim"], rol: value["rol"]),
                  ),
                  //(route) => true
                );
              }).catchError((e) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text("Hata: $e")));
              });
            },
            onKeyboardTap: (text) {
              setState(() {
                inputtext += text;
              });
            },
          ),
          Text("ŞÖHAL Software Team  |  CODEKSION.net"),
        ],
      ),
    );
  }
}
