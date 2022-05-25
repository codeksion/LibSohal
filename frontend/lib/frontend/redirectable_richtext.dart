import 'package:flag/flag_widget.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

const countryCodes = <String, String>{
  "Türkçe": "tr",
  //
  "English": "en",
  "İngilizce": "en",
  "Ingilizce": "en",
  //
  "Almanca": "de",
  "Germany": "de",
  "Deutschland": "de",
  //
};

class RedirectableRichText extends StatelessWidget {
  final Map<String, Function(BuildContext, String)?>
      list; // Yayın evi: <Yayin evi>
  //final Map<String, Widget> list; // Yayın evi: <Yayin evi>
  const RedirectableRichText({Key? key, required this.list}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final key = list.keys;
    final values = list.values;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List<Widget>.generate(list.length, (index) {
        final anahtar = key.elementAt(index);
        final ederi = values.elementAt(index);
        final split = anahtar.split(":");

        if (ederi == null) {
          return ListTile(
            title: Text(
              split[0],
            ),
            subtitle: (split.isEmpty)
                ? null
                : SizedBox(
                    //height: 30,
                    width: 100,
                    child: SingleChildScrollView(
                        child: Row(
                      children: List.generate(split.length - 1, (index) {
                        index++;

                        return Chip(
                          avatar: countryCodes.containsKey(split[index])
                              ? Flag.fromString(
                                      countryCodes[split[index]] ?? "")
                                  .build(context)
                              : CircleAvatar(
                                  backgroundColor: Color(
                                          (math.Random().nextDouble() *
                                                  0xFFFFFF)
                                              .toInt())
                                      .withOpacity(1),
                                ),
                          label: Text(split[index]),
                        );
                      }),
                    )),
                  ),
          );
        } else if (!anahtar.contains(":")) {
          return ListTile(
            title: Text(anahtar),
            leading: InputChip(
              label: Text(anahtar),
              onPressed: () => ederi(context, ""),
            ),
          );
        }

        return ListTile(
          title: Text(
            anahtar.split(":").first,
            textAlign: TextAlign.start,
          ),
          subtitle: SizedBox(
            //height: 30,
            width: 100,
            child: SingleChildScrollView(
                child: Row(
              children: List.generate(split.length - 1, (index) {
                index++;

                return InputChip(
                  avatar: countryCodes.containsKey(split[index])
                      ? Flag.fromString(countryCodes[split[index]] ?? "")
                          .build(context)
                      : CircleAvatar(
                          backgroundColor: Color(
                                  (math.Random().nextDouble() * 0xFFFFFF)
                                      .toInt())
                              .withOpacity(1),
                        ),
                  label: Text(split[index]),
                  onPressed: () => ederi(context, split[index]),
                );
              }),
            )),
          ),
        );
      }),
    );
  }
}

/*[
        WidgetSpan(
            child: InkWell(
          onTap: () {
            ederi(context);
          },
          child: RichText(
              text: TextSpan(
                  text: split[1], style: TextStyle(color: Colors.orange))),
        )),
      ] */
