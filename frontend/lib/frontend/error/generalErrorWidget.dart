import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:sohal_kutuphane/frontend/panel/ayarlar.dart';
import 'package:sohal_kutuphane/frontend/panel/password_redirector.dart';

class GeneralErrorWidget extends StatefulWidget {
  final dynamic error;
  final String errorTip;
  final bool showOfflineSettingsButton;
  final double? height, width;
  const GeneralErrorWidget({
    Key? key,
    this.error,
    this.height,
    this.width,
    this.errorTip = "Unexcepted error catched: ",
    this.showOfflineSettingsButton = false,
  }) : super(key: key);

  @override
  _GeneralErrorWidgetState createState() => _GeneralErrorWidgetState();
}

class _GeneralErrorWidgetState extends State<GeneralErrorWidget> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      width: widget.width,
      child: Stack(
        children: [
          // Ink.image(
          //     image: AssetImage("assets/images/error.gif"), fit: BoxFit.cover),
          LottieBuilder.asset(
            "assets/images/error.json",
            alignment: Alignment.topRight,
            fit: BoxFit.cover,
          ),

          Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Text("${widget.errorTip}${widget.error ?? ''}",
                      textAlign: TextAlign.center),
                ),
                if (widget.showOfflineSettingsButton)
                  IconButton(
                      onPressed: () {
                        Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (context) => PasswordRedirector(
                                    redirect: Ayarlar(),
                                    password: "merhabadunya")),
                            (route) => true);
                      },
                      icon: Icon(
                        Icons.offline_bolt,
                        size: 30,
                      ))
              ],
            ),
          ),
        ],
      ),
    );
  }
}
