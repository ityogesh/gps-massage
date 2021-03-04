import 'package:flutter/material.dart';
import 'package:gps_massageapp/utils/Tooltipclasses/animatedExample.dart';
import 'package:gps_massageapp/utils/Tooltipclasses/basicexample.dart';
import 'package:gps_massageapp/utils/Tooltipclasses/obfuscated_example.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();
    return _MyAppData(
      routeObserver: routeObserver,
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: OptionsPage(),
        navigatorObservers: [
          routeObserver,
        ],
      ),
    );
  }

  static _MyAppData of(BuildContext context) {
    return _MyAppData.of(context);
  }
}

class _MyAppData extends InheritedWidget {
  final RouteObserver<PageRoute> routeObserver;

  _MyAppData({
    Key key,
    this.child,
    this.routeObserver,
  }) : super(key: key, child: child);

  final Widget child;

  static _MyAppData of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_MyAppData>();
  }

  @override
  bool updateShouldNotify(_MyAppData oldWidget) {
    return oldWidget.routeObserver != routeObserver;
  }
}

class OptionsPage extends StatelessWidget {
  const OptionsPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Simple Tooltip"),
      ),
      body: Container(
        height: double.infinity,
        width: double.maxFinite,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              RaisedButton(
                child: Text("Animated example"),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (ctx) =>
                        AnimatedExamplePage(title: 'Flutter Demo Home Page'),
                  ));
                },
              ),
              RaisedButton(
                child: Text("Basics"),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (ctx) => BasicsExamplePage(),
                  ));
                },
              ),
              RaisedButton(
                child: Text("Obfuscate"),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (ctx) => ObfuscateExamplePage(),
                  ));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
