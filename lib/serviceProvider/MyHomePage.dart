import 'package:flutter/material.dart';

void main() {
  runApp(MyHomePage());
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: RaisedButton(
          onPressed: () {
            showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text('Dialog Title'),
                  content: Text('This is my content'),
                )
            );
          },
          color: Colors.blue,
          child: Text('Show PopUp'),
        ),
      ),
    );
  }
}