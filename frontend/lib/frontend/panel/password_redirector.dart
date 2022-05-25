import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class PasswordRedirector extends StatefulWidget {
  final Widget redirect;
  final String password;
  const PasswordRedirector({
    Key? key,
    required this.redirect,
    required this.password,
  }) : super(key: key);

  @override
  _PasswordRedirectorState createState() => _PasswordRedirectorState();
}

class _PasswordRedirectorState extends State<PasswordRedirector> {
  String value = "";
  void ondone(BuildContext context) async {
    if (value == widget.password) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => widget.redirect,
          ),
          (route) => true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Stack(
        // crossAxisAlignment: CrossAxisAlignment.center,
        // mainAxisAlignment: MainAxisAlignment.center,
        // mainAxisSize: MainAxisSize.min,
        children: [
          Center(
              child: LottieBuilder.asset(
            "assets/images/password.json",
            fit: BoxFit.fill,
            alignment: Alignment.center,
          )),
          Center(
              child: Container(
            height: 50,
            padding: EdgeInsets.only(left: 60, right: 60),
            child: Card(
                child: Row(
              children: [
                Flexible(
                  child: TextField(
                    obscureText: true,
                    autofocus: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Admin password",
                      contentPadding: EdgeInsets.only(left: 20, right: 20),
                    ),
                    onChanged: (v) {
                      value = v;
                    },
                    onSubmitted: (_) => ondone(context),
                    onEditingComplete: () => ondone(context),
                  ),
                ),
                IconButton(
                    onPressed: () {
                      ondone(context);
                    },
                    icon: Icon(Icons.send_rounded))
              ],
            )),
          )),
        ],
      ),
    );
  }
}
