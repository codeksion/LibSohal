import 'package:flutter/material.dart';
import 'package:sohal_kutuphane/backend/layout.dart';
import 'package:sohal_kutuphane/backend/test.dart' as backtest;

class TestBookRequest extends StatefulWidget {
  const TestBookRequest({Key? key}) : super(key: key);

  @override
  _TestBookRequestState createState() => _TestBookRequestState();
}

class _TestBookRequestState extends State<TestBookRequest> {
  //List<Book>? list;
  bool requested = false;
  bool? success;
  String? error;

  void test() async {
    try {
      backtest.test();
      success = true;
    } catch (e) {
      error = e.toString();
    }

    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    test();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        child: (success!) ? Text("Başarılı!") : Text("Hata: $error"),
      ),
    );
  }
}
