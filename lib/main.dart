import 'package:arms/screens/full_screens/splash_screen.dart';
import 'package:arms/services/provider_services.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    const MaterialColor colorPrimarySwatch = MaterialColor(
      0xff04389E,
      <int, Color>{
        50: Color(0xff04389E),
        100: Color(0xff04389E),
        200: Color(0xff04389E),
        300: Color(0xff04389E),
        400: Color(0xff04389E),
        500: Color(0xff04389E),
        600: Color(0xff04389E),
        700: Color(0xff04389E),
        800: Color(0xff04389E),
        900: Color(0xff04389E),
      },
    );

    return ChangeNotifierProvider<AppDataProvider>(
        create: (context) => AppDataProvider(),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(primarySwatch: colorPrimarySwatch),
          home: const SplashScreen(),
        ));
  }
}
