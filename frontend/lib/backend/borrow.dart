import 'dart:convert';

import 'package:sohal_kutuphane/backend/layout.dart';
import 'package:sohal_kutuphane/backend/request.dart';

class BorrowBookRequest {
  final Book book;
  final String studentNo;
  final String type;
  final String? photopath;

  const BorrowBookRequest(
      {required this.book,
      required this.studentNo,
      required this.type,
      this.photopath});

  Future<bool> request() async {
    var yanit = await requestAPIPostForm(
      "/borrow",
      fields: {
        "type": type,
        "bookid": book.id ?? "",
        "studentno": studentNo,
      },
      nan200Error: true,
      files: (photopath != null) ? {"photo": photopath!} : null,
    );

    var jveri = await json.decode(await yanit.stream.toStringStream().first);

    if ((jveri)["error"] != null) {
      throw (jveri["error"]);
    }

    return true;
  }
}
