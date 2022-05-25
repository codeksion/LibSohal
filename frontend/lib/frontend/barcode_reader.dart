import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

class BarcodeReader extends StatefulWidget {
  const BarcodeReader({Key? key}) : super(key: key);

  @override
  _BarcodeReaderState createState() => _BarcodeReaderState();
}

class _BarcodeReaderState extends State<BarcodeReader> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Barkot/Qr okuyucu"),
        ),
        body: Container());
  }
}
