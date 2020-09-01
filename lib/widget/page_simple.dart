import 'package:flutter/material.dart';

class PageWidget {
  static final String title = "";
  static final String path = "";
  static final IconData icon = Icons.info;

  String get getTitle => title;

  IconData get getIcon => icon;

  String get getPath => path;
}

class PageStatelessWidget extends StatelessWidget implements PageWidget {
  PageStatelessWidget({Key key}) : super(key: key);
  @override
  static final String title = "";
  @override
  static final String path = "";
  @override
  static final IconData icon = Icons.info;

  @override
  String get getTitle => title;

  @override
  IconData get getIcon => icon;

  @override
  String get getPath => path;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: buildAction(context),
        title: Text(this.getTitle),
      ),
      body: buildBody(context),
    );
  }

  Widget buildBody(BuildContext context) {
    return Container();
  }

  List<Widget> buildAction(BuildContext context) {
    return [];
  }
}