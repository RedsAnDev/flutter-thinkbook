import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:thinkbook/widget/page_simple.dart';

class ConnectCalendarView extends StatefulWidget implements PageWidget {
  @override
  final String title = "Connessione Calendario";
  @override
  final String path = "/calendar/connect";
  @override
  final IconData icon = Icons.update;

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
    icon = widget.icon == null ? icon : Icon(widget.icon);
    title = widget.title == null ? "" : widget.title;
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
            return ListTile(
              contentPadding: EdgeInsets.all(8),
              title: Text(
                item.name,
                style: TextStyle(fontSize: 24),
              ),
              subtitle: Text(item.id),
              leading: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 32,
                      width: 32,
                      color: Color(item.color),
                    )
                  ]),
              trailing: Checkbox(
                value: false,
                onChanged: (value) {},
              ),
              onTap: () {},
            );
          }),
    );
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
