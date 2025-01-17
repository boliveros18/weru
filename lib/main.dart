import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weru/functions/functions.dart';
import 'package:weru/pages/home.dart';
import 'package:weru/pages/login.dart';
import 'package:weru/provider/session.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider<Session>(
      create: (context) => Session(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final session = Provider.of<Session>(context);
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(fontFamily: 'Poppins'),
        home: const LoginPage()
        /*
      FutureBuilder<bool>(
        future: Authentication(session.user, session.pass),
        builder: (context, snapshot) {
          if (snapshot.data == true) {
            return const HomePage();
          } else {
            return const LoginPage();
          }
        },
      ),
*/
        );
  }
}
