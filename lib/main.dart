import 'package:flutter/material.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:chatbot/home.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DynamicTheme(
        defaultBrightness: Brightness.dark,
        data: (brightness) => new ThemeData(
              primaryColor: Colors.blue,
              accentColor: Colors.blueAccent,
              brightness: brightness,
            ),
        themedWidgetBuilder: (context, theme) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Chatbot',
            theme: theme,
            home: HomePage(),
            routes: <String, WidgetBuilder>{
        '/homepage': (BuildContext context) => HomePage(),
      },
          );
        });
  }
}
