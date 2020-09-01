import 'package:thinkbook/db/calendar/_init.dart';
import 'package:thinkbook/db/orm/_init.dart';
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
  final GlobalKey keyActionAdd = GlobalKey();
  final GlobalKey keyForm = GlobalKey();

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
          actions: [
            FutureBuilder(
                future: Homeboard.getAll(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.hasError || !snapshot.hasData)
                    return IconButton(
                      icon: Icon(
                        Icons.add,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {});
                      },
                    );
                  List calendars = snapshot.data;
                  return IconButton(
                    key: keyActionAdd,
                    icon: Icon(Icons.add),
                    onPressed: () {
                      showModalBottomSheet(
                          context: context,
                          builder: (BuildContext context) {
                            DBModelEvent model = DBModelEvent();
                            return Container(
                                child: Form(
                                    key: keyForm,
                                    autovalidate: true,
                                    child: Padding(
                                        padding: EdgeInsets.all(16),
                                        child: Column(
                                          children: [
                                            DropdownButtonFormField(
                                              decoration: InputDecoration(
                                                  labelText:
                                                      "Calendario selezionato"),
                                              value: null,
                                              items: calendars
                                                  .where((element) =>
                                                      element.getSync)
                                                  .map((e) {
                                                return DropdownMenuItem(
                                                  value: e.getId,
                                                  child: Text(e.getTitle),
                                                );
                                              }).toList(),
                                              onChanged: (value) {},
                                            ),
                                            TextFormField(
                                              decoration: InputDecoration(
                                                  labelText: "Titolo evento"),
                                              initialValue: "",
                                              showCursor: true,
                                              validator: (String val) {
                                                if (val == null ||
                                                    val.trim().length == 0) {
                                                  return "L'evento deve avere un titolo";
                                                }
                                                model.title = val;
                                                return null;
                                              },
                                              onEditingComplete: () {
                                                // DESIGN [@redsandev] non sono proprio sicuro di cosa faccia questa funzione
                                                // https://stackoverflow.com/a/56946311/5930652
                                                FocusScope.of(context)
                                                    .unfocus();
                                              },
                                              onSaved: (String value) => value,
                                            ),
                                            InputDatePickerFormField(firstDate: DateTime(1900),lastDate: DateTime(2100),)
                                          ],
                                        ))));
                          });
                    },
                  );
                })
          ],
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
  static final IconData icon = Icons.calendar_today;
  @override
  static final String title = "Calendari";
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

  static Future getAll() {
    return DBModelCalendar.getAll(DBMSProvider.db);
  }
}

class _HomeboardState extends State<Homeboard> {
  @override
  Widget build(BuildContext context) {
    // ignore: unnecessary_statements
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
                print(item.getSync);
                return ListTile(
                  title: Text(item.getTitle),
                  subtitle: FutureBuilder(
                      future: DBModelEvent.getByCalendarID(
                          DBMSProvider.db, item.id),
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        String message;
                        if (snapshot.hasError)
                          message = "Errore di connessione al calendario";
                        else if (!item.getSync)
                          message = "Tieni premuto per sbloccare il calendario";
                        else if (!snapshot.hasData) message = "Nessun evento";
                        if (message != null) return Text(message);
                        List dataset = snapshot.data;
                        List<DBModelEvent> past = dataset
                            .where((event) => event.datetime < DateTime.now())
                            .toList();
                        List<DBModelEvent> fromnow = dataset
                            .where((event) => event.datetime >= DateTime.now())
                            .toList();
                        return Text(
                            "Eventi riscontrati ${past.length}/${fromnow.length}");
                      }),
                  onTap: () {
                    //TODO aggiornamento
                  },
                  onLongPress: () {
                    setState(() {
                      item.synced = !item.synced;
                      DBModelCalendar.update(DBMSProvider.db, item);
                    });
                  },
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
