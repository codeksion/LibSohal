// class BookMeta {
//   String? title;
//   String? subtitle;
//   List<String>? authors;
//   String? publisher;
//   String? publishedDate;
//   String? description;
//   List<IndustryIdentifiers>? industryIdentifiers;
//   late ReadingModes readingModes;
//   int? pageCount;
//   String? printType;
//   //List<String>? categories; //TODO!!

//   String? maturityRating;
//   bool? allowAnonLogging;
//   String? contentVersion;
//   PanelizationSummary? panelizationSummary;
//   ImageLinks? imageLinks;
//   String? language;
//   String? previewLink;
//   String? infoLink;
//   String? canonicalVolumeLink;

//   BookMeta(
//       {this.title,
//       this.subtitle,
//       this.authors,
//       this.publisher,
//       this.publishedDate,
//       this.description,
//       this.industryIdentifiers,
//       required this.readingModes,
//       this.pageCount,
//       this.printType,
//       //this.categories,
//       this.maturityRating,
//       this.allowAnonLogging,
//       this.contentVersion,
//       this.panelizationSummary,
//       this.imageLinks,
//       this.language,
//       this.previewLink,
//       this.infoLink,
//       this.canonicalVolumeLink});

//   BookMeta.fromJson(Map<String, dynamic> json) {
//     title = json['title'];
//     subtitle = json['subtitle'];
//     authors = (json['authors'] ?? []).cast<String>();
//     publisher = json['publisher'];
//     publishedDate = json['publishedDate'];
//     description = json['description'];
//     if (json['industryIdentifiers'] != null) {
//       industryIdentifiers = <IndustryIdentifiers>[];
//       json['industryIdentifiers'].forEach((v) {
//         industryIdentifiers!.add(new IndustryIdentifiers.fromJson(v));
//       });
//     }
//     readingModes = json['readingModes'] != null
//         ? new ReadingModes.fromJson(json['readingModes'])
//         : ReadingModes(image: false, text: false);
//     pageCount = json['pageCount'];
//     printType = json['printType'];
//     //categories = json['categories'];
//     maturityRating = json['maturityRating'];
//     allowAnonLogging = json['allowAnonLogging'];
//     contentVersion = json['contentVersion'];
//     panelizationSummary = json['panelizationSummary'] != null
//         ? new PanelizationSummary.fromJson(json['panelizationSummary'])
//         : null;
//     imageLinks = json['imageLinks'] != null
//         ? new ImageLinks.fromJson(json['imageLinks'])
//         : null;
//     language = json['language'];
//     previewLink = json['previewLink'];
//     infoLink = json['infoLink'];
//     canonicalVolumeLink = json['canonicalVolumeLink'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['title'] = this.title;
//     data['subtitle'] = this.subtitle;
//     data['authors'] = this.authors;
//     data['publisher'] = this.publisher;
//     data['publishedDate'] = this.publishedDate;
//     data['description'] = this.description;
//     if (this.industryIdentifiers != null) {
//       data['industryIdentifiers'] =
//           this.industryIdentifiers!.map((v) => v.toJson()).toList();
//     }
//     if (this.readingModes != null) {
//       data['readingModes'] = this.readingModes.toJson();
//     }
//     data['pageCount'] = this.pageCount;
//     data['printType'] = this.printType;
//     //data['categories'] = this.categories;
//     data['maturityRating'] = this.maturityRating;
//     data['allowAnonLogging'] = this.allowAnonLogging;
//     data['contentVersion'] = this.contentVersion;
//     if (this.panelizationSummary != null) {
//       data['panelizationSummary'] = this.panelizationSummary!.toJson();
//     }
//     if (this.imageLinks != null) {
//       data['imageLinks'] = this.imageLinks!.toJson();
//     }
//     data['language'] = this.language;
//     data['previewLink'] = this.previewLink;
//     data['infoLink'] = this.infoLink;
//     data['canonicalVolumeLink'] = this.canonicalVolumeLink;
//     return data;
//   }
// }

class BookMeta {
  String? source;
  String? searchQuery;
  String? title;
  String? summary;
  String? writer;
  int? pageCount;
  String? previewImageUrl;
  String? language;
  List<String>? categories;
  int? rating;
  List<String>? demoPagesUrl;
  String? publishingHouse;
  String? publishingDate;

  BookMeta(
      {this.source,
      this.searchQuery,
      this.title,
      this.summary,
      this.writer,
      this.pageCount,
      this.previewImageUrl,
      this.language,
      this.categories,
      this.rating,
      this.demoPagesUrl,
      this.publishingHouse,
      this.publishingDate});

  BookMeta.fromJson(Map<String, dynamic> json) {
    source = json['source'];
    searchQuery = json['search_query'];
    title = json['title'];
    summary = json['summary'];
    writer = json['writer'];
    pageCount = json['page_count'];
    previewImageUrl = json['preview_image_url'];
    language = json['language'];
    categories = (json['categories'] ?? <String>[]).cast<String>();
    rating = json['rating'];
    demoPagesUrl = (json['demo_pages_url'] ?? <String>[]).cast<String>();
    publishingHouse = json['publishing_house'];
    publishingDate = json['publishing_date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['source'] = source;
    data['search_query'] = searchQuery;
    data['title'] = title;
    data['summary'] = summary;
    data['writer'] = writer;
    data['page_count'] = pageCount;
    data['preview_image_url'] = previewImageUrl;
    data['language'] = language;
    data['categories'] = categories;
    data['rating'] = rating;
    data['demo_pages_url'] = demoPagesUrl;
    data['publishing_house'] = publishingHouse;
    data['publishing_date'] = publishingDate;
    return data;
  }
}

class IndustryIdentifiers {
  String? type;
  String? identifier;

  IndustryIdentifiers({this.type, this.identifier});

  IndustryIdentifiers.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    identifier = json['identifier'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['type'] = type;
    data['identifier'] = identifier;
    return data;
  }
}

class ReadingModes {
  bool? text;
  bool? image;

  ReadingModes({this.text, this.image});

  ReadingModes.fromJson(Map<String, dynamic> json) {
    text = json['text'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['text'] = text;
    data['image'] = image;
    return data;
  }
}

class PanelizationSummary {
  bool? containsEpubBubbles;
  bool? containsImageBubbles;

  PanelizationSummary({this.containsEpubBubbles, this.containsImageBubbles});

  PanelizationSummary.fromJson(Map<String, dynamic> json) {
    containsEpubBubbles = json['containsEpubBubbles'];
    containsImageBubbles = json['containsImageBubbles'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['containsEpubBubbles'] = this.containsEpubBubbles;
    data['containsImageBubbles'] = this.containsImageBubbles;
    return data;
  }
}

class ImageLinks {
  String? smallThumbnail;
  String? thumbnail;

  ImageLinks({this.smallThumbnail, this.thumbnail});

  ImageLinks.fromJson(Map<String, dynamic> json) {
    smallThumbnail = json['smallThumbnail'];
    thumbnail = json['thumbnail'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['smallThumbnail'] = this.smallThumbnail;
    data['thumbnail'] = this.thumbnail;
    return data;
  }
}
