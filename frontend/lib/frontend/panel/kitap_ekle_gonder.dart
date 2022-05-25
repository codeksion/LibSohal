import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:progress_state_button/iconed_button.dart';
import 'package:progress_state_button/progress_button.dart';
import 'package:sohal_kutuphane/backend/layout.dart';
import 'package:sohal_kutuphane/backend/request.dart';
import 'package:sohal_kutuphane/frontend/panel/kitap_ekle_layout.dart';

class KitapEkleGonder extends StatefulWidget {
  final String pw;

  final bool otofoto;

  final String id;
  final String baslik;
  final String yazar;
  final String dil;
  final String yayinEvi;
  final String basimYili;
  final String ozet;

  final int sayfaSayisi;

  final List<String> katagoriler;
  List<String> kitapkonumu;
  List<Fotograflar> kitaplar;

  KitapEkleGonder({
    Key? key,
    required this.pw,
    required this.otofoto,
    required this.id,
    required this.baslik,
    required this.yazar,
    required this.dil,
    required this.yayinEvi,
    required this.basimYili,
    required this.ozet,
    required this.sayfaSayisi,
    required this.katagoriler,
    required this.kitapkonumu,
    required this.kitaplar,
  }) : super(key: key) {
    if (kitapkonumu.isEmpty || kitapkonumu.length < 2) {
      kitapkonumu = ["", ""];
    }
  }

  @override
  _KitapEkleGonderState createState() => _KitapEkleGonderState();
}

class _KitapEkleGonderState extends State<KitapEkleGonder> {
  var buttonstate = ButtonState.idle;

  @override
  Widget build(BuildContext context) {
    //print("id: ${widget.id}");
    return ProgressButton.icon(
        state: buttonstate,
        onPressed: () async {
          setState(() {
            buttonstate = ButtonState.loading;
          });

          requestAPIPOST(
            "/yetkili/addBook",
            headers: {
              "PW": widget.pw,
              "Content-Type": "application/json",
              "Connection": "Keep-Alive"
            },
            body: json.encode(KitapEkleLayout(
              fotograflar: widget.kitaplar,
              kitap: Book(
                basimYili: widget.basimYili,
                baslik: widget.baslik,
                dil: widget.dil,
                id: widget.id,
                katagoriler: widget.katagoriler,
                ozet: widget.ozet,
                sayfaSayisi: widget.sayfaSayisi,
                yayinEvi: widget.yayinEvi,
                yazar: widget.yazar,
                kitapKonumu: KitapKonumu(
                  sira: widget.kitapkonumu[0],
                  sutun: widget.kitapkonumu[1],
                ),
              ),
            ).toJson()),
          ).then((value) {
            print("status code: ${value.statusCode}");
            if (value.statusCode == 200) {
              buttonstate = ButtonState.success;
            } else {
              buttonstate = ButtonState.fail;
              print(value.body);
            }

            setState(() {});
          }).catchError((e, a) {
            print(e);
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text("Hata: $e")));
            setState(() {
              buttonstate = ButtonState.fail;
            });
          });
        },
        iconedButtons: {
          ButtonState.idle: IconedButton(
              text: "Kitap Ekle",
              icon: Icon(Icons.send, color: Colors.white),
              color: Colors.deepPurple.shade500),
          ButtonState.loading: IconedButton(
              text: "Ekleniyor", color: Colors.deepPurple.shade700),
          ButtonState.fail: IconedButton(
              text: "Hata",
              icon: Icon(Icons.cancel, color: Colors.white),
              color: Colors.red.shade300),
          ButtonState.success: IconedButton(
              text: "Kitap Eklendi",
              icon: Icon(
                Icons.check_circle,
                color: Colors.white,
              ),
              color: Colors.green.shade400)
        });
  }
}
