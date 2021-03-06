import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:lottie/lottie.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sohal_kutuphane/backend/layout.dart';
import 'package:sohal_kutuphane/backend/request.dart';
import 'package:sohal_kutuphane/service/service.dart';

class EbookAsButton extends StatefulWidget {
  final String title;
  final Book book;
  const EbookAsButton({
    Key? key,
    required this.title,
    required this.book,
  }) : super(key: key);

  @override
  _EbookAsButtonState createState() => _EbookAsButtonState();
}

class _EbookAsButtonState extends State<EbookAsButton> {
  bool? cbd;
  String name = "";

  @override
  void initState() {
    () async {
      requestAPIJson(
        "/cbd?query=${widget.title}",
      ).then((value) {
        print("cbd response: $value");
        setState(() {
          cbd = value["name"] != null;
          if (cbd!) name = value["name"] as String;
        });
      }).catchError((e) {
        print("cbd request error: $e");
      });
    }();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ((cbd ?? false) && (Service.config.WifiSSID ?? "") != "")
        ? InkWell(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => EBookDownloaderClient(
                        title: widget.title,
                        book: widget.book,
                      )));
            },
            child: Column(
              children: [
                LottieBuilder.asset(
                  "assets/images/pdf.json",
                  height: 100,
                ),
                Text(
                  "E-kitap\nolarak oku",
                  textAlign: TextAlign.center,
                )
              ],
            ),
          )
        : Container();
  }
}

class EBookDownloaderClient extends StatelessWidget {
  final String title;
  final Book? book;
  const EBookDownloaderClient({
    Key? key,
    required this.title,
    this.book,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Haydi sana e-kitap hediye edelim"),
        backgroundColor: Color.fromRGBO(0, 0, 0, 0.3),
      ),
      body: IntroductionScreen(
        next: Text("Sonraki a??ama"),
        back: Text("??nceki a??ama"),
        done: Text("Tamamd??r!"),
        onDone: () {
          Navigator.of(context).pop();
        },
        showNextButton: true,
        showBackButton: true,
        showDoneButton: true,
        isBottomSafeArea: true,
        isTopSafeArea: true,
        pages: [
          PageViewModel(
              decoration: PageDecoration(
                bodyAlignment: Alignment.center,
                pageColor: Colors.purple,
              ),
              title: title,
              body:
                  "Kitab??n haz??r. Haz??r olmas??na ama..\nOkumak istedi??in kitap: '${(book?.baslik ?? 'bilinmeyen')}'\nBulabildi??im kitap: '$title'\n\nArad??????n?? bulabildiysem, telefonunu haz??rla; buyur devam et :)"),
          PageViewModel(
            title: "Seni a??a ba??layal??m!",
            decoration: PageDecoration(
              bodyAlignment: Alignment.center,
            ),
            bodyWidget: Center(
              //padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  QrImage(
                    data: Service.toWifiQR(),
                    backgroundColor: Colors.white,
                    version: QrVersions.auto,
                    size: 320,
                    gapless: true,
                    semanticsLabel: "Connect to ${Service.config.WifiSSID}",
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    "Ak??ll?? telefon yaz??l??m??n destekliyorsa yukar??daki Qr kodu okutarak a??a ba??lanabilirsin.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 25),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text.rich(TextSpan(
                          text: "Wifi SSID: ",
                          style: TextStyle(),
                          children: [
                            TextSpan(
                              text: Service.config.WifiSSID,
                              style: TextStyle(color: Colors.orange),
                            ),
                          ])),
                      Text.rich(TextSpan(text: "Wifi Pass: ", children: [
                        TextSpan(
                          text: Service.config.WifiPass ?? "",
                          style: TextStyle(color: Colors.orange),
                        ),
                      ])),
                    ],
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Text(
                    "Dipnot: E-kitab?? ak??ll?? telefon/tabletine indirilebilmek i??in bu a??a ba??l?? olmak zorundas??n.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            useScrollView: false,
          ),
          PageViewModel(
            title: "Haydi, indiiir",
            bodyWidget: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "A??a????daki QR kodu okutarak i??eri??i indirebilirsin",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  QrImage(
                    data:
                        "${Service.config.ApiURL}/db?query=${Uri.encodeQueryComponent(title)}",
                    backgroundColor: Colors.white,
                    version: QrVersions.auto,
                    size: 320,
                    gapless: true,
                    semanticsLabel: "Download the document",
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Text(
                    "D??k??man?? indirirken ${Service.config.WifiSSID} a????ndan ayr??lma.\n${Service.config.WifiSSID} a????na ba??l?? olan arkada????na ba??lant??y?? atarak\nkitab?? onlarla da payla??abilirsin. Ancak ba??lant?? yaln??zca 5 dakika ge??erli.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    "Kitap .zip uzant??l?? inerse .epub olarak de??i??tirmen uyumlu program ile ba??latman i??in yeterli olacakt??r",
                    style: TextStyle(fontSize: 10, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Text(
                    "??yi okumalar ( ????? ???? ????? )",
                    style: TextStyle(fontSize: 30),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
