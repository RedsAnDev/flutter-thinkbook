import 'package:thinkbook/widget/page_simple.dart';
import 'package:thinkbook/widget/route.dart';

import 'package:flutter/material.dart';

class DetailView extends StatefulWidget implements PageWidget {
  @override
  static final String title = "Dettagli evento";
  @override
  static final String path = "/calendar/event";
  @override
  static final IconData icon = Icons.event;

  @override
  IconData get getIcon => icon;

  @override
  String get getPath => path;

  @override
  String get getTitle => title;

  DetailView({Key key, route}) : super(key: key);

  @override
  _StateDetailView createState() => _StateDetailView();
}

class _StateDetailView extends State<DetailView> {
  // View
  IconData icon = Icons.info;
  String title;

  @override
  void initState() {
    icon = widget.getIcon == null ? icon : Icon(widget.getIcon);
    title = widget.getTitle == null ? "" : widget.getTitle;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Text("TOTO"),
    );
  }
}
