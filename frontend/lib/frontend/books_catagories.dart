import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sohal_kutuphane/backend/request.dart';
import 'package:sohal_kutuphane/frontend/books_search.dart';
import 'dart:math' as math;

class BookCatagories extends StatefulWidget {
  BookCatagories({Key? key}) : super(key: key);

  List<String> list = [];

  @override
  _BookCatagoriesState createState() => _BookCatagoriesState();
}

class _BookCatagoriesState extends State<BookCatagories> {
  void setCatagories() {
    requestAPI("/catagories").then((value) {
      widget.list = value.body.split(",");
      //print("widget.list = ${widget.list}");
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void initState() {
    () async {
      setCatagories();

      while (mounted) {
        //print("while ");
        await Future.delayed(Duration(minutes: 1));
        setCatagories();
      }
    }();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BookCatagorieButtons(list: widget.list);
  }
}

class BookCatagorieButtons extends StatelessWidget {
  final List<String> list;
  const BookCatagorieButtons({Key? key, required this.list}) : super(key: key);

  static Widget button2(BuildContext context, String cat) => InputChip(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      BookSearch(mkey: "katagori", value: cat)));
        },
        label: Text(cat),
        avatar: CircleAvatar(
          backgroundColor:
              Color((math.Random().nextDouble() * 0xFFFFFF).toInt())
                  .withOpacity(1),
        ),
      );

  static Widget button(BuildContext context, String cat) => Padding(
        padding: EdgeInsets.only(right: 3),
        child: TextButton(
          clipBehavior: Clip.antiAlias,
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        BookSearch(mkey: "katagori", value: cat)));
          },
          child: Text(cat, style: const TextStyle(color: Colors.white)),
          style: ButtonStyle(
              shape: MaterialStateProperty.all(RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(7),
              )),
              backgroundColor: MaterialStateProperty.all(Color(
                      (math.Random().nextDouble() * 0xFFFFFF)
                          .toInt()) //stackoverflow random color generator
                  .withOpacity(1.0))),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment.center,
        height: 30,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: List<Widget>.generate(list.length,
                (index) => BookCatagorieButtons.button2(context, list[index])),
          ),
        ));
  }
}
