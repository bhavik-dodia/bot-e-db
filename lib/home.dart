import 'dart:async';
import 'dart:convert';
import 'package:bubble/bubble.dart';
import 'package:flutter/material.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:progress_indicators/progress_indicators.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // final GlobalKey<AnimatedListState> _listKey = GlobalKey();
  List<dynamic> _data = [
    [true, "Hi, How can I help you?<bot>"]
  ];
  static const String BOT_URL =
      "https://bot-e-db.herokuapp.com/bot"; // your chatbot url
  TextEditingController _queryController = TextEditingController();
  ScrollController _sc = ScrollController();
  FocusNode inputFieldNode;
  String message;

  @override
  void initState() {
    super.initState();
    inputFieldNode = FocusNode();
  }

  @override
  void dispose() {
    inputFieldNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      resizeToAvoidBottomPadding: true,
      appBar: AppBar(
        elevation: 8,
        leading: Icon(Icons.home),
        title: Text('Chatbot'),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
              tooltip: 'Change Theme',
              icon: Icon(Icons.brightness_medium),
              onPressed: () {
                DynamicTheme.of(context).setBrightness(
                    Theme.of(context).brightness == Brightness.dark
                        ? Brightness.light
                        : Brightness.dark);
              }),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: <Widget>[
          ListView.builder(
            padding: EdgeInsets.only(top: 110, bottom: 60),
            itemBuilder: (BuildContext context, int index) =>
                _buildItem(_data[index], index),
            itemCount: _data.length,
            controller: _sc,
            reverse: false,
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Card(
              elevation: 8,
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30)),
              ),
              child: Container(
                height: 60,
                alignment: Alignment.center,
                child: TextField(
                  autofocus: true,
                  style: TextStyle(fontSize: 18),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    prefixIcon: Icon(
                      Icons.message,
                    ),
                    hintText: "Say something...",
                  ),
                  controller: _queryController,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.send,
                  focusNode: inputFieldNode,
                  onSubmitted: (msg) {
                    // to automatically scrolldown after sending request
                    if (_queryController.text.length > 0) {
                      message = msg;
                      print(message);
                      setState(() {
                        _data.add([true, message]);
                        _data.add([false, '<bot>']);
                      });
                      _queryController.clear();
                      _getResponse(_data.length - 1);
                      Timer(
                          Duration(milliseconds: 200),
                          () => _sc.animateTo(_sc.position.maxScrollExtent,
                              duration: Duration(milliseconds: 500),
                              curve: Curves.easeOut));
                      FocusScope.of(context).requestFocus(
                          inputFieldNode); // to keep keyboard open
                    }
                    // to automatically scrolldown after receiving response
                    // Timer(
                    //     Duration(seconds: 2),
                    //     () => _sc.animateTo(_sc.position.maxScrollExtent,
                    //         duration: Duration(milliseconds: 500),
                    //         curve: Curves.linear));
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Future<String> _getResponse(int index) async {
  //   var client = http.Client();
  //   final response = await client.post(
  //     BOT_URL,
  //     body: {"query": message},
  //   );
  //   print(response.body);
  //   Map<String, dynamic> data = jsonDecode(response.body);
  //   client.close();
  //   _data[index]=data['response'] + "<bot>";
  //   return _data[index];
  // }

  void _getResponse(int index) {
    var client = http.Client();
    try {
      client.post(
        BOT_URL,
        body: {"query": message},
      )..then((response) {
          print(response.body);
          Map<String, dynamic> data = jsonDecode(response.body);
          setState(() {
            _data[index] = [true, data['response'] + "<bot>"];
          });
          Timer(
              Duration(milliseconds: 100),
              () => _sc.animateTo(_sc.position.maxScrollExtent,
                  duration: Duration(milliseconds: 500),
                  curve: Curves.easeOut));
        });
    } catch (e) {
      print(e);
    } finally {
      client.close();
    }
  }

  Widget _buildItem(dynamic item, int index) {
    bool bot = item[1].endsWith("<bot>");
    return Padding(
      padding: EdgeInsets.only(bottom: 20),
      child: bot
          ? Container(
              alignment: Alignment.topLeft,
              child: Bubble(
                elevation: 8,
                // nip: BubbleNip.leftTop,
                margin: BubbleEdges.only(left: 8, right: 30),
                radius: Radius.circular(15),
                child: item[0]
                        ? SelectableText(
                            item[1].replaceAll("<bot>", ""),
                            style: TextStyle(fontSize: 17),
                          )
                        : CollectionScaleTransition(children: [
                            Text('●', style: TextStyle(fontSize: 17)),
                            SizedBox(
                              width: 5,
                            ),
                            Text('●', style: TextStyle(fontSize: 17)),
                            SizedBox(
                              width: 5,
                            ),
                            Text('●', style: TextStyle(fontSize: 17))
                          ]),
                // : FutureBuilder(
                //     future: _getResponse(index),
                //     builder: (context, snapshot) {
                //       if (!snapshot.hasData)
                //         return CollectionScaleTransition(children: [Text('●',style: TextStyle(fontSize: 17)),SizedBox(width: 5,),Text('●',style: TextStyle(fontSize: 17)),SizedBox(width: 5,),Text('●',style: TextStyle(fontSize: 17))]);
                //       else
                //         return SelectableText(
                //           snapshot.data.replaceAll("<bot>", ""),
                //           style: TextStyle(fontSize: 17),
                //         );
                //     }),
                color: Colors.black26,
                padding: BubbleEdges.all(10),
              ),
            )
          : Container(
              alignment: Alignment.topRight,
              child: Bubble(
                elevation: 8,
                // nip: BubbleNip.rightTop,
                margin: BubbleEdges.only(left: 30, right: 8),
                radius: Radius.circular(15),
                child: SelectableText(
                  item[1],
                  style: TextStyle(fontSize: 17, color: Colors.white),
                ),
                color: Colors.blue,
                padding: BubbleEdges.all(10),
              ),
            ),
    );
  }
}
