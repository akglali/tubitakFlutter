import 'dart:async';
import 'dart:convert';

import 'package:Tubitak/models/becaon_model.dart';
import 'package:Tubitak/utils/secure_storage.dart';
import 'package:http/http.dart' as http;

class DataService {
  String domain = 'http://172.20.10.2:8000/';
  List<BeaconModel> beaonlist = [];
  List<String> beaconIdList = [];

  Future<List<String>> getAllBeaconInfo() async {
    var url = Uri.parse('${domain}track/get_all_beacon_info');
    var response = await http.get(url);
    var body = jsonDecode(response.body);
    for (var i in body) {
      beaonlist.add(BeaconModel(
          beaconId: i['BeaconId'], locationOfBeacon: i['LocationOfBeacon']));
      beaconIdList.add(i['BeaconId']);
    }
    return beaconIdList;
  }

  Future sendLocationInfoToService(Map<String, List> locationInfo) async {
    String? uuid = await SecureStorage().readKey("uuid");
    var url = Uri.parse('${domain}track/send_location');
    for (var k in locationInfo.values) {
      String beaconId = k[0];
      String distance = k[1];
      /*double rssi=double.parse(k[2]);
      double txPower=double.parse(k[3]);
      double distanceFound=distanceCalculator(txPower, rssi);
      print(distanceFound);
      print("distance "+distance);*/
      await http.post(url,
          body: json.encode(
              {"beaconId": beaconId, "patientId": uuid, "distance": distance}));
    }
  }

/*double distanceCalculator(double txPower,double rssi) {
    if (rssi == 0) {
      return -1.0; // if we cannot determine accuracy, return -1.
    }

    double ratio = rssi*1.0/txPower;
    if (ratio < 1.0) {
      double result= pow(ratio,10)*(1);
      return result;
    }
    else {
      double accuracy =  (0.89976)*pow(ratio,7.7095) + 0.111;
      return accuracy;
    }

  }*/

}
