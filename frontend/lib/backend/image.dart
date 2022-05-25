import 'package:flutter/painting.dart';
import 'package:sohal_kutuphane/service/service.dart';

// String apiImageControlled(String image) {
//   print("ApiImageControlled: ${image}");

//   if (image == "") return Service.config.DefaultImageURL;

//   if (image.startsWith("/")) return Service.config.ApiURL + image;

//   return image;
// }

// String apiImageControlledLIST(List<String>? list) {
//   return apiImageControlled(((list == null || list.isEmpty) ? "" : list.first));
// }

String toStaticImage(String path) {
  return Service.config.ApiURL + "/static/" + path;
}

String imageURLServer(String _url) {
  if (_url == "") return imageURLServer(Service.config.DefaultImageURL);
  return (ServerURL.isHttp(_url)) ? _url : toStaticImage(_url);
}

class ServerURL {
  String url;
  ServerURL(this.url);

  static String normalizedList(List<String>? list) {
    return normalized((list ??= []).isEmpty ? "" : list.first);
  }

  static bool isHttp(String path) {
    return (path.startsWith("http://") || path.startsWith("https://"));
  }

  static String normalized(String _url) {
    if (_url == "") return ServerURL.normalized(Service.config.DefaultImageURL);
    var yanit = (isHttp(_url)) ? _url : toStaticImage(_url);

    return yanit;
  }

  String get static => Service.config.ApiURL + "/static/" + url;
  ImageProvider get image => NetworkImage(ServerURL.normalized(url));
}
