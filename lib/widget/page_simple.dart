import 'package:flutter/material.dart';

class PageWidget {
  final String title = "";
  final String path = "";
  final IconData icon = Icons.info;

  String get getTitle => title;

  IconData get getIcon => icon;

  String get getPath => path;
}

class PageStatelessWidget extends StatelessWidget implements PageWidget {
  PageStatelessWidget({Key key}) : super(key: key);
  @override
  final String title = "";
  @override
  final String path = "";
  @override
  final IconData icon = Icons.info;

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
        title: Text(this.title),
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

