import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:thinkbook/db/calendar/_init.dart';
import 'package:thinkbook/db/orm/dbms.dart';
import 'package:thinkbook/widget/page_simple.dart';

class ConnectCalendarView extends StatefulWidget implements PageWidget {
  @override
  static final String title = "Connessione Calendario";
  @override
  static final String path = "/calendar/connect";
  @override
  static final IconData icon = Icons.update;

  @override
  IconData get getIcon => icon;

  @override
  String get getPath => path;

  @override
  String get getTitle => title;

  ConnectCalendarView({Key key, route}) : super(key: key);

  @override
  _StateConnectCalendarView createState() => _StateConnectCalendarView();
}

class _StateConnectCalendarView extends State<ConnectCalendarView> {
  // Dataset
  DeviceCalendarPlugin _deviceCalendarPlugin;
  List<Calendar> _calendars;

  // View
  Icon icon = Icon(Icons.info);
  String title;

  @override
  _StateConnectCalendarView() {
    _deviceCalendarPlugin = DeviceCalendarPlugin();
  }

  @override
  void initState() {
    super.initState();
    icon = widget.getIcon == null ? icon : Icon(widget.getIcon);
    title = widget.getTitle == null ? "" : widget.getTitle;
    _retrieveCalendars();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(title),
          actions: [IconButton(icon: icon, onPressed: this._syncCalendar)],
        ),
        body: ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: _calendars?.length ?? 0,
            itemBuilder: (BuildContext context, int index) {
              Calendar item = _calendars[index];
              return FutureBuilder(
                  future: DBModelCalendar.getOrCreate(
                      DBMSProvider.db,
                      item.id,
                      DBModelCalendar(
                          id: item.id,
                          title: item.name,
                          visible: true,
                          synced: false,
                          blocked: false)),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.hasError)
                      return Text("Errore per calendario ${item.name} \n${snapshot.error}");
                    DBModelCalendar obj;
                    if (snapshot.hasData) obj = snapshot.data;
                    if (obj == null)
                      return Text("Impossibile proseguire, errore nel DB");
                    return CheckboxListTile(
                      contentPadding: EdgeInsets.all(8),
                      title: Text(
                        obj.getTitle,
                        style: TextStyle(fontSize: 24),
                      ),
                      subtitle: Text(obj.getId),
                      secondary: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: 32,
                              width: 32,
                              color: Color(item.color),
                            )
                          ]),
                      value: obj.getSync,
                      onChanged: (bool value) async {
                        setState(() {
                          obj.synced = value;
                          DBModelCalendar.update(DBMSProvider.db, obj);
                        });
                      },
                    );
                  });
            }));
  }

  void _syncCalendar() {
    _retrieveCalendars();
  }

  void _retrieveCalendars() async {
    try {
      var permissionsGranted = await _deviceCalendarPlugin.hasPermissions();
      print("RETRIEVE CAL");
      if (permissionsGranted.isSuccess && !permissionsGranted.data) {
        print("PERMISSION OK BUT NO DAT");
        permissionsGranted = await _deviceCalendarPlugin.requestPermissions();
        if (!permissionsGranted.isSuccess || !permissionsGranted.data) {
          print("WHAT!");
          return;
        }
      }
      final calendarResult = await _deviceCalendarPlugin.retrieveCalendars();
      print("CALENDAR RES $calendarResult");
      setState(() {
        _calendars = calendarResult?.data;
      });
    } on PlatformException catch (e) {
      print("PLATFORM EXCEPTION $e");
    } catch (e) {
      print("GENERIC $e");
    }
  }
}
