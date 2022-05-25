import 'package:flutter/material.dart';
import 'package:sohal_kutuphane/frontend/books_view.dart';
import 'package:sohal_kutuphane/frontend/panel/ayarlar.dart';
import 'package:sohal_kutuphane/frontend/panel/panel_auth.dart';
import 'package:sohal_kutuphane/frontend/panel/password_redirector.dart';

class BookSearch extends StatelessWidget {
  String mkey;
  String value;
  BookSearch({Key? key, required this.mkey, required this.value})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (value == ":panel") {
      return PanelAUTH();
    } else if (value == ":settings") {
      return PasswordRedirector(redirect: Ayarlar(), password: "merhabadunya");
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      //resizeToAvoidBottomInset: true,
      appBar: AppBar(backgroundColor: Colors.transparent),
      body: ListView(
        children: [
          BooksView(
              grid: true,
              errorText: "'$value' adlı bir kitap/içerik bulunamadı.",
              title: "Arama sonucu: " + value,
              addErrorWidget: Positioned(
                child: Image.asset(
                  "assets/images/down.gif",
                  height: 100,
                  width: 120,
                ),
                bottom: 70,
                right: 20,
              ),
              neverScroll: true,
              bookquery: {"yeni": "true", "adet": "40", mkey: value}),
          Padding(
            padding: EdgeInsets.all(20),
            child: BooksView(
              title: "En çok arananlar",
              bookquery: {"yeni": "true", "adet": "20", "tag": "top"},
            ),
          ),
        ],
      ),
    );
  }
}
