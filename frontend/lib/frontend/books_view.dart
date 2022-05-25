import 'dart:async';

import 'package:delayed_display/delayed_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:lottie/lottie.dart';
import 'package:skeleton_animation/skeleton_animation.dart';
import 'package:sohal_kutuphane/backend/image.dart';
import 'package:sohal_kutuphane/backend/layout.dart';
import 'package:sohal_kutuphane/backend/request.dart';
import 'package:sohal_kutuphane/backend/utils.dart';
import 'package:sohal_kutuphane/frontend/book_details.dart';
import 'package:sohal_kutuphane/frontend/books_grid_view.dart';
import 'package:sohal_kutuphane/frontend/error/generalErrorWidget.dart';

class BooksView extends StatefulWidget {
  final String title;
  final Map<String, dynamic> bookquery;
  final String? errorText;
  final Widget Function(BuildContext, String)? errorWidget;
  final Widget? addErrorWidget;
  final bool neverScroll;
  final ScrollController? scrollController;
  final bool grid;
  final Duration? otoRefresh;

  int sayfa = 1;

  BooksView({
    Key? key,
    required this.title,
    required this.bookquery,
    this.errorText,
    this.addErrorWidget,
    this.errorWidget,
    this.grid = false,
    this.neverScroll = false,
    this.scrollController,
    this.otoRefresh,
  }) : super(key: key) {
    if (bookquery.containsKey("_sayfa")) {
      sayfa = bookquery["_sayfa"];
      bookquery.remove("_sayfa");
    }

    if (!bookquery.containsKey("adet")) {
      bookquery["adet"] = "20";
    }
  }
  @override
  _BooksViewState createState() => _BooksViewState();
}

class _BooksViewState extends State<BooksView> {
  String? error;
  List<Book>? booklist;
  int total_items = 0;
  Timer? timer;

  void _getbooks() async {
    widget.bookquery["sayfa"] = widget.sayfa.toString();
    try {
      var yenit = await getBooks(widget.bookquery);
      //print("new request length: ${yenit.books?.length}");
      total_items = yenit.total_items ?? 0;
      //print("totalitems: $total_items");
      booklist ??= [];

      for (var i in (yenit.books ?? <Book>[])) {
        //if (!booklist!.contains(i)) booklist!.add(i);
        if (!i.contains(booklist!)) {
          booklist!.add(i);
        }
      }

      //widget.booklist!.addAll(yenit);

      error = null;
    } catch (e, a) {
      print("getbooks error: ${e} trace: ${a}");

      error = (widget.errorText == null)
          ? e.toString()
          : widget.errorText; // + " trace: " + a.toString();
    }

    setState(() {});
  }

  @override
  void initState() {
    //print("initState books_view");
    super.initState();
    _getbooks();

    if (widget.otoRefresh != null) {
      timer = Timer.periodic(widget.otoRefresh!, (timer) {
        _getbooks();
      });
    }
  }

  @override
  void dispose() {
    super.dispose();

    if (timer != null) timer!.cancel();
  }

  //Widget errorWidget(BuildContext context) =>

  @override
  Widget build(BuildContext context) {
    if (error != null) {
      return (widget.errorWidget != null)
          ? widget.errorWidget!(context, error!)
          : GeneralErrorWidget(
              error: error,
            );
      // : Container(
      //     height: MediaQuery.of(context).size.height,
      //     child: Stack(
      //       children: [
      //         Ink.image(
      //           image: AssetImage("assets/images/error.gif"),
      //           fit: BoxFit.cover,
      //         ),
      //         Center(
      //           child: Text(
      //             error.toString(),
      //             textAlign: TextAlign.center,
      //             style: TextStyle(fontSize: 50),
      //           ),
      //         ),
      //         if (widget.addErrorWidget != null) widget.addErrorWidget!,
      //       ],
      //     ),
      //   );

    } else if (booklist != null) {
      var ek = (booklist!.length <
          total_items); // //widget.sayfa * int.parse(widget.bookquery["adet"]

      // print("total book length: ${booklist!.length}");
      // print("show more button state: $ek");
      return DelayedDisplay(
          // fadeIn: true,
          // fadingDuration: Duration(milliseconds: 100),
          slidingBeginOffset: (widget.grid) ? Offset(0, 0.35) : Offset(0.35, 0),
          child: ListTile(
            title: Text(
              widget.title,
              style: const TextStyle(
                  fontSize: 20,
                  fontStyle: FontStyle.normal,
                  fontFamily: "mint"),
              textAlign: TextAlign.start,
            ),
            subtitle: SizedBox(
              height: (widget.grid) ? null : 200,
              //width: 200,
              child: (widget.grid)
                  ? Column(
                      children: [
                        ViewBookListGrid(
                          neverScroll: widget.neverScroll,
                          list: booklist!,
                        ),
                        if (ek)
                          TextButton(
                              onPressed: () {
                                widget.sayfa++;
                                _getbooks();
                              },
                              child: Text("Daha fazlasını getir!")),
                      ],
                    )
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          ViewBooksListView(
                              list: booklist!, heiht: 200, width: 200),
                          if (ek)
                            TextButton(
                                onPressed: () {
                                  widget.sayfa++;
                                  _getbooks();
                                },
                                child: Container(
                                  height: 200,
                                  width: 100,
                                  child: Center(
                                    child: Text("Data fazlasını görüntüle"),
                                  ),
                                ))
                        ],
                      ),
                    ),
              //)
            ),
          ));
    } else {
      // return Skeleton(
      //   height: 200,
      //   style: SkeletonStyle.box,
      //   //animation: SkeletonAnimation.pulse,
      // );
      return Center(
        child: LottieBuilder.asset(
          "assets/images/loading.json",
          height: (widget.grid) ? null : 230,
        ),
      );
    }
  }
}

class ViewBooksListView extends StatelessWidget {
  final List<Book> list;
  double heiht;
  double width;
  bool neverScroll;

  ViewBooksListView({
    Key? key,
    required this.list,
    required this.heiht,
    required this.width,
    this.neverScroll = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    /*return Container(
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 4),
      height: heiht,
      width: width,
      //alignment: Alignment.center,

      child: */
    return ListView.builder(
      physics: (neverScroll)
          ? AlwaysScrollableScrollPhysics()
          : NeverScrollableScrollPhysics(),

      shrinkWrap: true, scrollDirection: Axis.horizontal,
      itemCount: list.length,
      itemBuilder: (context, index) {
        var herokey = getRandomString(5);
        var kitap = list[index];
        return SizedBox(
          height: heiht,
          width: width,
          child: Card(
            //margin: EdgeInsets.all(2),
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(13),
            ),
            child: InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => BookDetails(
                              book: list[index],
                              herokey: herokey,
                            )));
              },
              child: Stack(
                children: [
                  Hero(
                      tag: getHeroTag(list[index], herokey),
                      child: Material(
                        child: Ink.image(
                            /*colorFilter: ColorFilter.mode(
                                Colors.black54, BlendMode.difference),*/ //TODO
                            fit: BoxFit.cover,
                            image: NetworkImage(ServerURL.normalized(
                                (kitap.fotograflar != null &&
                                        kitap.fotograflar!.isNotEmpty)
                                    ? kitap.fotograflar!.first
                                    : ""))),
                      )),
                  //TODO
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: Opacity(
                      opacity: 0.85,
                      child: Container(
                        color: Colors.black,
                        height: heiht / 5,
                        width: width,
                        child: Center(
                          child: Text(
                            "${kitap.baslik}",
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      //  ),
    );
  }
}
