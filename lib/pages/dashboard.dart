import 'dart:collection';

import 'package:device_calendar/device_calendar.dart';
import 'package:thinkbook/db/calendar/_init.dart';
import 'package:thinkbook/db/calendar/model.dart';
import 'package:thinkbook/db/orm/_init.dart';
import 'package:thinkbook/widget/page_simple.dart';
import 'package:thinkbook/widget/route.dart';
import 'package:flutter/material.dart';
import 'package:thinkbook/widget/text.dart';
import 'package:uuid/uuid.dart';
import 'package:uuid/uuid_util.dart';

class Dashboard extends StatefulWidget {
  final String title;
  final PathDrawer route;

  Dashboard({Key key, this.title, this.route}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _counter = 0, _selectedIndex = 1;
  String _title;
  List<PageWidget> _boards = [];
  List<BottomNavigationBarItem> _tabs = [];
  final GlobalKey keyActionAdd = GlobalKey();
  final GlobalKey<FormState> keyForm = GlobalKey<FormState>();
  final DeviceCalendarPlugin _deviceCalendarPlugin = DeviceCalendarPlugin();

  final GlobalKey keyScheduleboardPast = GlobalKey();
  final GlobalKey keyScheduleboardFuture = GlobalKey();

  @override
  void initState() {
    super.initState();
    _title = widget.title;
    _boards = <PageWidget>[
      Scheduleboard(
        key: keyScheduleboardPast,
        icon: Icons.arrow_back,
        title: "Eventi passati",
        path: "events_passed",
        from_today: false,
      ),
      Homeboard(),
      Scheduleboard(
        key: keyScheduleboardFuture,
        icon: Icons.arrow_forward,
        title: "Eventi futuri",
        path: "events_incoming",
        from_today: true,
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
            StreamBuilder(
                stream: DBModelCalendar.getAll(DBMSProvider.db).asStream(),
                // stream: Homeboard.getAll().asStream(),
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
                      ModalBottomCreateEvent(context);
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

  /// Modale per la creazione degli eventi specificandone Titolo, data inizio e fine e calendario.
  void ModalBottomCreateEvent(BuildContext context) async {
    List calendars = await DBModelCalendar.getAll(DBMSProvider.db);
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
                                labelText: "Calendario selezionato"),
                            value: model.idCalendar,
                            items: calendars
                                .where((element) => element.getSync)
                                .map((e) {
                              return DropdownMenuItem(
                                value: e.getId,
                                child: Text(e.getTitle),
                              );
                            }).toList(),
                            onChanged: (value) {
                              model.idCalendar = value;
                            },
                          ),
                          textFormFieldText(context,
                              labelText: "Titolo evento",
                              showCursor: true,
                              errorMessage: "L'evento deve avere un titolo",
                              initialValue: "",
                              errorMessageCB: "Errore, valore non corretto",
                              cb: (val) {
                            model.title = val;
                          }),
                          textFormFieldDateTime(context,
                              icon: Icons.calendar_today,
                              labelText: "Data inizio evento",
                              initialValue: DateTime.now(), cb: (val) {
                            model.dt_start = DateTime.parse(val);
                          }),
                          textFormFieldDateTime(context,
                              icon: Icons.calendar_today,
                              labelText: "Data fine evento",
                              initialValue: DateTime.fromMillisecondsSinceEpoch(
                                  DateTime.now().millisecondsSinceEpoch +
                                      1000 * 15 * 60), cb: (val) {
                            model.dt_end = DateTime.parse(val);
                          }),
                          IconButton(
                              icon: Icon(Icons.send),
                              tooltip: "Save data",
                              onPressed: () async {
                                if (keyForm.currentState.validate()) {
                                  Event event = Event(
                                      model.idCalendar.toString(),
                                      title: model.title,
                                      description: model.payload.toString(),
                                      start: model.dt_start,
                                      end: model.dt_end);
                                  if (model.dt_start == model.dt_end)
                                    event = Event(model.idCalendar.toString(),
                                        title: model.title,
                                        allDay: true,
                                        description: model.payload.toString(),
                                        start: model.dt_start,
                                        end: model.dt_end);
                                  Result<String> eventID =
                                      await _deviceCalendarPlugin
                                          .createOrUpdateEvent(event);
                                  if (eventID.errorMessages.length == 0) {
                                    model.id = eventID.data;
                                    await DBModelEvent.insert(
                                        DBMSProvider.db, model);
                                    Navigator.pop(context);
                                    setState(() {});
                                  }
                                }
                              })
                        ],
                      ))));
        });
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

  // TODO DESIGN TO DELETE
  static Future getAll() {
    return DBModelCalendar.getAll(DBMSProvider.db);
  }
}

class _HomeboardState extends State<Homeboard> {
  final DeviceCalendarPlugin _deviceCalendarPlugin = DeviceCalendarPlugin();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: DBModelCalendar.getAll(DBMSProvider.db),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          String message = null;
          if (snapshot.hasError)
            message =
                "Attenzione, errore di connessione al DB ${snapshot.error}";
          else if (!snapshot.hasData)
            message = "Non son presenti eventi di alcun tipo";
          if (message != null) return Center(child: Text(message));
          List dataset = snapshot.data;
          return ListView.builder(
              itemCount: dataset.length,
              itemBuilder: (BuildContext context, int index) {
                DBModelCalendar calendarItem = dataset[index];
                Row iconStatus = Row(children: [
                  Icon(
                    calendarItem.getSync ? Icons.sync : Icons.sync_disabled,
                    size: 16,
                    color:
                        calendarItem.getSync ? Colors.green : Colors.amber[900],
                  ),
                  Icon(
                      calendarItem.getVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      size: 16,
                      color:
                          calendarItem.getVisible ? Colors.green : Colors.grey),
                  Icon(
                      calendarItem.getBlocked
                          ? Icons.event_busy
                          : Icons.event_available,
                      size: 16,
                      color:
                          calendarItem.getBlocked ? Colors.red : Colors.green)
                ]);
                return ListTile(
                  title: Text(calendarItem.getTitle),
                  subtitle: iconStatus,
                  trailing: StreamBuilder(
                      stream: DBModelEvent.getByCalendarID(
                              DBMSProvider.db, calendarItem.id)
                          .asStream(),
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        String message;
                        if (snapshot.hasError)
                          message = "Errore di connessione al calendario";
                        else if (!calendarItem.getSync)
                          message = "Tieni premuto per sbloccare il calendario";
                        else if (!snapshot.hasData) message = "Nessun evento";
                        if (message != null) return Text(message);
                        List dataset = snapshot.data;
                        List<DBModelEvent> past = dataset
                            .map((e) {
                              return DBModelEvent.fromMap(e);
                            })
                            .where((event) =>
                                event.dt_end.millisecondsSinceEpoch <
                                DateTime.now().millisecondsSinceEpoch)
                            .toList();
                        List<DBModelEvent> fromnow = dataset
                            .map((e) {
                              return DBModelEvent.fromMap(e);
                            })
                            .where((event) =>
                                event.dt_end.millisecondsSinceEpoch >=
                                DateTime.now().millisecondsSinceEpoch)
                            .toList();
                        return Text(
                            "Eventi riscontrati ${past.length}/${fromnow.length}");
                      }),
                  onTap: () async {
                    if (calendarItem.getSync) {
                      int month = 365 * 24 * 60 * 60 * 1000;
                      RetrieveEventsParams query = RetrieveEventsParams(
                          startDate: DateTime.fromMillisecondsSinceEpoch(
                              DateTime.now().millisecondsSinceEpoch - month),
                          endDate: DateTime.fromMillisecondsSinceEpoch(
                              DateTime.now().millisecondsSinceEpoch + month));
                      Result<UnmodifiableListView<Event>> bufferEvents =
                          await _deviceCalendarPlugin.retrieveEvents(
                              calendarItem.id, query);
                      if (bufferEvents.errorMessages.length == 0) {
                        await bufferEvents.data.forEach((Event event) async {
                          if (event.recurrenceRule == null) {
                            await DBModelEvent.updateOrCreate(
                                DBMSProvider.db,
                                DBModelEvent(
                                    id: event.eventId,
                                    idCalendar: event.calendarId,
                                    title: event.title,
                                    dt_start: event.start,
                                    dt_end: event.end,
                                    payload: event.description));
                          } else {
                            print(event.recurrenceRule.toJson());
                          }
                        });
                      }
                    }
                    setState(() {});
                  },
                  onLongPress: () async {
                    calendarItem.synced = !calendarItem.synced;
                    await DBModelCalendar.update(DBMSProvider.db, calendarItem);
                    setState(() {});
                  },
                );
              });
        });
  }
}

class Scheduleboard extends StatefulWidget implements PageWidget {
  bool from_today;
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
  final DeviceCalendarPlugin _deviceCalendarPlugin = DeviceCalendarPlugin();
  bool from_today = true;
  GlobalKey<FormState> keyForm = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    this.from_today =
        widget.from_today != null ? widget.from_today : this.from_today;
  }

  @override
  Widget build(BuildContext context) {
    this.from_today =
        widget.from_today != null ? widget.from_today : this.from_today;
    return StreamBuilder(
        stream: DBModelEvent.getAllEvents(DBMSProvider.db).asStream(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasError)
            return Center(
                child: Text("Spiacente, ci sono dei problemi con il DB"));
          if (!snapshot.hasData)
            return Center(child: Text("Nessun evento disponibile"));
          List<DBModelEvent> buffer = (snapshot.data as List).map((e) {
            return DBModelEvent.fromMap(e);
          }).where((event) {
            if (!this.from_today &&
                (event.dt_end.millisecondsSinceEpoch <
                    DateTime.now().millisecondsSinceEpoch))
              return true;
            else if (this.from_today &&
                (event.dt_end.millisecondsSinceEpoch >=
                    DateTime.now().millisecondsSinceEpoch)) return true;
            return false;
          }).toList();
          return ListView.builder(
              itemCount: buffer.length,
              itemBuilder: (BuildContext context, int index) {
                return eventCard(context, buffer[index], _deviceCalendarPlugin);
              });
        });
  }

  Widget eventCard(BuildContext context, DBModelEvent event,
      DeviceCalendarPlugin _deviceCalendarPlugin) {
    return Card(
      color: Colors.white,
      child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(children: [
                Icon(Icons.bubble_chart),
                Text(
                  event.title,
                  style: TextStyle(fontSize: 24),
                )
              ]),
              SizedBox(height: 16),
              FutureBuilder(
                  future: DBModelCalendar.getByID(
                      DBMSProvider.db, event.idCalendar),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.hasError)
                      return Text("Nessun calendario disponibile");
                    if (!snapshot.hasData || snapshot.data.length == 0)
                      return Text("Nessun calendario associato");
                    DBModelCalendar dataset = snapshot.data[0];
                    return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Row(children: [
                            Icon(Icons.calendar_today),
                            Text(
                              dataset.title,
                            )
                          ]),
                          Row(children: [
                            Icon(
                              dataset.synced ? Icons.sync : Icons.sync_disabled,
                              color: dataset.synced
                                  ? Colors.green
                                  : Colors.amber[900],
                            ),
                            Text(dataset.synced
                                ? "Sincronizzato"
                                : "Non Sincronizzato")
                          ]),
                          Row(children: [
                            Icon(
                                dataset.visible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: dataset.visible
                                    ? Colors.green
                                    : Colors.amber[900]),
                            Text(dataset.visible ? "Visibile" : "Non Visibile")
                          ])
                        ]);
                  }),
              SizedBox(height: 16),
              Row(
                children: [
                  Text(event.dt_start.toLocal().toString().split(".")[0]),
                  Icon(Icons.compare_arrows),
                  Text(event.dt_end.toLocal().toString().split(".")[0])
                ],
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
              ),
              ButtonBar(
                alignment: MainAxisAlignment.spaceBetween,
                children: [
                  RaisedButton(
                    onPressed: () {
                      setState(() {
                        ModalBottomUpdateEvent(context, event);
                      });
                    },
                    child: Row(
                      children: [Icon(Icons.edit), Text("Modifica")],
                    ),
                  ),
                  RaisedButton(
                    onPressed: () async {
                      Result<bool> res = await _deviceCalendarPlugin
                          .deleteEvent(event.idCalendar, event.id);
                      if (res.errorMessages.length == 0) {
                        await DBModelEvent.delete(DBMSProvider.db,
                            id: event.id);
                        setState(() {});
                      }
                    },
                    child: Row(
                      children: [Icon(Icons.delete_forever), Text("Rimuovi")],
                    ),
                  ),
                ],
              )
            ],
          )),
    );
  }

  /// Update event
  void ModalBottomUpdateEvent(
      BuildContext context, DBModelEvent modelEvent) async {
    List calendars = await DBModelCalendar.getAll(DBMSProvider.db);
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) {
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
                                labelText: "Calendario selezionato"),
                            value: modelEvent.idCalendar,
                            items: calendars
                                .where((element) => element.getSync)
                                .map((e) {
                              return DropdownMenuItem(
                                value: e.getId,
                                child: Text(e.getTitle),
                              );
                            }).toList(),
                            onChanged: (value) {
                              modelEvent.idCalendar = value;
                            },
                          ),
                          textFormFieldText(context,
                              labelText: "Titolo evento",
                              showCursor: true,
                              errorMessage: "L'evento deve avere un titolo",
                              initialValue: modelEvent.title,
                              errorMessageCB: "Errore, valore non corretto",
                              cb: (val) {
                            modelEvent.title = val;
                          }),
                          textFormFieldDateTime(context,
                              icon: Icons.calendar_today,
                              labelText: "Data inizio evento",
                              initialValue: modelEvent.dt_start, cb: (val) {
                            modelEvent.dt_start = DateTime.parse(val);
                          }),
                          textFormFieldDateTime(context,
                              icon: Icons.calendar_today,
                              labelText: "Data fine evento",
                              initialValue: modelEvent.dt_end, cb: (val) {
                            modelEvent.dt_end = DateTime.parse(val);
                          }),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                RaisedButton(
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit),
                                        Text("Salva")
                                      ],
                                    ),
                                    onPressed: () async {
                                      if (keyForm.currentState.validate()) {
                                        Event event = Event(
                                            modelEvent.idCalendar.toString(),
                                            eventId: modelEvent.id,
                                            title: modelEvent.title,
                                            description:
                                                modelEvent.payload.toString(),
                                            start: modelEvent.dt_start,
                                            end: modelEvent.dt_end);
                                        if (modelEvent.dt_start ==
                                            modelEvent.dt_end)
                                          event = Event(
                                              modelEvent.idCalendar.toString(),
                                              eventId: modelEvent.id,
                                              title: modelEvent.title,
                                              allDay: true,
                                              description:
                                                  modelEvent.payload.toString(),
                                              start: modelEvent.dt_start,
                                              end: modelEvent.dt_end);
                                        Result<String> eventID =
                                            await _deviceCalendarPlugin
                                                .createOrUpdateEvent(event);
                                        if (eventID.errorMessages.length == 0) {
                                          await DBModelEvent.update(
                                              DBMSProvider.db, modelEvent);
                                          Navigator.pop(context);
                                        }
                                      }
                                    }),
                                RaisedButton(
                                  child: Row(
                                    children: [
                                      Icon(Icons.close),
                                      Text("Annulla")
                                    ],
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                )
                              ])
                        ],
                      ))));
        });
  }
}
