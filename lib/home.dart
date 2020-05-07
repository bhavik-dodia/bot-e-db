import 'dart:async';
import 'dart:convert';
import 'package:bubble/bubble.dart';
import 'package:flutter/material.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey();
  List<String> _data = ["Hi, How can I help you? <bot>"];
  static const String BOT_URL =
      "https://bot-e-db.herokuapp.com/bot"; // your chatbot url
  TextEditingController _queryController = TextEditingController();
  ScrollController _sc = ScrollController();
  FocusNode inputFieldNode;

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
          AnimatedList(
              // key to call remove and insert from anywhere
              key: _listKey,
              padding: EdgeInsets.only(top: 110, bottom: 60),
              controller: _sc,
              initialItemCount: _data.length,
              itemBuilder:
                  (BuildContext context, int index, Animation animation) {
                return _buildItem(_data[index], animation, index);
              }),
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
                    Timer(Duration(milliseconds: 400), () => _sc.animateTo(_sc.position.maxScrollExtent,duration: Duration(milliseconds: 500), curve: Curves.linear)); // to automatically scrolldown after sending request
                    this._getResponse();
                    FocusScope.of(context).requestFocus(inputFieldNode); // to keep keyboard open
                    Timer(Duration(seconds: 2), () => _sc.animateTo(_sc.position.maxScrollExtent,duration: Duration(milliseconds: 500), curve: Curves.linear)); // to automatically scrolldown after receiving response
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  http.Client _getClient() {
    return http.Client();
  }

  void _getResponse() {
    if (_queryController.text.length > 0) {
      this._insertSingleItem(_queryController.text);
      var client = _getClient();
      try {
        client.post(
          BOT_URL,
          body: {"query": _queryController.text},
        )..then((response) {
            print(response.body);
            Map<String, dynamic> data = jsonDecode(response.body);
            _insertSingleItem(data['response'] + "<bot>");
          });
      } catch (e) {
        print("Failed -> $e");
      } finally {
        client.close();
        _queryController.clear();
      }
    }
  }

  void _insertSingleItem(String message) {
    _data.add(message);
    _listKey.currentState.insertItem(_data.length - 1);
  }

  Widget _buildItem(String item, Animation animation, int index) {
    bool mine = item.endsWith("<bot>");
    return SizeTransition(
      sizeFactor: animation,
      child: Padding(
        padding: EdgeInsets.only(bottom: 20),
        child: mine
            ? Container(
                alignment: Alignment.topLeft,
                child: Bubble(
                  elevation: 8,
                  // nip: BubbleNip.leftTop,
                  margin: BubbleEdges.only(left: 8, right: 30),
                  radius: Radius.circular(15),
                  child: SelectableText(
                    item.replaceAll("<bot>", ""),
                    style: TextStyle(fontSize: 17),
                  ),
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
                    item.replaceAll("<bot>", ""),
                    style: TextStyle(fontSize: 17, color: Colors.white),
                  ),
                  color: Colors.blue,
                  padding: BubbleEdges.all(10),
                ),
              ),
      ),
    );
  }
}
