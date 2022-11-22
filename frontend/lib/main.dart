import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';

import 'package:sohal_kutuphane/home.dart';
import 'package:sohal_kutuphane/service/service.dart';

void main() {
  runApp(MaterialApp(
    theme: FlexColorScheme.dark().toTheme,
    //theme: ThemeData.dark(),
    debugShowCheckedModeBanner: false,
    //initialRoute: "/",
    home: Service().initWidget(redirect: Home()),
    title: "SOHAL E-Kütüphane",
  ));
}
