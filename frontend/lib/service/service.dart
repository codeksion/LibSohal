import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';

part 'service.g.dart';

@HiveType(typeId: 0)
class Config {
  @HiveField(0)
  late String ApiURL;

  @HiveField(1)
  late String DefaultImageURL;

  Config({required this.ApiURL, required this.DefaultImageURL});

  Config.defaultConfig() {
    ApiURL = "https://libsohal.codeksion.net"; // Type your server ip
    DefaultImageURL = "https://cdn.codeksion.net/book_2300x1500.gif";
  }

  Map<String, dynamic> toJson() {
    return {
      "ApiURL": ApiURL,
      "DefaultImageURL": DefaultImageURL,
    };
  }

  Config.fromJson(Map<String, dynamic> json) {
    ApiURL = json["ApiURL"];
    DefaultImageURL = json["DefaultImageURL"];
  }
}

// class ConfigAdaptor extends TypeAdapter<Config> {
//   @override
//   final typeId = 0;

//   @override
//   Config read(BinaryReader reader) {
//     return Config.fromJson(reader.read());
//   }

//   @override
//   void write(BinaryWriter writer, Config obj) {
//     writer.write(obj.toJson());
//   }
// }

class Service {
  static late Config config;
  static bool inited = false;

  Future<void> init() async {
    print("init ediliyor");
    WidgetsFlutterBinding.ensureInitialized();
    await Future.delayed(Duration(seconds: 1));
    if (inited) {
      return;
    }

    Hive.registerAdapter(ConfigAdapter());
    await Hive.initFlutter(".");

    var bcfg = await Hive.openBox<Config>("config");

    print("get-config: ${bcfg.get("config")}");

    if (bcfg.isEmpty) {
      print("default config using");
      config = Config.defaultConfig();
    } else {
      config = (bcfg.get("config") ?? Config.defaultConfig());
    }
    await writeConfig();
    inited = true;
  }

  static Future<void> writeConfig() async {
    print("writing config");
    var box = Hive.box<Config>("config");
    // if (box.isEmpty) {
    //   return box.add(config);
    // }

    print(config.toJson());

    await box.put("config", config);
    await box.flush();

    print('await box.get("config"): ${await box.get("config")}');

    print("writed");
  }

  Widget initWidget({required Widget redirect}) {
    return Scaffold(
      body: FutureBuilder(
        future: Service().init(),
        builder: (context, snapshot) {
          print(snapshot.connectionState.name);
          if (snapshot.connectionState == ConnectionState.done) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => redirect,
                  ),
                  (route) => false);
            });
          }

          if (snapshot.hasError) {
            print(snapshot.error);
            return Center(
              child: Text("Error: ${snapshot.error}"),
            );
          }

          return Center(
            child: CircularProgressIndicator(
              color: Colors.orange,
            ),
          );
        },
      ),
    );
  }
}
