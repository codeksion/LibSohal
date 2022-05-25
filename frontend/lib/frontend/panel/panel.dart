import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sohal_kutuphane/frontend/monitor/monitor.dart';
import 'package:sohal_kutuphane/frontend/panel/ayarlar.dart';
import 'package:sohal_kutuphane/frontend/panel/kitap_ekle.dart';

class Panel extends StatelessWidget {
  final String pw;
  final String isim;
  final String rol;
  const Panel({
    Key? key,
    required this.pw,
    required this.isim,
    required this.rol,
  }) : super(key: key);

  Widget redirector(BuildContext context, String text, String asset,
          Function(BuildContext context) onpress) =>
      Container(
        height: 300,
        padding: EdgeInsets.all(10),
        alignment: Alignment.center,
        child: InkWell(
          onTap: () {
            onpress(context);
          },
          child: Stack(
            children: [
              Ink(
                  decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                  image: AssetImage(asset),
                  fit: BoxFit.cover,
                ),
              )),
              Center(
                child: Text(
                  text,
                  style: TextStyle(fontSize: 50),
                ),
              ),
            ],
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Developer Console </$isim>"),
      ),
      body: ListView(
        children: [
          redirector(
              context,
              "Kitap Ekle",
              "assets/images/book.gif",
              (context) => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PanelKitapEkle(pw: pw),
                  ))),
          redirector(
              context,
              "Ayarlar",
              "assets/images/disli.gif",
              (context) => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Ayarlar(),
                  ))),
          MonitorWidget(authkey: pw),
          Padding(
            padding: EdgeInsets.only(top: 20),
            child: Text(
              "ŞÖHAL Software Team  |  CODEKSION.net",
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
