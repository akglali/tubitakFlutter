import 'dart:convert';


import 'package:Tubitak/utils/secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginService {
  String patientTc;
  String domain = 'http://172.20.10.2:8000/';

  LoginService({required this.patientTc});

  Future<List<String>> loginPatient() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var url = Uri.parse('${domain}patient/login');
    var response =
        await http.post(url, body: json.encode({"patientTc": patientTc}));
    var body = jsonDecode(response.body);
    if (response.statusCode != 200) {
      return [jsonDecode(response.body)["Error"]];
    }
    String uuid = body['patientId'];
    String patientName = body['patientName'];
    await SecureStorage().writeKey(uuid, "uuid");
    await prefs.setString("patientName", patientName);
    await prefs.setString("patientTc", patientTc);
    return [uuid, patientName, patientTc];
  }


}
