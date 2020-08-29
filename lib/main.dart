import 'package:thinkbook/pages/detail.dart';
import 'package:thinkbook/widget/route.dart';
import 'package:flutter/material.dart';
import './pages/dashboard.dart';

void main() {
  runApp(App());
}

class App extends StatelessWidget {


  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    PathDrawer drawer=PathDrawer();
    return MaterialApp(
      title: 'Flutter Demo',
      initialRoute: '/',
      routes: {
        '/': (context) => Dashboard(title: "A",route: drawer,),
        '/details': (context) => DetailView(title: "B",route: drawer,)
      },
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
    );
  }
}