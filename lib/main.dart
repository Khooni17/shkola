import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Проверка баланса карты'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _main = '';
  String _dop = '';
  String _cart = '';
  TextEditingController _cartController = TextEditingController();

  Future<void> getInfo() async {
    final String url =
        'http://xn--58-6kc3bfr2e.xn--p1ai/ajax/?card=$_cart&act=FreeCheckBalance';
    Response r = await get(url);

    if (r.statusCode == 200) {
      final res = r.body.toString();
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
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              onChanged: (String s) async {
                //saveCart(s);
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
              onPressed: () async {
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

  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      onLoad(context);
    });
  }

  void onLoad(BuildContext context) async {
    await getCartFromStorage();
    setState(() {
      _cartController.text = _cart;
    });
    await getInfo();
  }
}
