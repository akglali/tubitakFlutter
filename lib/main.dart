import 'package:first_project_flutter/screens/send_data.dart';
import 'package:first_project_flutter/utils/secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'screens/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isLoading = true;
  bool isLoggedIn = false;
  String uuid='';
  @override
  void initState() {
    _startApp();
    super.initState();
  }
  Future<void> _startApp() async {
    String? uuid = await SecureStorage().readKey('uuid');
    await Future.delayed(Duration(seconds: 1));
    if (uuid != null) {
      setState(() {
        isLoading = false;
        isLoggedIn = true;
      });
    } else {
      setState(() {
        isLoading = false;
        isLoggedIn = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData.dark(),
      home: isLoading
          ? Scaffold(
              body: Center(child: SpinKitSpinningLines(
                color: Colors.white,
                size: 100,

              ),),
            )
          : isLoggedIn ?  SendData(uuid: uuid):HomePage(title: 'Name Of The App') ,
    );
  }
}
