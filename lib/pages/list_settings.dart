import 'package:thinkbook/widget/page_simple.dart';

import 'settings/connectCalendar.dart';
import 'package:thinkbook/widget/route.dart';
import 'package:flutter/material.dart';

class ListSettingsView extends StatelessWidget {
  List<PageWidget> settingsOptions = [ConnectCalendarView()];

  ListSettingsView({Key key, this.title, this.route}) : super(key: key);

  final String title;
  final String path = "/settings";
  final PathDrawer route;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: this.route,
      appBar: AppBar(
        title: Text(this.title),
      ),
      body: ListView.builder(
          itemCount: settingsOptions.length,
          itemBuilder: (BuildContext context, int index) {
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
                Navigator.pushNamed(context, this.path + settingOption.getPath);
              },
            );
          }),
    );
  }
}
