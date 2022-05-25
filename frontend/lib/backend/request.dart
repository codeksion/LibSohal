import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:sohal_kutuphane/backend/book_meta.dart';
import 'package:sohal_kutuphane/backend/layout.dart';
import 'package:sohal_kutuphane/service/service.dart';

Future<http.Response> requestAPIPOST(String? path,
        {Map<String, String>? headers, Object? body}) =>
    http.post(Uri.parse(Service.config.ApiURL + (path ?? "")),
        headers: headers, body: body);

Future<http.Response> requestAPI(String? path,
        {Map<String, String>? headers}) =>
    http.get(Uri.parse(Service.config.ApiURL + (path ?? "")), headers: headers);

Future<dynamic> requestAPIJson(String? path,
    {bool nan200Error = false, Map<String, String>? headers}) async {
  print("api request|| path: ${path}");
  var response = await requestAPI(path, headers: headers);
  if (nan200Error && response.statusCode != 200) {
    throw " ${path ?? "/"} beklenmeyen hata kodu: " +
        response.statusCode.toString();
  }

  return json.decode(utf8.decode(response.bodyBytes));
}

Future<http.StreamedResponse> requestAPIPostForm(String? path,
    {bool nan200Error = false,
    Map<String, String>? headers,
    Map<String, String>? fields,
    Map<String, String>? files}) async {
  var req = http.MultipartRequest(
      "POST", Uri.parse("${Service.config.ApiURL}${path ?? "/"}"));

  req.fields.addAll(fields ?? {});
  (files ?? {}).forEach((key, value) {
    req.files
        .add(http.MultipartFile.fromBytes(key, File(value).readAsBytesSync()));
  });
  return req.send();
}

Future<Books> getBooks(Map<String, dynamic> query) async {
  return Books.fromJson(
      await requestAPIJson("/books?" + Uri(queryParameters: query).query));
}

// Future<List<Book>> getBooks(Map<String, dynamic> query) async {
//   var yanit =
//       await requestAPIJson("/books?" + Uri(queryParameters: query).query);

//   return Book.fromApiResponse(yanit);
// }

Future<BookMeta> searchBook(String query) async {
  return BookMeta.fromJson((await requestAPIJson("/bookmeta?q=" + query)));
}
