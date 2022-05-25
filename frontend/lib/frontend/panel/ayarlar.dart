import 'package:flutter/material.dart';
import 'package:progress_state_button/iconed_button.dart';
import 'package:progress_state_button/progress_button.dart';
import 'package:sohal_kutuphane/service/service.dart';

class Ayarlar extends StatefulWidget {
  const Ayarlar({Key? key}) : super(key: key);

  @override
  _AyarlarState createState() => _AyarlarState();
}

class _AyarlarState extends State<Ayarlar> {
  var formkey = GlobalKey<FormState>();
  var clone = Service.config.toJson();
  Map<String, GlobalKey> clonekey = {
    for (var i in Service.config.toJson().keys) i: GlobalKey<FormState>()
  };

  Widget input(String text, Widget child,
          {double height = 50, double width = 150}) =>
      Container(
        padding: EdgeInsets.all(5),
        height: height,
        child: Row(
          children: [
            //Flexible(
            //child:
            SizedBox(
              width: width,
              child: Text(
                text,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            //flex: 0,
            //),
            Expanded(
              child: child,
              flex: 4,
            ),
          ],
        ),
      );

  List<Widget> configToList() {
    var widgetlist = <Widget>[];

    Service.config.toJson().forEach((key, value) {
      widgetlist.add(input(
          key,
          TextFormField(
            key: clonekey[key],
            initialValue: value,
            onSaved: (v) {
              clone[key] = v;
            },
          )));
    });

    return widgetlist;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Ayarlar"),
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: Form(
          key: formkey,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: configToList()

              //children:   ,
              ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (formkey.currentState!.validate()) {
            formkey.currentState!.save();
            Service.config = Config.fromJson(clone);

            Service.writeConfig()
                .then((value) => ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text("Kayıt edildi!"))))
                .catchError((e) {
              print("config set error: $e");
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Config set-error: $e")));
            });
          }
        },
        child: Icon(Icons.save),
        tooltip: "Kaydet",
      ),
    );
  }
}
