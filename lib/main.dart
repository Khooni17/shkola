import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart';
import 'package:html/parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LocalNotifications(),
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
    );
  }
}

class LocalNotifications extends StatefulWidget {
  @override
  _LocalNotificationsState createState() => _LocalNotificationsState();
}

class _LocalNotificationsState extends State<LocalNotifications> {
  String _main = '';
  String _dop = '';
  String _cart = '';
  TextEditingController _cartController = TextEditingController();

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  AndroidInitializationSettings androidInitializationSettings;
  IOSInitializationSettings iosInitializationSettings;
  InitializationSettings initializationSettings;

  @override
  void initState() {
    super.initState();
    initializing();
  }

  void _showNotification() async {
    await notificationSchedule();
  }

  void initializing() async {
    androidInitializationSettings = AndroidInitializationSettings('app_icon');
    iosInitializationSettings = IOSInitializationSettings(
        onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    initializationSettings = InitializationSettings(
        androidInitializationSettings, iosInitializationSettings);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
  }

  Future<void> notificationSchedule() async {
    final Int64List vibrationPattern = Int64List(4);
    vibrationPattern[0] = 0;
    vibrationPattern[1] = 1000;
    vibrationPattern[2] = 5000;
    vibrationPattern[3] = 2000;


    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'your other channel id',
        'your other channel name',
        'your other channel description',
        vibrationPattern: vibrationPattern,
        enableLights: true,
        color: const Color.fromARGB(255, 255, 0, 0),
        ledColor: const Color.fromARGB(255, 255, 0, 0),
        ledOnMs: 1000,
        ledOffMs: 500);
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    NotificationDetails platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        0,
        'Hi there',
        'Subscibe my youtube channel',
        // scheduledNotificationDateTime,
        platformChannelSpecifics);
  }

  // ignore: missing_return
  Future onSelectNotification(String payLoad) {
    if (payLoad != null) {
      debugPrint("$payLoad");
    }
    //print("Notification Tab");
  }

  Future onDidReceiveLocalNotification(
      int id, String title, String body, String payload) async {
    return showDialog(
        context: context,
        builder: (
          BuildContext context,
        ) =>
            CupertinoAlertDialog(
              title: Text(title),
              content: Text(body),
              actions: <Widget>[
                CupertinoDialogAction(
                  isDefaultAction: true,
                  child: Text("Okay"),
                  onPressed: () {
                    // naviagate to desire page
                  },
                )
              ],
            ));
  }

  Future<void> getInfo() async {
    final String url =
        'http://xn--58-6kc3bfr2e.xn--p1ai/ajax/?card=$_cart&act=FreeCheckBalance';
    Response r = await get(url);

    if (r.statusCode == 200) {
      final res = r.body.toString();
      //print(res);
      var doc = parse(res);
      String main = '';
      String dop = '';
      try {
        main = doc.getElementsByTagName('span')[1].text;
      } catch (e) {
        main = '';
      }

      try {
        dop = doc.getElementsByTagName('span')[3].text;
      } catch (e) {
        dop = '';
      }

      setState(() {
        _main = main;
        _dop = dop;
      });
    } else {
      setState(() {
        _main = '';
        _dop = '';
      });
    }
  }

  Future<void> getCartFromStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _cart = prefs.getString('cart') ?? "69-001412";
  }

  Future<void> saveCart(String s) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('cart', s);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text('Узнать баланс карты'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              onChanged: (String s) async {
                await saveCart(s);
              },
              controller: _cartController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Номер карты',
              ),
            ),
            Text(
              '\n\n\n Основное (горячее питание): \n',
              style: Theme.of(context).textTheme.headline6,
            ),
            Text(
              '$_main \n\n',
              style: Theme.of(context).textTheme.headline4,
            ),
            Text(
              'Дополнительное (буфет) руб. \n',
              style: Theme.of(context).textTheme.headline6,
            ),
            Text(
              '$_dop',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      persistentFooterButtons: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            FlatButton(
              onPressed: () {
                _showNotification();
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  new Icon(Icons.notifications),
                  new Text('Уведомление'),
                ],
              ),
            ),
            FlatButton(
              onPressed: () async {
                await getCartFromStorage();
                setState(() {
                  _cartController.text = _cart;
                });
                await getInfo();
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  new Icon(Icons.update),
                  new Text('Обновить'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
