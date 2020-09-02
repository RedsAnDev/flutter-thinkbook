import 'package:flutter/material.dart';
import 'package:thinkbook/pages/dashboard.dart';


class PathDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: ListView(padding: EdgeInsets.zero, children: <Widget>[
      DrawerHeader(
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.account_circle),
                  onPressed: () {
                    //TODO quando premuto, devi andare a verificare l'account!
                  },
                ),
                Text("Cancarlo Provetti")
              ],
            ),
            Row(children: [
              Text("Utente base"),
            ]),
            Spacer(),
            Text(
              "Smart Safety",
              textScaleFactor: 2,
              softWrap: true,
            ),
          ],
        ),
        decoration: BoxDecoration(
          color: Colors.blue,
        ),
      ),
          ListTile(
              leading: Icon(Icons.home),
              title: Text("Home"),
              onTap: () {
                Navigator.popAndPushNamed(context, "/");
              }),
          ListTile(
              leading: Icon(Icons.settings),
              title: Text("Impostazioni"),
              onTap: () {
                Navigator.popAndPushNamed(context, "/settings");
              })
    ]));
  }
}
