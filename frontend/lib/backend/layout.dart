class Books {
  int? total_items;
  List<Book>? books;

  Books({this.total_items, this.books});

  Books.fromJson(Map<String, dynamic> json) {
    total_items = json["total_items"];
    //books = (json["books"] ?? []).cast<Book>();
    if (json["books"] != null) {
      books = <Book>[];
      json['books'].forEach((v) {
        books!.add(Book.fromJson(v));
      });
    }
  }
}

class Book {
  String? id;
  String? baslik;
  String? yazar;
  String? dil;
  int? sayfaSayisi;
  int? adet;
  List<String>? katagoriler;
  String? yayinEvi;
  String? basimYili;
  KitapKonumu? kitapKonumu;
  List<String>? fotograflar;
  String? tag;
  String? ozet;
  //bool? borrowable;

  Book({
    this.id,
    this.baslik,
    this.yazar,
    this.dil,
    this.sayfaSayisi,
    this.adet,
    this.katagoriler,
    this.yayinEvi,
    this.basimYili,
    this.kitapKonumu,
    this.fotograflar,
    this.tag,
    this.ozet,
    //this.borrowable,
  });

  Book.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    baslik = json['baslik'];
    yazar = json['yazar'];
    dil = json['dil'];
    sayfaSayisi = json['sayfa_sayisi'];
    adet = json['adet'];
    katagoriler = (json['katagoriler'] ??= []).cast<String>();
    yayinEvi = json['yayin_evi'];
    basimYili = json['basim_yili'];
    kitapKonumu = json['kitap_konumu'] != null
        ? KitapKonumu.fromJson(json['kitap_konumu'])
        : null;
    //fotograflar = json['fotograflar'].cast<String>();
    fotograflar = (json['fotograflar'] ??= []).cast<String>();
    tag = json['tag'];
    ozet = json["ozet"];
    //borrowable = json["borrowable"];
  }

  bool contains(List<Book> list) {
    for (var i in list) {
      if (i.id == id) {
        return true;
      }
    }
    return false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['id'] = id;
    data['baslik'] = baslik;
    data['yazar'] = yazar;
    data['dil'] = dil;
    data['sayfa_sayisi'] = sayfaSayisi;
    data['adet'] = adet;
    data['katagoriler'] = katagoriler;
    data['yayin_evi'] = yayinEvi;
    data['basim_yili'] = basimYili;
    if (kitapKonumu != null) {
      data['kitap_konumu'] = kitapKonumu!.toJson();
    }
    data['fotograflar'] = fotograflar;
    data['tag'] = tag;
    data["ozet"] = ozet;
    //data["borrowable"] = borrowable;
    return data;
  }

  static List<Book> fromApiResponse(dynamic value) {
    List<Book> list = [];
    for (var i in value) {
      list.add(Book.fromJson(i));
    }
    return list;
  }
}

class KitapKonumu {
  String? sira;
  String? sutun;

  KitapKonumu({this.sira, this.sutun});

  KitapKonumu.fromJson(Map<String, dynamic> json) {
    sira = json['sira'];
    sutun = json['sutun'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['sira'] = sira;
    data['sutun'] = sutun;
    return data;
  }

  String toPretty() {
    return "Sıra: $sira\nSütun: $sutun";
  }
}
