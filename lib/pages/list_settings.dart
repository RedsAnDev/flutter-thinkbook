import 'package:thinkbook/db/orm/dbms.dart';
import 'package:thinkbook/widget/page_simple.dart';

import 'settings/connectCalendar.dart';
import 'package:thinkbook/widget/route.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';

class ListSettingsView extends StatelessWidget {
  List<dynamic> settingsOptions = [ConnectCalendarView()];

  ListSettingsView({Key key, this.title, this.route}) : super(key: key);

  final String title;
  static final String path = "/settings";
  final PathDrawer route;

  @override
  Widget build(BuildContext context) {
    settingsOptions.add(singleOption(
        title: "Ricrea DB",
        icon: Icons.upgrade,
        context: context,
        onTap: () async {
          await DBMSProvider.db.clearDB(DBMSProvider.db);
        }));
    settingsOptions.add(singleOption(
        title: "Inizializza DB",
        icon: Icons.upgrade,
        context: context,
        onTap: () async {
          await DBMSProvider.db.initDB(recreate: true);
        }));
    return Scaffold(
      drawer: this.route,
      appBar: AppBar(
        title: Text(this.title),
      ),
      body: ListView.builder(
          itemCount: settingsOptions.length,
          itemBuilder: (BuildContext context, int index) {
            if (settingsOptions[index].runtimeType == ConnectCalendarView) {
              PageWidget settingOption = settingsOptions[index];
              return ListTile(
                contentPadding: EdgeInsets.all(16),
                title: Text(
                  settingOption.getTitle,
                  style: TextStyle(fontSize: 20),
                ),
                leading: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [Icon(settingOption.getIcon)],
                ),
                onTap: () {
                  Navigator.pushNamed(context,
                      join(ListSettingsView.path, settingOption.getPath));
                },
              );
            } else if (settingsOptions[index].runtimeType == ListTile)
              return settingsOptions[index] as ListTile;
            else
              return Text("Nessuna impostazione disponibile");
          }),
    );
  }
}

ListTile singleOption(
    {String title, IconData icon, BuildContext context, VoidCallback onTap}) {
  return ListTile(
    contentPadding: EdgeInsets.all(16),
    title: Text(
      title,
      style: TextStyle(fontSize: 20),
    ),
    leading: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [Icon(icon)],
    ),
    onTap: onTap,
  );
}
