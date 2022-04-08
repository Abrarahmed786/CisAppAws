import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

enum PhotoSource { ASSET, NETWORK }
enum PhotoStatus { LOADING, ERROR, LOADED }

void main() => runApp(CisAppAWS());

class CisAppAWS extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late PhotoSource photoSource;
  late PhotoStatus photoStatus;
  late String source;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 24),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 200,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Container(
                        color: Colors.grey.shade200,
                        child: photoSource == PhotoSource.NETWORK
                            ? Image.network(source, height: 200)
                            : photoSource == PhotoSource.ASSET
                                ? Image.asset(source, height: 200)
                                : Container(
                                    color: Colors.grey.shade200, height: 200),
                      ),
                    ),
                    Center(
                      child: photoStatus == PhotoStatus.LOADING
                          ? CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation(Colors.red))
                          : photoStatus == PhotoStatus.ERROR
                              ? Icon(MaterialIcons.error,
                                  color: Colors.red, size: 40)
                              : Container(),
                    )
                  ],
                ),
              ),
              SizedBox(height: 16),
              RaisedButton(
                onPressed: () async {},
                child: Text('Select image'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
