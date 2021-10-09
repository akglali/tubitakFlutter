import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;

import 'package:beacons_plugin/beacons_plugin.dart';
import 'package:first_project_flutter/http_service/data_service.dart';
import 'package:flutter/material.dart';

class SendData extends StatefulWidget {
  String uuid;

  SendData({required this.uuid});

  @override
  _SendDataState createState() => _SendDataState();
}

class _SendDataState extends State<SendData> with WidgetsBindingObserver {
  List<String>  beaconIdList =[];
  List<String> _results = [];
  String _beaconResult = 'Not Scanned Yet.';

  final StreamController<String> beaconEventsController =
  StreamController<String>.broadcast();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
    WidgetsBinding.instance?.addPostFrameCallback((dur) async {
      beaconIdList = await  DataService().getAllBeaconInfo();
      initPlatformState();


    }); //after everything uploaded run this function

  }

  Future stopMonitoring(Map<String,List> foundBeaconLists) async{
    await BeaconsPlugin.stopMonitoring();
    await DataService().sendLocationInfoToService(foundBeaconLists);
    print("Stop works");
    Future.delayed(const Duration(milliseconds: 20000), initPlatformState);
  }


  Future<void> initPlatformState() async {
    await BeaconsPlugin.startMonitoring();
    Map<String, List> infoMap= <String, List>{};
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
          if (data.isNotEmpty ) {
            setState(() {
              _beaconResult = data;
              _results.add(_beaconResult);

            });
            String uuid =jsonDecode(_beaconResult)['uuid'];
            String distance=jsonDecode(_beaconResult)['distance'];
            String rssi=jsonDecode(_beaconResult)['rssi'];
            String txPower=jsonDecode(_beaconResult)['txPower'];
            if (beaconIdList.contains(uuid)){
              infoMap[uuid]=[uuid,distance,rssi,txPower];
            }
          }
        },
        onDone: () {},
        onError: (error) {
          print("Error: $error");
        });

    await BeaconsPlugin.runInBackground(true);
    await Future.delayed(const Duration(milliseconds: 10000));
    await stopMonitoring(infoMap);

  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('This is second Page'),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Center(child: Text('Data Pages')),
          ],
        ),
      ),
    );
  }
}
