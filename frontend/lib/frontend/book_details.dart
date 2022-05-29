import 'package:delayed_display/delayed_display.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:sohal_kutuphane/backend/image.dart';
import 'package:sohal_kutuphane/backend/layout.dart';
import 'package:sohal_kutuphane/backend/utils.dart';
import 'package:sohal_kutuphane/frontend/book_details_borrowable.dart';
import 'package:sohal_kutuphane/frontend/books_search.dart';
import 'package:sohal_kutuphane/frontend/books_view.dart';
import 'package:sohal_kutuphane/frontend/ebook.dart';
import 'package:sohal_kutuphane/frontend/redirectable_richtext.dart';
import 'package:sohal_kutuphane/frontend/slider.dart';
import 'package:sohal_kutuphane/service/service.dart';

class BookDetails extends StatelessWidget {
  final Book book;
  final String? herokey;
  const BookDetails({
    Key? key,
    required this.book,
    this.herokey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(book.baslik ?? "Kitap"),
        //backgroundColor: Colors.transparent,
        backgroundColor: Color.fromRGBO(0, 0, 0, 0.5),

        //excludeHeaderSemantics: true,
      ),
      body: Container(
        //child:
        // Stack(
        //   children: [
        //Visibility(child: child),
        // DelayedDisplay(
        //     fadeIn: true,
        //     fadingDuration: Duration(seconds: 2),
        //     child: Center(
        //       child: Opacity(
        //         opacity: 0.05,
        //         child: Hero(
        //           tag: getHeroTag(book, herokey ?? ""),
        //           child: Material(
        //             child: Ink.image(
        //                 fit: BoxFit.cover,
        //                 image: NetworkImage(
        //                     ServerURL.normalizedList(book.fotograflar))),
        //           ),
        //         ),
        //       ),
        //     )),
        // Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // if (book.fotograflar != null && book.fotograflar!.isNotEmpty)
              //   SizedBox(
              //     height: 150,
              //     width: 150,
              //     child: Ink.image(
              //       image: NetworkImage(book.fotograflar!.first),
              //       fit: BoxFit.fill,
              //       alignment: Alignment.center,
              //       colorFilter: ColorFilter.mode(
              //         Colors.grey,
              //         BlendMode.colorBurn,
              //       ),
              //     ),
              //   ),
              SizedBox(
                //width: 200,
                height: 50,
              ),
              Container(
                  padding: EdgeInsets.all(10),
                  child: ListTile(
                    title: Text((book.baslik ?? "") +
                        " - " +
                        book.basimYili.toString()),
                    subtitle: Text(book.ozet ?? "Özet eklenmemiş."),
                  )),
              // ListTile(
              //   title: Text("Kitap konumu"),
              //   subtitle: Text(getFormatedKitapKonumu(book.kitapKonumu)),
              // ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 200,
                    child: ListTile(
                      title: Text("Kitap konumu"),
                      subtitle: Text(getFormatedKitapKonumu(book.kitapKonumu)),
                    ),
                  ),
                  BorrowWidget(
                    book: book,
                  ),
                  if (book.baslik != null)
                    Padding(
                      padding: EdgeInsets.all(20),
                      child: EbookAsButton(
                        title: book.baslik!,
                        book: book,
                      ),
                    ),
                ],
              ),

              SizedBox(
                height: 50,
              ),

              ImageSlider(
                  imageList: (book.fotograflar?.isEmpty ?? true)
                      ? [Service.config.DefaultImageURL]
                      : book.fotograflar!
                          .map((e) => ServerURL.normalized(e))
                          .toList(growable: false)),

              SizedBox(
                //width: 200,
                height: 20,
              ),

              SizedBox(
                height: 500,
                // padding: EdgeInsets.all(20),
                // alignment: Alignment.centerLeft,
                child: RedirectableRichText(list: {
                  "Dil:${(book.dil ?? "bilinmiyor").replaceFirst("t", "T")}":
                      (ctx, _) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => BookSearch(
                                mkey: "dil", value: book.dil ?? "")));
                  },
                  "\nYazar:${book.yazar ?? 'bilinmiyor'}": (ctx, _) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => BookSearch(
                                mkey: "yazar", value: book.yazar ?? "")));
                  },
                  "\nYayın Evi:${book.yayinEvi ?? 'bilinmiyor'}": (ctx, _) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => BookSearch(
                                mkey: "yayinevi", value: book.yayinEvi ?? "")));
                  },
                  "\nBasım yılı:${book.basimYili}": null,
                  //"\nFonksiyon çağırmayan bir yazı!": null,
                  "\nKatagori:${(book.katagoriler ?? []).join(': ')}":
                      (ctx, key) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => BookSearch(
                                mkey: "katagori", value: key.trim())));
                  },
                  "\nSayfa sayısı: ${book.sayfaSayisi ?? 0}": null,
                }),
              ),

              // ImageSlider(
              //     imageList: (book.fotograflar?.isEmpty ?? true)
              //         ? [Service.config.DefaultImageURL]
              //         : book.fotograflar!
              //             .map((e) => ServerURL.normalized(e))
              //             .toList(growable: false)),
              if (book.katagoriler != null && book.katagoriler!.isNotEmpty)
                BooksView(title: "Benzer", bookquery: {
                  "katagori": book.katagoriler!.first,
                  "adet": "20",
                  "yeni": "true",
                }),
              if (book.yazar != null && book.yazar!.isNotEmpty)
                BooksView(title: book.yazar! + " daha çok eser", bookquery: {
                  "yazar": book.yazar!,
                  "adet": "20",
                  "yeni": "true",
                }),
            ],
          ),
        ),
        //     ),
        //     /*ImageSlider(
        //         imageList: (book.fotograflar?.isEmpty ?? true)
        //             ? [ServiceConfig.defaultImageURL]
        //             : book.fotograflar!
        //                 .map((e) => apiImageControlled(e))
        //                 .toList(growable: false)),*/
        //   ],
        // ),
      ),
    );
  }
}
