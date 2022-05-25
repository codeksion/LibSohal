import 'package:sohal_kutuphane/backend/request.dart';

class Borrowable {
  String? error;
  bool? borrowable;

  Borrowable({this.error, this.borrowable});

  Borrowable.fromJson(dynamic value) {
    error = value["error"];
    borrowable = value["borrowable"];
  }
}

Future<Borrowable> apiRequestBorrowable(String bookid) async {
  try {
    return Borrowable.fromJson(await requestAPIJson(
        "/borrowable?book_id=" + bookid,
        nan200Error: true));
  } catch (e) {
    return Borrowable(error: e.toString());
  }
}
