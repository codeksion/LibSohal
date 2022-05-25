import 'dart:ui';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:lottie/lottie.dart';
import 'package:progress_state_button/iconed_button.dart';
import 'package:progress_state_button/progress_button.dart';
import 'package:sohal_kutuphane/backend/borrow.dart';
import 'package:sohal_kutuphane/backend/layout.dart';

class BookBarcodeUserIDNavig extends StatefulWidget {
  String? bookid, userid, islem, booklocation;
  String type;

  String title;
  //Function(String bookid, String userid) onDone;
  BookBarcodeUserIDNavig({
    Key? key,
    this.bookid,
    this.userid,
    this.title = "Adınız listede yok :)",
    this.islem = "Gönder",
    this.booklocation,
    required this.type,
    //required this.onDone,
  }) : super(key: key);

  @override
  _BookBarcodeUserIDNavigState createState() => _BookBarcodeUserIDNavigState();
}

class _BookBarcodeUserIDNavigState extends State<BookBarcodeUserIDNavig> {
  bool showScanBarcode = false;
  var isbnController = TextEditingController();
  var buttonstate = ButtonState.idle;

  @override
  void initState() {
    showScanBarcode = widget.bookid == null;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),

      floatingActionButton: ProgressButton.icon(
        iconedButtons: {
          ButtonState.idle: IconedButton(
              text: widget.islem,
              icon: Icon(Icons.send, color: Colors.white),
              color: Colors.deepPurple.shade500),
          ButtonState.loading: IconedButton(
              text: "İşleniyor", color: Colors.deepPurple.shade700),
          ButtonState.fail: IconedButton(
              text: "Hata",
              icon: Icon(Icons.cancel, color: Colors.white),
              color: Colors.red.shade300),
          ButtonState.success: IconedButton(
              text: "Eyvah",
              icon: Icon(
                Icons.check_circle,
                color: Colors.white,
              ),
              color: Colors.green.shade400)
        },
        state: buttonstate,
        onPressed: () async {
          if ((widget.bookid ?? "") == "" || (widget.userid ?? "") == "") {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(
                    "Gerçi çalışmadım mı biliyosun B sallıyorum sınavı, 20-25 alıyorum rahat ediyorum yani")));
            return;
          }

          // Navigator.of(context).pop();

          // widget.onDone(widget.bookid!, widget.userid!);

          setState(() {
            buttonstate = ButtonState.loading;
          });
          try {
            var yanit = await BorrowBookRequest(
              book: Book(id: widget.bookid),
              studentNo: widget.userid!,
              type: widget.type,
            ).request();
            if (!yanit) {
              throw "İşlem başarısız..";
            }

            setState(() {
              buttonstate = ButtonState.success;
            });

            await Future.delayed(Duration(seconds: 3));
            if (mounted) {
              Navigator.of(context)
                  .pushNamedAndRemoveUntil("/", (route) => false);
            }
          } catch (e) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text("Hata :( $e")));
            setState(() {
              buttonstate = ButtonState.fail;
            });
          }
        },
      ),
      //backgroundColor: Colors.purpleAccent[200],
      body: (buttonstate == ButtonState.success)
          ? Stack(
              alignment: Alignment.center,
              children: [
                LottieBuilder.asset(
                  "assets/images/celebrate.json",
                  alignment: Alignment.center,
                ),
                AnimatedTextKit(animatedTexts: [
                  ColorizeAnimatedText(
                      "İşlem başarılı ( ͡° ͜ʖ ͡°)\nHaydi hoşçakal",
                      textAlign: TextAlign.center,
                      textStyle: TextStyle(fontSize: 50),
                      colors: [
                        Colors.blueAccent,
                        Colors.greenAccent,
                      ])
                ]),
              ],
            )
          : Column(
              children: [
                Card(
                  margin: EdgeInsets.only(left: 20, right: 20, top: 20),
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    //width: 200,
                    height: 200,
                    child: Row(children: [
                      LottieBuilder.asset(
                        "assets/images/people.json",
                        height: 130,
                      ),
                      SizedBox(
                        height: 20,
                        width: 20,
                      ),
                      Expanded(
                        child: (widget.userid != null)
                            ? Text(widget.userid!)
                            : TextField(
                                autofocus: true,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                keyboardType: TextInputType.number,
                                onChanged: (e) {
                                  widget.userid = e;
                                },
                                onSubmitted: (s) {
                                  widget.userid = s;
                                },
                                onEditingComplete: () {},
                                decoration: InputDecoration(
                                    label: Text(
                                      "Öğrenci okul numaran nedir?",
                                      style: TextStyle(fontSize: 20),
                                    ),
                                    contentPadding: EdgeInsets.only(left: 10),
                                    hintText: "yedibinkırkyedi",
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(20))),
                              ),
                        // ListTile(
                        // title: Text("Öğrenci okul numaran nedir?\n"),
                        // subtitle: ,
                        //)
                      ),
                    ]),
                  ),
                ),
                Card(
                  margin: EdgeInsets.only(left: 20, right: 20, top: 20),
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: SizedBox(
                    //padding: EdgeInsets.all(10),
                    // decoration: BoxDecoration(
                    //   borderRadius: BorderRadius.circular(20),
                    // ),
                    //width: 200,
                    height: 200,
                    child: Row(children: [
                      LottieBuilder.asset(
                        "assets/images/barcode.json",
                        height: 130,
                      ),
                      SizedBox(
                        height: 20,
                        width: 20,
                      ),
                      Expanded(
                        child: (!showScanBarcode)
                            ? Text("ISBN: ${widget.bookid}")
                            : TextField(
                                controller: isbnController,
                                autofocus: true,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                keyboardType: TextInputType.number,
                                onChanged: (e) {
                                  print(e);
                                  widget.bookid = e;
                                },
                                onSubmitted: (s) {
                                  widget.bookid = s;
                                },
                                onEditingComplete: () {},
                                decoration: InputDecoration(
                                    hintText: "8768492858",
                                    prefixText: "ISBN: ",
                                    helperText:
                                        "Arkağın arka kapağında, ince uzun şeritlerden (her biri bir rakamı ifade eder) oluşan barkod",
                                    label: Text(
                                      "Kitabın ISBN numarası nedir?",
                                      style: TextStyle(fontSize: 20),
                                    ),
                                    contentPadding: EdgeInsets.only(left: 10),
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(20))),
                              ),
                        // ListTile(
                        // title: Text("Öğrenci okul numaran nedir?\n"),
                        // subtitle: ,
                        //)
                      ),
                      if (showScanBarcode)
                        Padding(
                            padding: EdgeInsets.only(bottom: 5),
                            child: IconButton(
                              onPressed: () async {
                                FlutterBarcodeScanner.scanBarcode("black",
                                        "Vazgeçtim", true, ScanMode.BARCODE)
                                    .then((value) {
                                  setState(() {
                                    widget.bookid = value;
                                  });

                                  isbnController.text = value;
                                });
                              },
                              icon: Icon(Icons.camera_alt_rounded),
                              alignment: Alignment.center,
                            )),
                    ]),
                  ),
                ),
                Card(
                    margin: EdgeInsets.only(left: 20, right: 20, top: 20),
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: SizedBox(
                      //padding: EdgeInsets.all(10),
                      // decoration: BoxDecoration(
                      //   borderRadius: BorderRadius.circular(20),
                      // ),
                      //width: 200,
                      height: 200,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            flex: 4,
                            child: Padding(
                                padding: EdgeInsets.only(left: 30),
                                child: Text(widget.booklocation ??
                                    "Kitap konumu bilinmiyor :(")),
                          ),
                          LottieBuilder.asset("assets/images/location.json"),
                        ],
                      ),
                    )),
                Expanded(
                  child:
                      LottieBuilder.asset("assets/images/girl_with_book.json"),
                ),
              ],
            ),
    );
  }
}
