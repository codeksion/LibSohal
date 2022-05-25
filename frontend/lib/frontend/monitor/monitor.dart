import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:sohal_kutuphane/backend/monitor.dart';
import 'package:sohal_kutuphane/frontend/monitor/request.dart';
import 'package:visibility_aware_state/visibility_aware_state.dart';

class MonitorWidget extends StatefulWidget {
  final String authkey;
  const MonitorWidget({
    Key? key,
    required this.authkey,
  }) : super(key: key);

  @override
  _MonitorState createState() => _MonitorState();
}

class _MonitorState extends /*VisibilityAwareState*/ State<MonitorWidget> {
  Monitor? monitorvalue;
  bool yeahContiuneToRequest = true;

  // @override
  // void onVisibilityChanged(WidgetVisibility visibility) {
  //   print("visit:  ${visibility.name}");

  //   super.onVisibilityChanged(visibility);
  // }

  @override
  void initState() {
    () async {
      //bool errorshowed = false;
      while (mounted) {
        await Future.delayed(Duration(seconds: 3));

        if (!yeahContiuneToRequest) {
          continue;
        }

        try {
          var jmon = await requestMonitor(widget.authkey);
          if (mounted) {
            setState(() {
              monitorvalue = jmon;
            });
          }
        } catch (e) {
          print(e);

          // if (errorshowed) {
          //   //return;
          // }

          // errorshowed = true;
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text("Hata: $e")));
        }

        //print(monitorvalue!.cpuPercents);
      }
    }();

    super.initState();
  }

  Widget textedBox(
    BuildContext context, {
    String? text,
    Widget? child,
    double circular = 20,
  }) =>
      Container(
        decoration:
            BoxDecoration(borderRadius: BorderRadius.circular(circular)),
        child: Column(
          children: [
            if (child != null) child,
            if (text != null)
              Text(
                text,
                textAlign: TextAlign.center,
                softWrap: true,
                style: TextStyle(
                  fontSize: 15,
                ),
              ),
          ],
          mainAxisSize: MainAxisSize.min,
        ),
      );
  num ortalama(List<num> list) {
    num total = 0;

    for (var i in list) {
      total += i;
    }

    return (total / list.length);
  }

  @override
  Widget build(BuildContext context) => (monitorvalue == null)
      ? Container()
      : SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              textedBox(context,
                  text: "Server CPU Usage",
                  child: Stack(
                    //fit: StackFit.expand,
                    alignment: Alignment.center,
                    children: [
                      Center(
                        child: Text(ortalama(monitorvalue!.cpuPercents ?? [])
                                .toStringAsFixed(2) +
                            " %"),
                      ),
                      SfCircularChart(
                        //backgroundColor: Color.fromARGB(255, 109, 30, 30),
                        series: <CircularSeries>[
                          RadialBarSeries(
                            innerRadius: "40",

                            dataSource: monitorvalue!.cpuPercents,
                            xValueMapper: (e, int i) => (e is double) ? e : 0,
                            yValueMapper: (e, int i) => (e is double) ? e : 0,
                            maximumValue: 100,
                            //cornerStyle: CornerStyle,
                            gap: "3",
                            //radius: "500",
                            pointColorMapper: (dynamic d, int index) {
                              if (d > 60) {
                                return Colors.red;
                              } else if (d > 40) {
                                return Colors.orange;
                              } else if (d > 20) {
                                return Colors.blue;
                              }

                              return Colors.green;
                            },

                            name: "Server Cpu Usage",
                            legendIconType: LegendIconType.diamond,
                            enableTooltip: true,
                          ),
                        ],
                      )
                    ],
                  )),
              textedBox(context,
                  text: "Server Memory Usage",
                  child: SfCircularChart(
                    series: <CircularSeries>[
                      PieSeries(
                        enableTooltip: true,
                        explode: true,
                        dataSource: [
                          ChartZort(
                              value: monitorvalue?.memory?.total,
                              color: Colors.cyan,
                              text:
                                  "Toplam ${((monitorvalue?.memory?.total ?? 0) / 1024 / 1024 / 1024).toStringAsFixed(2)} GB"),
                          ChartZort(
                            value: monitorvalue?.memory?.used,
                            text:
                                "Kullanılan\n${((monitorvalue?.memory?.used ?? 0) / 1024 / 1024 / 1024).toStringAsFixed(2)} GB",
                          ),
                          ChartZort(
                              value: monitorvalue?.memory?.free,
                              text:
                                  "Serbest\n${((monitorvalue?.memory?.free ?? 0) / 1024 / 1024 / 1024).toStringAsFixed(2)} GB",
                              color: Colors.green),
                          /*ChartZort(
                          value: monitorvalue?.memory?.usedPercent,
                          text: "Kullanım yüzdesi"),*/
                        ],
                        xValueMapper: (d, i) => d.value,
                        yValueMapper: (d, i) => d.value,
                        dataLabelMapper: (d, _) => d.text,
                        animationDuration: 0,
                        pointColorMapper: (d, _) => d.color,
                        dataLabelSettings: DataLabelSettings(
                          isVisible: true,
                          showZeroValue: true,
                        ),
                      ),
                    ],
                  )),
              textedBox(context,
                  text: "Server Swap Memory Usage",
                  child: SfCircularChart(
                    series: <CircularSeries>[
                      PieSeries(
                        enableTooltip: true,
                        explode: true,
                        dataSource: [
                          ChartZort(
                              value: monitorvalue?.swapMemory?.total,
                              color: Colors.grey,
                              text:
                                  "Toplam ${((monitorvalue?.swapMemory?.total ?? 0) / 1024 / 1024 / 1024).toStringAsFixed(2)} GB"),
                          ChartZort(
                            value: monitorvalue?.swapMemory?.used,
                            text:
                                "Kullanılan\n${((monitorvalue?.swapMemory?.used ?? 0) / 1024 / 1024 / 1024).toStringAsFixed(2)} GB",
                            color: Colors.red,
                          ),
                          ChartZort(
                              value: monitorvalue?.swapMemory?.free,
                              text:
                                  "Serbest\n${((monitorvalue?.swapMemory?.free ?? 0) / 1024 / 1024 / 1024).toStringAsFixed(2)} GB",
                              color: Colors.amber),
                          /*ChartZort(
                          value: monitorvalue?.memory?.usedPercent,
                          text: "Kullanım yüzdesi"),*/
                        ],
                        xValueMapper: (d, i) => d.value,
                        yValueMapper: (d, i) => d.value,
                        dataLabelMapper: (d, _) => d.text,
                        animationDuration: 0,
                        pointColorMapper: (d, _) => d.color,
                        dataLabelSettings: DataLabelSettings(
                          isVisible: true,
                          showZeroValue: true,
                        ),
                      ),
                    ],
                  )),
              textedBox(context,
                  text: "Api Memory Usage",
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Center(
                        child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                                text: "GO: ${monitorvalue?.numGoroutine}",
                                style: TextStyle(fontSize: 17),
                                children: [
                                  TextSpan(
                                    text:
                                        "\nGC: ${monitorvalue?.apiUsage?.numGc}",
                                    style: TextStyle(fontSize: 10),
                                  )
                                ])),
                      ),
                      SfCircularChart(
                        series: <CircularSeries>[
                          DoughnutSeries(
                            enableTooltip: true,
                            explodeAll: false,
                            explode: false,
                            //innerRadius: "50",
                            dataSource: [
                              ChartZort(
                                value: monitorvalue?.memory?.free,
                                text:
                                    "Kullanılabilir\n${(((monitorvalue?.swapMemory?.free ?? 0) + (monitorvalue?.memory?.free ?? 0)) / 1024 / 1024 / 1024).toStringAsFixed(2)} GB",
                                //  color: Colors.lightGreen,
                              ),
                              ChartZort(
                                value: (monitorvalue?.apiUsage?.alloc),
                                text:
                                    "Kullanılan\n ${((monitorvalue?.apiUsage?.alloc ?? 0) / 1024 / 1024).toStringAsFixed(2)} MB",
                              ),
                            ],
                            xValueMapper: (d, i) => d.value,
                            yValueMapper: (d, i) => d.value,
                            dataLabelMapper: (d, _) => d.text,
                            animationDuration: 0,
                            pointColorMapper: (d, _) => d.color,

                            dataLabelSettings: DataLabelSettings(
                              //labelAlignment: ChartDataLabelAlignment.top,

                              textStyle:
                                  TextStyle(color: Colors.white, fontSize: 16),
                              //labelPosition: ChartDataLabelPosition.inside,

                              isVisible: true,
                              showZeroValue: true,
                            ),
                          ),
                        ],
                      )
                    ],
                  )),
            ],
            //),
          ));
}

class ChartZort {
  final num? value;
  final Color? color;
  final String? text;
  ChartZort({this.value = 0, this.color, this.text});
}
