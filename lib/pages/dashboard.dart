import 'package:thinkbook/db/calendar/_init.dart';
import 'package:thinkbook/db/orm/_init.dart';
import 'package:thinkbook/widget/card.dart';
import 'package:thinkbook/widget/page_simple.dart';
import 'package:thinkbook/widget/route.dart';
import 'package:flutter/material.dart';

class Dashboard extends StatefulWidget {
  final String title;
  final PathDrawer route;

  Dashboard({Key key, this.title, this.route}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _counter = 0, _selectedIndex = 1;
  String _title;
  List<PageWidget> _boards = [];
  List<BottomNavigationBarItem> _tabs = [];

  @override
  void initState() {
    super.initState();
    _title = widget.title;
    _boards = <PageWidget>[
      Scheduleboard(
        icon: Icons.arrow_back,
        title: "Eventi passati",
        path: "events_passed",
        from_today: false,
      ),
      Homeboard(),
      Scheduleboard(
        icon: Icons.arrow_forward,
        title: "Eventi futuri",
        path: "events_incoming",
      )
    ];
    _tabs = _boards
        .map(
          (PageWidget element) => BottomNavigationBarItem(
              icon: Icon(element.getIcon), title: Text(element.getTitle)),
        )
        .toList();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size dev = MediaQuery.of(context).size;
    return Scaffold(
        drawer: widget.route,
        appBar: AppBar(
          title: Text(_title),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          items: _tabs,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        ),
        body: _boards.elementAt(_selectedIndex) as Widget);
  }
}

class Homeboard extends StatefulWidget implements PageWidget {
  @override
  static final IconData icon = Icons.build;
  @override
  static final String title = "Home";
  @override
  static final String path = "homeboard";

  Homeboard({Key key}) : super(key: key);

  @override
  _HomeboardState createState() => _HomeboardState();

  @override
  IconData get getIcon => icon;

  @override
  String get getPath => path;

  @override
  String get getTitle => title;
}

class _HomeboardState extends State<Homeboard> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: DBModelCalendar.getAll(DBMSProvider.db),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          String message = null;
          if (snapshot.hasError)
            message = "Attenzione, errore di connessione al DB";
          else if (!snapshot.hasData)
            message = "Non son presenti eventi di alcun tipo";
          if (message != null) return Center(child: Text(message));
          List dataset = snapshot.data;
          return ListView.builder(
              itemCount: dataset.length,
              itemBuilder: (BuildContext context, int index) {
                DBModelCalendar item = dataset[index];
                return ListTile(
                  title: Text(item.getTitle),
                  subtitle: FutureBuilder(
                      future: DBModelEvent.getByCalendarID(DBMSProvider.db,item.id),
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        String message;
                        if (snapshot.hasError)
                          message = "Clicca per aggiornare";
                        else if (!snapshot.hasData)
                          message = "Eventi riscontrati 0/0";
                        if (message != null) return Text(message);
                      }),
                );
              });
        });
  }
}

class Scheduleboard extends StatefulWidget implements PageWidget {
  bool from_today = true;
  @override
  final IconData icon;
  @override
  final String title;
  @override
  final String path;

  Scheduleboard({Key key, this.from_today, this.title, this.path, this.icon})
      : super(key: key);

  @override
  _Scheduleboard createState() => _Scheduleboard();

  @override
  IconData get getIcon => icon;

  @override
  String get getPath => path;

  @override
  String get getTitle => title;
}

class _Scheduleboard extends State<Scheduleboard> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: null,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasError)
            return Center(
                child: Text("Spiacente, ci sono dei problemi con il DB"));
          if (!snapshot.hasData)
            return Center(child: Text("Nessun evento disponibile"));
          List buffer = snapshot.data;
          return ListView.builder(
              itemBuilder: (BuildContext context, int index) {
            return Text(buffer[index].toString());
          });
        });
  }
}
