import 'dart:convert';

import 'package:first_project_flutter/utils/secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginService {
  String patientTc;
  String domain = 'http://192.168.43.56:8000/';

  LoginService({required this.patientTc});

  Future<List<String>> loginPatient() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var url = Uri.parse('${domain}patient/login');
    var response =
        await http.post(url, body: json.encode({"patientTc": patientTc}));
    var body = jsonDecode(response.body);
    if(response.statusCode != 200){
      return jsonDecode(response.body)["Error"];
    }
    String uuid=body['patientId'];
    String patientName=body['patientName'];
    await SecureStorage().writeKey(uuid,"uuid");
    await prefs.setString("patientName", patientName);
    await prefs.setString("patientTc", patientTc);
    return  [uuid,patientName,patientTc];
  }

  Future<List<String>> getPatientName(String uuid) async{
    var url = Uri.parse('${domain}patient/get_patient_name');
    var response= await http.get(url, headers:{"uuid":uuid});
    var body = jsonDecode(response.body);
    print(body["patientName"]);
    return body["patientName"];

  }

}
