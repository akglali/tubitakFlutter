import 'package:first_project_flutter/components/input_widget.dart';
import 'package:first_project_flutter/http_service/auth_service.dart';
import 'package:first_project_flutter/screens/send_data.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  String title;

  HomePage({required this.title});

  TextEditingController tcno = TextEditingController();
  String uuid = '';
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      body: Padding(
        padding: EdgeInsets.only(bottom: 20, top: 20, left: 20, right: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Lütfen Hastanın TC Kimlik Numarasını Giriniz.",
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            Flexible(
                child: Form(
                    key: _formKey,
                    child: InputWidget(
                        controller: tcno,
                        hint: "TC : 01234567891",
                        keyboardType: TextInputType.number))),
            SizedBox(
              width: 20,
            ),
            TextButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  uuid = (await LoginService(patientTc: tcno.text)
                      .loginPatient())[0];
                  if (uuid == "There is no such a patient") {
                    AlertDialog alert = const AlertDialog(
                      title: Text("Not Found"),
                      content: Text("There Is no Such a patient"),
                      actions: [],
                    );
                    showDialog(context: context, builder: (context) => alert);
                  } else {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SendData(uuid: uuid)));
                  }
                }
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.lightBlue,
                primary: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(5),
                  ),
                ),
              ),
              child: Text("Giriş"),
            ),
          ],
        ),
      ),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      centerTitle: true,
      title: Text(title),
    );
  }
}
