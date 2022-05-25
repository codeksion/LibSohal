import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sohal_kutuphane/backend/image.dart';
import 'package:sohal_kutuphane/backend/layout.dart';
import 'package:sohal_kutuphane/backend/utils.dart';
import 'package:sohal_kutuphane/frontend/book_details.dart';

class ViewBookListGrid extends StatelessWidget {
  final List<Book> list;
  final bool neverScroll;
  /*final double height;

  final double width;*/

  const ViewBookListGrid({
    Key? key,
    required this.list /*, required this.height, required this.width*/,
    this.neverScroll = false,
  }) : super(key: key);

  List<Widget> getList(BuildContext context) {
    List<Widget> listother = [];
    for (var kitap in list) {
      var herokey = getRandomString(9);
      listother.add(Container(
        padding: EdgeInsets.all(2),
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
                            book: kitap,
                            herokey: herokey,
                          )));
            },
            child: Stack(
              children: [
                Hero(
                    tag: getHeroTag(kitap, herokey),
                    child: Material(
                      child: Ink.image(
                          fit: BoxFit.cover,
                          image: NetworkImage(ServerURL.normalized(
                              (kitap.fotograflar != null &&
                                      kitap.fotograflar!.isNotEmpty)
                                  ? kitap.fotograflar!.first
                                  : ""))),
                    )),

                //TODO
                Positioned(
                    child: Opacity(
                  opacity: 0.5,
                  child: Container(
                    height: 40,
                    width: 900,
                    color: Colors.black,
                    child: Center(
                      child: Text(
                        "${kitap.baslik}",
                        textAlign: TextAlign.center,
                        //overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                )),
              ],
            ),
          ),
        ),
      ));
    }

    return listother;
  }

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      physics: (neverScroll) ? NeverScrollableScrollPhysics() : null,
      shrinkWrap: true,
      children: getList(context),
      crossAxisCount: (MediaQuery.of(context).size.width ~/ 170),
    );
  }
}
