import 'dart:math';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:sohal_kutuphane/frontend/BookBarcodeAndUserID.dart';
import 'package:sohal_kutuphane/frontend/book_details_borrowable.dart';
import 'package:sohal_kutuphane/frontend/books_catagories.dart';
import 'package:sohal_kutuphane/frontend/books_search.dart';
import 'package:sohal_kutuphane/frontend/books_view.dart';
import 'package:sohal_kutuphane/frontend/error/generalErrorWidget.dart';

class ReloadableHome extends StatefulWidget {
  const ReloadableHome({Key? key}) : super(key: key);

  @override
  _ReloadableHomeState createState() => _ReloadableHomeState();
}

class _ReloadableHomeState extends State<ReloadableHome> {
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
        child: Home(),
        onRefresh: () async {
          setState(() {});
        });
  }
}

class Home extends StatelessWidget {
  Home({Key? key}) : super(key: key);

  var controller = ScrollController();
  var textfieldcontroller = TextEditingController();

  dynamic getRandomListValue(List list) {
    return list[Random().nextInt(list.length)];
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      top: true,
      child: Scaffold(
          floatingActionButton: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.all(5),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => BorrowBookInstructions(
                                redirect: BookBarcodeUserIDNavig(
                              type: "borrow",
                              islem: "Ödünç Al",
                              title: "Ismarlama kitap",
                            ))));
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      LottieBuilder.asset(
                        "assets/images/buy.json",
                        height: 70,
                      ),
                      AnimatedTextKit(repeatForever: true, animatedTexts: [
                        FadeAnimatedText(
                          "Ödünç\nAl",
                          textAlign: TextAlign.center,
                          textStyle: TextStyle(fontSize: 20),
                        ),
                      ]),
                    ],
                  ),
                  style: ElevatedButton.styleFrom(
                    shape: CircleBorder(), //<-- SEE HERE
                    padding: EdgeInsets.all(5),
                    alignment: Alignment.center,
                    primary: Colors.green,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(5),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => BookBarcodeUserIDNavig(
                              type: "return",
                              islem: "İadet et",
                              title: "Ismarlama kitap iadesi ",
                            )));
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      LottieBuilder.asset(
                        "assets/images/return.json",
                        height: 70,
                      ),
                      AnimatedTextKit(repeatForever: true, animatedTexts: [
                        FadeAnimatedText(
                          "İade\nEt",
                          textAlign: TextAlign.center,
                          textStyle: TextStyle(fontSize: 20),
                        )
                      ]),
                    ],
                  ),
                  style: ElevatedButton.styleFrom(
                    shape: CircleBorder(), //<-- SEE HERE
                    padding: EdgeInsets.all(5),
                    alignment: Alignment.center,
                    primary: Colors.orange,
                  ),
                ),
              ),
            ],
          ),
          appBar: AppBar(
              toolbarHeight: 90,
              backgroundColor: Colors.transparent,
              flexibleSpace: SizedBox(
                height: 90,
                child: Column(
                  children: [
                    SizedBox(
                      height: 40,
                      child: Padding(
                        padding: EdgeInsets.only(left: 10, right: 10),
                        child: TextField(
                          maxLines: 1,
                          onSubmitted: (v) {
                            textfieldcontroller.clear();
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BookSearch(
                                    value: v,
                                    mkey: "baslik",
                                  ),
                                ));
                          },

                          controller: textfieldcontroller,

                          //scrollPadding: EdgeInsets.all(0),

                          decoration: InputDecoration(

                              //contentPadding: EdgeInsets.all(10),
                              //helperText: Text("Neye bakmıştın?"),
                              //helperText: "Neye bakmıştın?",
                              hintText: getRandomListValue([
                                "Ölüme gidelim dedin de mazot mu yok dedik",
                                "İleride güzel günler göreceğiz demişlerdi. Daha ne kadar gideceğiz?",
                                "Sana gelmediğim gün, sanayiye gittiğim gündür gülüm...",
                                "Otopsi istiyorum! Hayallerim kendi eceliyle ölmüş olamaz.",
                                "Nolacak bu mazotun fiyatı.."
                              ]),
                              labelText: "Neye bakmıştın?",
                              border: OutlineInputBorder(
                                // borderRadius: BorderRadius.only(
                                //   bottomLeft: Radius.circular(15),
                                //   bottomRight: Radius.circular(15),
                                // ),
                                //gapPadding: 10,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5)),
                              )),
                        ),
                      ),
                    ),
                    Expanded(
                      child: BookCatagories(),
                    ),
                  ],
                ),
              )),
          body: ListView(
            controller: controller,
            children: [
              // Container(
              //   padding: EdgeInsets.all(5),
              //   child: BookCatagories(),
              // ),
              BooksView(
                title: "En Yeniler",
                bookquery: {"yeni": "true", "adet": "20"},
                otoRefresh: Duration(minutes: 5),
              ),
              BooksView(
                title: "İçerikler",
                bookquery: {
                  "_sayfa": 1,
                  "adet": "50",
                  "yeni": "false",
                  "rastgele":
                      "true", //https://stackoverflow.com/questions/2824157/random-record-from-mongodb
                },
                grid: true,
                scrollController: controller,
                neverScroll: true,
                otoRefresh: Duration(minutes: 10),
                errorWidget: (_, e) => GeneralErrorWidget(
                  error: e,
                  showOfflineSettingsButton: true,
                  height: 200,
                  width: 100,
                ),
              ),
            ],
          )),
    );
  }
}
