import 'package:thinkbook/pages/detail.dart';
import 'package:thinkbook/pages/list_settings.dart';
import 'package:thinkbook/pages/settings/connectCalendar.dart';
import 'package:thinkbook/widget/route.dart';
import 'package:flutter/material.dart';
import './pages/dashboard.dart';
import "package:path/path.dart";

void main() {
  runApp(App());
}

class App extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    PathDrawer drawer = PathDrawer();
    return MaterialApp(
      title: 'ThinkBook',
      initialRoute: '/',
      routes: {
        '/': (context) => Dashboard(
              title: "ThinkBook",
              route: drawer,
            ),
        ListSettingsView.path: (context) =>
            ListSettingsView(title: "Impostazioni", route: drawer),
        join(ListSettingsView.path, ConnectCalendarView.path): (context) =>
            ConnectCalendarView(),
    join(ListSettingsView.path,DetailView.path): (context) => DetailView()
      },
      theme: ThemeData(
        primarySwatch: Colors.teal,
        backgroundColor: Colors.amber,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
    );
  }
}
