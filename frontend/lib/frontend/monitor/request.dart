import 'package:sohal_kutuphane/backend/monitor.dart';
import 'package:sohal_kutuphane/backend/request.dart';

Future<Monitor?> requestMonitor(String authkey) async {
  var resp = await requestAPIJson(
    "/yetkili/monitor",
    nan200Error: true,
    headers: {"PW": authkey},
  );
  return Monitor.fromJson(resp);
}
