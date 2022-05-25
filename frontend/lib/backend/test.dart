import 'package:sohal_kutuphane/backend/layout.dart';
import 'package:sohal_kutuphane/backend/request.dart';

void test() async {
  print("start");
  var yanit = await requestAPIJson("/books?yeni=true", nan200Error: true);
  print(yanit);

  var parsedresponse = Book.fromApiResponse(yanit);
  print(parsedresponse);

  print("stop");
}
