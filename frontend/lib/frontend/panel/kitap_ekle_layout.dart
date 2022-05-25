import 'package:sohal_kutuphane/backend/layout.dart';

// class KitapEkleLayout {
//   List<String>? fotograflar;
//   bool? otoFotografEkle;
//   Book? kitap;

//   KitapEkleLayout({this.fotograflar, this.otoFotografEkle, this.kitap});

//   KitapEkleLayout.fromJson(Map<String, dynamic> json) {
//     fotograflar = json['fotograflar'];
//     otoFotografEkle = json['otoFotografEkle'];
//     kitap = json['kitap'] != null ? Book.fromJson(json['kitap']) : null;
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = {};
//     data['fotograflar'] = fotograflar;
//     data['otoFotografEkle'] = otoFotografEkle;
//     if (kitap != null) {
//       data['kitap'] = kitap!.toJson();
//     }
//     return data;
//   }
// }

class KitapEkleLayout {
  List<Fotograflar>? fotograflar;
  Book? kitap;

  KitapEkleLayout({this.fotograflar, this.kitap});

  KitapEkleLayout.fromJson(Map<String, dynamic> json) {
    if (json['fotograflar'] != null) {
      fotograflar = <Fotograflar>[];
      json['fotograflar'].forEach((v) {
        fotograflar!.add(Fotograflar.fromJson(v));
      });
    }

    kitap = json['kitap'] != null ? Book.fromJson(json['kitap']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (fotograflar != null) {
      data['fotograflar'] = fotograflar!.map((v) => v.toJson()).toList();
    }
    if (kitap != null) {
      data['kitap'] = kitap!.toJson();
    }
    return data;
  }
}

class Fotograflar {
  bool? isRemote;
  bool? isBase64;
  bool? isLocal;
  String? data;

  Fotograflar({this.isRemote, this.isBase64, this.isLocal, this.data});

  Fotograflar.fromJson(Map<String, dynamic> json) {
    isRemote = json['is_remote'];
    isBase64 = json['is_base64'];
    isLocal = json['is_local'];
    data = json['data'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['is_remote'] = isRemote;
    data['is_base64'] = isBase64;
    data['is_local'] = isLocal;
    data['data'] = this.data;
    return data;
  }
}
