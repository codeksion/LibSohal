import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sohal_kutuphane/backend/book_meta.dart';
import 'package:sohal_kutuphane/backend/image.dart';
import 'package:sohal_kutuphane/backend/request.dart';
import 'package:sohal_kutuphane/frontend/ocr/ocr.dart';
import 'package:sohal_kutuphane/frontend/panel/fotograf_panel.dart';
import 'package:sohal_kutuphane/frontend/panel/kitap_ekle_gonder.dart';
import 'package:sohal_kutuphane/frontend/panel/kitap_ekle_layout.dart';

class PanelKitapEkle extends StatefulWidget {
  final String pw;
  const PanelKitapEkle({Key? key, required this.pw}) : super(key: key);

  @override
  _PanelKitapEkleState createState() => _PanelKitapEkleState();
}

class _PanelKitapEkleState extends State<PanelKitapEkle> {
  String? oneri;
  //"ISBN <ID> zaten kayıt edilmiş. Kitap Ekle isteği atıldığı zaman önceden kayıt edilen kitabın sayısı 1 arttıralacak.\nDeğerleri tekrar doldurmanız gerek yok!";
  Function? oneriFunc; /* = () {
    print("öneri uygulanacak!");
  };*/

  String id = "";
  var idController = TextEditingController();

  String baslik = "";
  var baslikController = TextEditingController();

  String yazar = "";
  var yazarController = TextEditingController();

  String dil = "";
  var dilController = TextEditingController();

  int sayfaSayisi = 0;
  var sayfaSayisiController = TextEditingController();

  String yayinEvi = "";
  var yayinEviController = TextEditingController();

  String basimYili = "";
  var basimYiliController = TextEditingController();

  String ozet = "";
  var ozetController = TextEditingController();

  List<String> katagoriler = [];
  var katagorilerController = TextEditingController();

  List<String> kitapKonumu = [];
  var kitapKonumuController = TextEditingController();

  List<Fotograflar> fotograflar = [];

  int ocrbuttonstate = 0; // 0 wait | 1 loading | 2 error

  bool otoresim = true;

  void IdISBNKontrol() async {
    print("id $id isbn kontrol");
    getBooks({"id": id}).then((value) {
      if ((value.books ??= []).isNotEmpty) {
        print("not empty");

        setState(() {
          oneri =
              "ISBN $id zaten kayıt edilmiş. Kitap Ekle isteği atıldığı zaman önceden kayıt edilen kitabın sayısı 1 arttıralacak.\nDeğerleri tekrar doldurmanıza gerek yok!";
          oneriFunc = () {
            setState(() {
              baslik = "ONEMSIZ";
              baslikController.text = "ONEMSIZ";
            });
          };
        });
      }
    }).catchError((e) => null);
  }

  Widget input(String text, Widget child,
          {double height = 50, double width = 100}) =>
      Container(
        padding: EdgeInsets.all(5),
        height: height,
        child: Row(
          children: [
            //Flexible(
            //child:
            Container(
              width: width,
              child: Text(
                text,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            //flex: 0,
            //),
            Expanded(
              child: child,
              flex: 4,
            ),
          ],
        ),
      );

  String shortCNCodeToLong(String? code) {
    if (code == null) return "";
    switch (code) {
      case "tr":
        return "Türkçe";
      case "en":
        return "İngilizce";
      case "fr":
        return "Fransızca";
      case "de":
        return "Almanca";
      case "ar":
        return "Arapça";
    }

    return "";
  }

  void chanceMeta(BookMeta value) {
    // if (value.readingModes.image ?? false) {
    //   oneri = "Kitap sayfalarına ait fotoğraf(lar) bulundu.";
    //   oneriFunc = null;
    // }
    setState(() {
      idController.text = id;

      baslik = value.title ?? "";
      baslikController.text = baslik;

      yazar = value.writer ?? "";
      yazarController.text = yazar;

      dil = shortCNCodeToLong(value.language);
      dilController.text = dil;

      sayfaSayisi = value.pageCount ?? 0;
      sayfaSayisiController.text = sayfaSayisi.toString();

      yayinEvi = value.publishingHouse ?? "";
      yayinEviController.text = yayinEvi;

      basimYili = (value.publishingDate ?? "").split("-")[0];
      basimYiliController.text = basimYili;

      if (ozet != "") ozet = value.summary ?? "";
      if (ozet != "") ozetController.text = ozet;

      if (value.previewImageUrl != null || value.previewImageUrl != "") {
        fotograflar.add(Fotograflar(
          isRemote: true,
          data: value.previewImageUrl,
        ));
      }

      // (value.demoPagesUrl ??= []).forEach((element) {
      //   fotograflar.add(Fotograflar(
      //     isRemote: true,
      //     data: element,
      //   ));
      // });
    });

    fotograflar.addAll((value.demoPagesUrl ??= [])
        .map((e) => Fotograflar(isRemote: true, data: e)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Developer Console | Kitap Ekle"),
        actions: [
          IconButton(
              onPressed: () {
                setState(() {
                  oneri = null;
                  oneriFunc = null;

                  idController.text = "";
                  id = "";

                  baslikController.text = "";
                  baslik = "";

                  yazar = "";
                  yazarController.text = "";

                  dil = "";
                  dilController.text = "";

                  sayfaSayisi = 0;
                  sayfaSayisiController.text = "";

                  yayinEvi = "";
                  yayinEviController.text = "";

                  basimYili = "";
                  basimYiliController.text = "";

                  ozet = "";
                  ozetController.text = "";

                  katagoriler = [];
                  katagorilerController.text = "";

                  kitapKonumu = [];
                  kitapKonumuController.text = "";

                  fotograflar = [];
                });
              },
              icon: Icon(Icons.delete)),
          Container(
            height: 25,
            width: 25,
          ),
        ],
      ),
      floatingActionButton: KitapEkleGonder(
        pw: widget.pw,
        basimYili: basimYili,
        baslik: baslik,
        dil: dil,
        id: id,
        katagoriler: katagoriler,
        kitapkonumu: kitapKonumu,
        otofoto: otoresim,
        ozet: ozet,
        sayfaSayisi: sayfaSayisi,
        yayinEvi: yayinEvi,
        yazar: yazar,
        kitaplar: fotograflar,
      ),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          if (oneri != null)
            Container(
              decoration: BoxDecoration(
                  color: Colors.green, borderRadius: BorderRadius.circular(10)),
              padding: EdgeInsets.all(20),
              //height: 60,
              //color: Colors.green,
              child: Column(
                children: [
                  Text(oneri!),
                  if (oneriFunc != null)
                    Container(
                      height: 10,
                    ),
                  if (oneriFunc != null)

                    /*Expanded(
                        child: */
                    TextButton(
                      style: ButtonStyle(
                          alignment: Alignment.center,
                          padding:
                              MaterialStateProperty.all(EdgeInsets.all(15)),
                          backgroundColor:
                              MaterialStateProperty.all(Colors.black)),
                      onPressed: () {
                        setState(() {
                          oneri = null;
                        });
                        oneriFunc!();
                      },
                      child: Text(
                        "Öneriyi uygula",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                      //)
                    ),
                ],
              ),
            ),
          input(
              "Id (ISBN)",
              Row(
                children: [
                  Expanded(
                      child: TextField(
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    controller: idController,
                    onEditingComplete: () => IdISBNKontrol(),
                    onChanged: (value) {
                      setState(() {
                        id = value;
                      });
                      //idController.text = id;
                    },
                    onSubmitted: (value) => IdISBNKontrol(),

                    //onEditingComplete: (value) async {},
                  )),
                  IconButton(
                      onPressed: () async {
                        searchBook(id)
                            .then((value) => chanceMeta(value))
                            .catchError((e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Kitap bulunamadı: $e")));
                        });
                      },
                      icon: Icon(Icons.radio_button_checked_sharp)),
                  IconButton(
                      onPressed: () async {
                        var response = await FlutterBarcodeScanner.scanBarcode(
                            "black", "Iptal", true, ScanMode.BARCODE);
                        print("Barcode: $response");

                        setState(() {
                          id = response;
                          idController.text = id;
                        });
                      },
                      icon: Icon(Icons.camera_alt)),
                ],
              )),
          input(
              "Başlık",
              Row(
                children: [
                  Expanded(
                      child: TextField(
                    controller: baslikController,

                    onChanged: (value) => baslik = value,

                    //onEditingComplete: (value) async {},
                  )),
                  IconButton(
                      onPressed: () async {
                        searchBook(baslik)
                            .then((value) => chanceMeta(value))
                            .catchError((e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Kitap bulunamadı: $e")));
                        });
                      },
                      icon: Icon(Icons.radio_button_checked_sharp)),
                ],
              )),
          input(
              "Yazar",
              TextField(
                controller: yazarController,
                onChanged: (value) => yazar = value,
              )),
          input(
              "Dil",
              TextField(
                controller: dilController,
                onChanged: (value) => dil = value,
              )),
          input(
              "Sayfa Sayısı",
              TextField(
                keyboardType: TextInputType.number,
                controller: sayfaSayisiController,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (value) => sayfaSayisi = int.tryParse(value) ?? 0,
              )),
          input(
              "Yayın Evi",
              TextField(
                controller: yayinEviController,
                onChanged: (value) => yayinEvi = value,
              )),
          input(
              "Basım Yılı",
              TextField(
                controller: basimYiliController,
                onChanged: (value) => basimYili = value,
              )),
          input(
              "Özet",
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      minLines: 1,
                      maxLines: 100,
                      keyboardType: TextInputType.multiline,
                      maxLength: TextField.noMaxLength,
                      controller: ozetController,
                      onChanged: (value) => ozet = value,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                          onPressed: () async {
                            requestAPI("/booksummary?isbn=" + id).then((value) {
                              if (value.statusCode != 200) {
                                throw json.decode(value.body)["error"];
                              }
                              setState(() {
                                ozet = value.body;
                                ozetController.text = ozet;
                              });
                            }).catchError((e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text("Özet bulunamadı: $e")));
                            });
                          },
                          icon: Icon(Icons.radio_button_checked_sharp)),
                      IconButton(
                          onPressed: () {
                            setState(() {
                              ocrbuttonstate = 1;
                            });
                            pickImageAndOCR().then((value) {
                              print("ocr response $value");
                              if (value == null) return;
                              setState(() {
                                ozet = value;
                                ozetController.text = ozet;
                                ocrbuttonstate = 0;
                              });
                            }).catchError((e) {
                              print("pickImageAndOCR error: $e");
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("OCR hata: $e")));

                              setState(() {
                                ocrbuttonstate = 0;
                              });
                            });
                          },
                          icon: (ocrbuttonstate == 0)
                              ? Icon(Icons.camera_alt)
                              : CircularProgressIndicator()),
                    ],
                  ),
                ],
              ),
              height: 300),
          input(
              "Katagoriler",
              TextField(
                decoration: InputDecoration(
                    hintText: "roman, tarih, felsefe, bilim kurgu"),
                onChanged: (v) {
                  var split = v.toLowerCase().split(",");
                  katagoriler = split.map((e) => e.trim()).toList();
                },
                controller: katagorilerController,
              )),
          input(
              "Kitap Konumu",
              TextField(
                decoration: InputDecoration(hintText: "Felsefe,1"),
                onChanged: (v) {
                  var split = v.split(",");
                  if (split.length != 2) {
                    return;
                  }
                  kitapKonumu = split.map((e) => e.trim()).toList();
                },
                controller: kitapKonumuController,
              )),
          // input(
          //     "Otomatik Resim Ekle",
          //     Switch(
          //         value: otoresim,
          //         onChanged: (b) => setState(() {
          //               otoresim = b;
          //             })),
          //     height: 50,
          //     width: 200),
          SizedBox(
            height: 200,
            child: Stack(
              children: [
                input(
                  "Fotoğraflar",
                  FotografPanel(
                      onIndexChanged: (p0, p1) {
                        var iv = fotograflar[p0];
                        var i2v = fotograflar[p1];

                        fotograflar[p0] = i2v;
                        fotograflar[p1] = iv;
                      },
                      onRemoved: (i) {
                        fotograflar.removeAt(i);
                      },
                      seed: List<ImageProvider>.generate(fotograflar.length,
                          (index) {
                        if (fotograflar[index].isBase64 ?? false) {
                          return MemoryImage(
                              base64.decode(fotograflar[index].data ?? ""));
                        }
                        return ServerURL(fotograflar[index].data ?? "").image;
                      })),
                  height: 200,
                ),
                Positioned(
                  child: IconButton(
                      onPressed: () {
                        ImagePicker()
                            .pickImage(source: ImageSource.camera)
                            .then((image) {
                          if (image == null) return;

                          setState(() {
                            fotograflar.add(Fotograflar(
                                isBase64: true,
                                data: base64.encode(
                                    File(image.path).readAsBytesSync())));
                          });
                        });
                      },
                      icon: Icon(Icons.add)),
                  bottom: 5,
                  left: 10,
                ),
              ],
            ),
          ),
          SizedBox(
            height: 100,
          )
        ],
      ),
    );
  }
}
