import 'package:http/http.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:shared_preferences/shared_preferences.dart';



void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.green,  // цвет темы
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
  String cart = '69-001412';


  Future<List<String>> getInfo(String cartNumber) async {
    final String url = 'http://xn--58-6kc3bfr2e.xn--p1ai/ajax/?card=$cartNumber&act=FreeCheckBalance';
    Response r = await get(url);

    if(r.statusCode == 200){
      final res = r.body.toString();
      var doc = parse(res);
      String main = '';
      String dop = '';
      try {
        main = doc.getElementsByTagName('span')[1].text;
      } catch(e){
        main = '';
      }

      try {
        dop = doc.getElementsByTagName('span')[3].text;
      } catch(e){
        dop = '';
      }

      return [main, dop];
    } else {
      return ['', ''];
    }
  }

  Future<String> getCartFromStorage() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String value = prefs.getString('cartNumber') ??  "69-001412";
    return value;
  }


  @override
  Widget build(BuildContext context) {

    final TextEditingController cartController = TextEditingController();


    cartController.text = cart;


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
              controller: cartController,
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
      floatingActionButton: FloatingActionButton(
        onPressed: () async{
          final List<String> res = await getInfo(cartController.text);
          setState(() {
            print(res);
            _main = res[0];
            _dop = res[1];
          });
        },
        tooltip: 'Increment',
        child: Icon(Icons.update),
      ),
    );
  }



  void onLoad(BuildContext context) async{
    //cart = await getCartFromStorage();
  } //callback when layout build done



}
