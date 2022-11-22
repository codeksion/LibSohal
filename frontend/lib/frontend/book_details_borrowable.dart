import 'dart:io';

//import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animated_button/flutter_animated_button.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:lottie/lottie.dart';
import 'package:sohal_kutuphane/backend/borrow.dart';
import 'package:sohal_kutuphane/backend/borrowable.dart';

import 'dart:math' as math;

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:sohal_kutuphane/backend/image.dart';
import 'package:sohal_kutuphane/backend/layout.dart';
import 'package:sohal_kutuphane/frontend/BookBarcodeAndUserID.dart';
import 'package:sohal_kutuphane/frontend/redirectable_richtext.dart';
import 'package:sohal_kutuphane/frontend/utils.dart';

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1).toLowerCase()}";
  }
} // stackoverflow

class BorrowWidget extends StatefulWidget {
  final Book book;
  final double height, width;

  BorrowWidget({
    Key? key,
    required this.book,
    this.height = 150,
    this.width = 50,
  }) : super(key: key) {
    assert(book.id != null,
        "kitap id'si (isbn) null'a eşit olamaz. Bu bir geliştirici hatasıdır. (randomcode=553)");
  }

  @override
  _BorrowWidgetState createState() => _BorrowWidgetState();
}

class _BorrowWidgetState extends State<BorrowWidget> {
  Borrowable? brr;

  @override
  void initState() {
    super.initState();

    apiRequestBorrowable(widget.book.id ?? "").then((value) {
      brr = value;

      if (mounted) {
        setState(() {});
      }
    }).catchError((e) {
      print(e);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Hata: $e")));
    });
  }

  Widget buton({
    required String text,
    String? lottieAssest,
    VoidCallback? callback,
    Color? color,
  }) =>
      SizedBox(
        width: 270,
        child: AnimatedButton(
          text: text,
          onPress: callback ?? () {},
          transitionType: TransitionType.CENTER_LR_IN,
          gradient: (color == null)
              ? null
              : LinearGradient(colors: <Color>[
                  color,
                  Color((math.Random().nextDouble() * 0xFFFFFF).toInt())
                      .withOpacity(1),
                  Color((math.Random().nextDouble() * 0xFFFFFF).toInt())
                      .withOpacity(1)
                ]),
        ),
      );

  @override
  Widget build(BuildContext context) => (brr == null)
      ? CircularProgressIndicator()
      : Flexible(
          child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            buton(
              text: "Ödünç al",
              lottieAssest: "assets/images/buy.json",
              color: (brr!.borrowable ??= false) ? Colors.blue : Colors.orange,
              callback: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => BorrowBookInstructions(
                      redirect: BorrowBookWidget(
                    book: widget.book,
                    borrowable: brr,
                  )),
                ));
              },
            ),
            buton(
              text: "İade et",
              color: Colors.green,
              callback: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => BookBarcodeUserIDNavig(
                            type: "return",
                            bookid: widget.book.id,
                            booklocation: widget.book.kitapKonumu?.toPretty(),
                            islem: "İade et",
                            title: "${widget.book.baslik} iade",
                          )),
                );
              },
              lottieAssest: "assets/images/return.json",
            ),
          ],
        ));
}

class BorrowBookInstructions extends StatelessWidget {
  final Widget redirect;
  const BorrowBookInstructions({Key? key, required this.redirect})
      : super(key: key);

  void redirectfn(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => redirect), (route) => true);

    return;

    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => redirect));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Kitap ödünç al"),
        backgroundColor: Color.fromRGBO(0, 0, 0, 0.3),
      ),
      // floatingActionButton: FloatingActionButton.extended(
      //     onPressed: () {
      //       Navigator.of(context).pop();
      //     },
      //     label: Text("İptal")),
      body: IntroductionScreen(
        onDone: () => redirectfn(context),
        onSkip: () => redirectfn(context),
        done: Row(
          children: const [
            Icon(Icons.done),
            SizedBox(
              height: 20,
            ),
            Text(
              "Devam",
              style: TextStyle(color: Colors.white),
            )
          ],
        ),
        skip: Chip(
            label: Text("Atla"),
            avatar: Icon(
              Icons.keyboard_double_arrow_right,
              color: Colors.white,
            )),
        back: Icon(
          Icons.arrow_back_ios_rounded,
          color: Colors.white,
        ),
        next: Icon(
          Icons.arrow_forward_ios_rounded,
          color: Colors.white,
        ),
        globalBackgroundColor: Colors.purple,
        isBottomSafeArea: true,
        isTopSafeArea: true,
        showBackButton: true,
        pages: [
          PageViewModel(
            title: "Selam",
            body: "Demek kitap ödünç almak istiyorsun.\nDoğru butona bastın!",
            image: Center(
              child: LottieBuilder.asset("assets/images/girl_with_book.json"),
            ),
            useScrollView: false,
          ),
          PageViewModel(
            title: "Kurallar, kurallar",
            // body:
            //     "İstediğin kitabı alabilirsin. Ancak, elbette birkaç kuralımız var.",
            bodyWidget: Padding(
              padding: EdgeInsets.all(10),
              child: AnimatedTextKit(
                  displayFullTextOnTap: true,
                  isRepeatingAnimation: true,
                  repeatForever: true,
                  pause: Duration(seconds: 2),
                  // onFinished: () {
                  //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  //       content: Text(
                  //           "Herhangi bir sorununda kütüphane görevlisi ya da bilişim öğretmenine danışabilirsin.")));
                  // },

                  animatedTexts: [
                    TypewriterAnimatedText(
                      "1- Yıpratma.",
                      textStyle: TextStyle(
                        fontSize: 30,
                      ),
                    ),
                    TypewriterAnimatedText(
                      "2- Geciktirme.",
                      textStyle: TextStyle(
                        fontSize: 30,
                      ),
                    ),
                    TypewriterAnimatedText(
                      "2.1- Ödünç aldığın kitabı en fazla 1 ay alıkoyabilirsin.",
                      textStyle: TextStyle(
                        fontSize: 30,
                      ),
                    ),
                    TypewriterAnimatedText(
                        "3- Kitabı iade ederken sistemi kullan.",
                        textStyle: TextStyle(
                          fontSize: 30,
                        )),
                    TypewriterAnimatedText(
                      "3.1- Ödünç aldığın kitabı okuduktan sonra kütüphaneye bırakmış bile olsan LibŞÖHAL yazılımı üzerinde teslim etmemiş olarak gözükeceksin.\nHerhangi bir kitabı iade etmeden önce mutlaka yazılımımızı kullan.",
                      textStyle: TextStyle(
                        fontSize: 30,
                      ),
                    ),
                    TypewriterAnimatedText(
                      "4- Yerine geri bırak.",
                      textStyle: TextStyle(
                        fontSize: 30,
                      ),
                    ),
                    TypewriterAnimatedText(
                      "4.1- Kitabı nereden aldıysan yerine koyman gerekiyor.\nHatırlamıyor musun? Sorun değil. İade ederken sistemi kullan :)",
                      textStyle: TextStyle(
                        fontSize: 30,
                      ),
                    ),
                  ]),
            ),
            image: Center(
              child: LottieBuilder.asset("assets/images/share_book.json"),
            ),
            useScrollView: false,
          ),
          PageViewModel(
            title: "Son bir şey daha",
            image: Center(
              child: LottieBuilder.asset("assets/images/agreement.json"),
            ),
            bodyWidget: Container(
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Yazılımımız kullanıcı güvenliği/veri doğruluğu ikilemini sağlayabilmek/koruyabilmek adına aşağıdaki verileri okul içerisinde saklanan veritabanına kayıt edecektir.\nDevam ederek aşağıdaki bilgilerin veri tabanına yazılmasına onay vermiş sayılırsınız:\n\n",
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    "• Ödünç alınan: Kitap id/isbn numarası",
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                  Text(
                    "• Ödünç alınan: Tarih",
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                  Text(
                    "• Ödünç alan: Öğrenci okul nuraması",
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                  Text(
                    "• Ödünç alan: Fotoğrafı",
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                ],
              ),
            ),
            useScrollView: true,
          ),
        ],
      ),
    );
  }
}

class BorrowBookWidget extends StatefulWidget {
  final Book book;
  final Borrowable? borrowable;
  const BorrowBookWidget({
    Key? key,
    required this.book,
    this.borrowable,
  }) : super(key: key);

  @override
  _BorrowBookWidgetState createState() => _BorrowBookWidgetState();
}

class _BorrowBookWidgetState extends State<BorrowBookWidget> {
  String schoolid = "";
  bool borrowed = false;
  bool waitingResponse = false;

  void sfMessage(String mesaj) {
    print("sfMessage: $mesaj");
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(mesaj)));
    }
    ;
  }

  controlAndSendBorrow() async {
    print("controlAndSendBorrow: $schoolid");
    if (schoolid == "") {
      sfMessage("Lütfen okul nuramanı doldur!");
      return;
    }

    if (waitingResponse) {
      return;
    }

    waitingResponse = true;

    BorrowBookRequest(book: widget.book, studentNo: schoolid, type: "borrow")
        .request()
        .then((value) {
      waitingResponse = false;

      if (!value) {
        return;
      }

      sfMessage("İyi okumalar. İşlemin kayıt edildi.");
      setState(() {
        borrowed = true;
      });

      // () async {
      //   await Future.delayed(Duration(seconds: 10));
      //   Navigator.of(context).pushNamed("/");
      //   // Navigator.of(context).pop();
      //   // Navigator.of(context).pop();
      //   // Navigator.of(context).pop();
      // }();
    }).catchError((e) {
      sfMessage("Kitap ödünç alınamadı!\n${e}");
    });
  }

  bool get isScreenBig {
    return MediaQuery.of(context).size.width > 600;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: (borrowed)
          ? null
          : AppBar(
              title:
                  Text("${widget.book.baslik} kitabını ödünç almak üzeresin")),
      body: (borrowed)
          ? Stack(
              children: [
                Center(
                  child: LottieBuilder.asset("assets/images/banana.json"),
                ),
                Center(
                  child: AnimatedTextKit(
                      isRepeatingAnimation: false,
                      repeatForever: false,
                      onFinished: (() {
                        Navigator.pushNamedAndRemoveUntil(
                            context, "/", (route) => false);
                      }),
                      animatedTexts: [
                        TypewriterAnimatedText(
                          "Süper!\nArtık kitabı yasal olarak kaçırabilirsin.",
                          textAlign: TextAlign.center,
                          speed: Duration(milliseconds: 100),
                          textStyle: TextStyle(fontSize: 40, shadows: [
                            Shadow(
                              blurRadius: 0.5,
                              //color: Colors.purple,
                            ),
                          ]),
                        ),
                      ]),
                )
              ],
            )
          : ListView(
              children: [
                Card(
                  margin: EdgeInsets.all(20),
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
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
                        child: TextField(
                          autofocus: true,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          keyboardType: TextInputType.number,
                          onChanged: (e) {
                            schoolid = e;
                          },
                          onSubmitted: (s) {
                            schoolid = s;
                            controlAndSendBorrow();
                          },
                          onEditingComplete: () {
                            controlAndSendBorrow();
                          },
                          decoration: InputDecoration(
                              label: Text(
                                "Öğrenci okul numaran nedir?",
                                style: TextStyle(fontSize: 20),
                              ),
                              suffix: IconButton(
                                padding: EdgeInsets.all(5),
                                onPressed: controlAndSendBorrow,
                                icon: Icon(Icons.send),
                              ),
                              contentPadding: EdgeInsets.only(left: 10),
                              hintText: "yedibinkırkyedi",
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20))),
                        ),
                        // ListTile(
                        // title: Text("Öğrenci okul numaran nedir?\n"),
                        // subtitle: ,
                        //)
                      ),
                    ]),
                  ),
                ),
                SizedBox(
                  height: 30,
                  width: 30,
                ),
                Container(
                  padding: EdgeInsets.all(20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Flexible(
                          fit: FlexFit.loose,
                          flex: 1,
                          child: RedirectableRichText(list: {
                            "Kitap:${widget.book.baslik}": null,
                            "Yazar:${widget.book.baslik}": null,
                            "\nDil:${(widget.book.dil ?? "bilinmiyor").capitalize()}":
                                null,
                            "\nYazar:${widget.book.yazar ?? 'bilinmiyor'}":
                                null,
                            "\nYayın Evi:${widget.book.yayinEvi ?? 'bilinmiyor'}":
                                null,
                            "\nBasım yılı:${widget.book.basimYili}": null,
                            "\nKatagori:${(widget.book.katagoriler ?? []).join(': ')}":
                                null,
                            "\nSayfa sayısı:${widget.book.sayfaSayisi ?? 0}":
                                null,
                          })),
                      if (isScreenBig)
                        Flexible(
                          flex: 4,
                          fit: FlexFit.loose,
                          child: Text("${widget.book.ozet}"),
                        ),
                    ],
                  ),
                ),
                if (!isScreenBig)
                  Container(
                    padding: EdgeInsets.all(20),
                    child: Text("${widget.book.ozet}"),
                  ),
              ],
            ),
    );
  }
}

class ReturnBookWidget extends StatefulWidget {
  String? bookid;
  ReturnBookWidget({Key? key}) : super(key: key);

  @override
  _ReturnBookWidgetState createState() => _ReturnBookWidgetState();
}

class _ReturnBookWidgetState extends State<ReturnBookWidget> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
