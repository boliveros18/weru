import 'package:provider/provider.dart';
import 'package:weru/pages/home.dart';
import 'package:weru/pages/login.dart';
import 'package:flutter/material.dart';
import 'package:weru/provider/session.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final session = Session();
  await session.getSession();
  runApp(
    ChangeNotifierProvider<Session>(
      create: (context) => session,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    //final session = Provider.of<Session>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Poppins'),
      initialRoute:
          '/login', //session.user.isNotEmpty && session.pass.isNotEmpty
      // ? '/home'
      // : '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
      },
    );
  }
}
