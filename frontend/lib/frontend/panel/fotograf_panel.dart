import 'package:flutter/material.dart';

class FotografPanel extends StatefulWidget {
  final void Function(int)? onRemoved;
  final void Function(int, int)? onIndexChanged;
  final void Function(String)? onNewPhoto;
  List<ImageProvider> seed;

  FotografPanel(
      {Key? key,
      required this.seed,
      this.onRemoved,
      this.onNewPhoto,
      this.onIndexChanged})
      : super(key: key);

  @override
  _FotografPanelState createState() => _FotografPanelState();
}

class _FotografPanelState extends State<FotografPanel> {
  @override
  void dispose() {
    super.dispose();
    widget.seed.clear();
  }

  @override
  void initState() {
    super.initState();
  }

  Widget removeableImage(void Function() press, int index) => Stack(
        key: ValueKey(index),
        children: [
          Image(
            image: widget.seed[index],
            //fit: BoxFit.contain,
          ),
          Positioned(
              bottom: 1,
              right: 1,
              child: IconButton(
                enableFeedback: false,
                onPressed: press,
                icon: Icon(Icons.cancel),
              )),
        ],
      );

  @override
  Widget build(BuildContext context) {
    return ReorderableListView.builder(
      //shrinkWrap: true,
      onReorder: (i, i2) {
        var iv = widget.seed[i];
        var i2v = widget.seed[i2];

        setState(() {
          widget.seed[i] = i2v;
          widget.seed[i2] = iv;
        });
      },
      itemCount: widget.seed.length,
      scrollDirection: Axis.horizontal,
      itemBuilder: (_, i) => SizedBox(
        height: 200,
        width: 200,
        key: ValueKey(i),
        child: removeableImage(() {
          if (widget.onRemoved != null) widget.onRemoved!(i);
          setState(() {
            widget.seed.removeAt(i);
          });
        }, i),
      ),
    );
  }
}
