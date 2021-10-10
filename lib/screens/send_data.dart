import 'dart:async';
import 'dart:convert';
import 'package:beacons_plugin/beacons_plugin.dart';
import 'package:first_project_flutter/http_service/data_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SendData extends StatefulWidget {
  String uuid;

  SendData({required this.uuid});

  @override
  _SendDataState createState() => _SendDataState();
}

class _SendDataState extends State<SendData> with WidgetsBindingObserver {
  List<String> beaconIdList = [];
  final List<String> _results = [];
  String _beaconResult = 'Not Scanned Yet.';
  String patientName = '';
  String patientTc = '';
  bool isScanning = true;

  final StreamController<String> beaconEventsController =
      StreamController<String>.broadcast();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
    WidgetsBinding.instance?.addPostFrameCallback((dur) async {
      beaconIdList = await DataService().getAllBeaconInfo();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        patientName = prefs.getString("patientName")!;
        patientTc = prefs.getString("patientTc")!;
      });
      const oneSec = Duration(seconds: 30);
      Timer.periodic(oneSec, (Timer t) => initPlatformState());
    }); //after everything uploaded run this function
  }

  Future<void> initPlatformState() async {
    await BeaconsPlugin.startMonitoring();
    setState(() {
      isScanning = true;
    });
    Map<String, List> infoMap = <String, List>{};
    BeaconsPlugin.listenToBeacons(beaconEventsController);

    /* await BeaconsPlugin.addRegion(
        "BeaconType1", "909c3cf9-fc5c-4841-b695-380958a51a5a");
    await BeaconsPlugin.addRegion(
        "BeaconType2", "6a84c716-0f2a-1ce9-f210-6a63bd873dd9");

    BeaconsPlugin.addBeaconLayoutForAndroid(
        "m:2-3=beac,i:4-19,i:20-21,i:22-23,p:24-24,d:25-25");
    BeaconsPlugin.addBeaconLayoutForAndroid(
        "m:2-3=0215,i:4-19,i:20-21,i:22-23,p:24-24"); */

    /* BeaconsPlugin.setForegroundScanPeriodForAndroid(
        foregroundScanPeriod: 2 , foregroundBetweenScanPeriod: 1);

    BeaconsPlugin.setBackgroundScanPeriodForAndroid(
        backgroundScanPeriod: 2, backgroundBetweenScanPeriod: 1);*/

    beaconEventsController.stream.listen(
        (data) {
          if (data.isNotEmpty) {
            setState(() {
              _beaconResult = data;
              _results.add(_beaconResult);
            });
            String uuid = jsonDecode(_beaconResult)['uuid'];
            String distance = jsonDecode(_beaconResult)['distance'];
            String rssi = jsonDecode(_beaconResult)['rssi'];
            String txPower = jsonDecode(_beaconResult)['txPower'];
            if (beaconIdList.contains(uuid)) {
              infoMap[uuid] = [uuid, distance, rssi, txPower];
            }
          }
        },
        onDone: () {},
        onError: (error) {
          print("Error: $error");
        });

    await BeaconsPlugin.runInBackground(true);
    await Future.delayed(const Duration(seconds: 15));
    await BeaconsPlugin.stopMonitoring();
    print("Stop works");
    setState(() {
      isScanning = false;
    });
    await DataService().sendLocationInfoToService(infoMap);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Name of The App"),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Hasta Adı:  $patientName",
                          style: TextStyle(
                            fontSize: 25,
                          )),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Text(
                        "Hasta Tc:  $patientTc",
                        style: TextStyle(
                          fontSize: 25,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Column(
              children: [
                isScanning
                    ? SpinKitDualRing(
                        color: Colors.green,
                        size: 100,
                      )
                    : SpinKitRotatingCircle(
                        color: Colors.red,
                        size: 100.0,
                      ),
                Padding(
                  padding: const EdgeInsets.all(25),
                  child: isScanning
                      ? Text(
                          "Taranıyor",
                          style: TextStyle(
                            fontSize: 25,
                          ),
                        )
                      : Text(
                          "Tarama için bekleniyor..",
                          style: TextStyle(
                            fontSize: 25,
                          ),
                        ),
                ),
              ],
            ),
            SizedBox(
              height: 100,
            )
          ],
        ),
      ),
    );
  }
}
