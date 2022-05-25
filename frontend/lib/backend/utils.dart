import 'dart:math';

import 'package:sohal_kutuphane/backend/layout.dart';

const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
Random _rnd = Random();

String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
    length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

String getHeroTag(Book context, [String ek = ""]) {
  //!!?
  return (context.id ?? "") + ek;
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1).toLowerCase()}";
  }
} // stackoverflow

String getFormatedKitapKonumu(KitapKonumu? k) {
  if (k == null || (k.sutun == null || k.sira == null))
    return "konum bilgisi yok";
  return "Sütun ${(k.sutun == null || k.sutun == "") ? 'yok' : k.sutun!} Sıra ${(k.sira == null || k.sira == "") ? 'yok' : k.sira!}";
}
