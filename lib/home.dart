import 'dart:async';
import 'dart:convert';
import 'package:bubble/bubble.dart';
import 'package:flutter/material.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:progress_indicators/progress_indicators.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> _data = [
    [true, "Hi, How can I help you?<bot>"]
  ];
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
        title: Text(
          'Chatbot',
          style: GoogleFonts.courgette(
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            tooltip: 'Change Theme',
            icon: Icon(Icons.brightness_medium),
            onPressed: () {
              DynamicTheme.of(context).setBrightness(
                Theme.of(context).brightness == Brightness.dark
                    ? Brightness.light
                    : Brightness.dark,
              );
            },
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
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
              clipBehavior: Clip.antiAlias,
              elevation: 8,
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Container(
                height: 60,
                padding: EdgeInsets.symmetric(horizontal: 8),
                alignment: Alignment.center,
                child: TextField(
                  autofocus: true,
                  style: GoogleFonts.merienda(fontSize: 16),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    prefixIcon: Icon(
                      Icons.message,
                      size: 28,
                      color: Colors.blueAccent,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        Icons.send,
                        size: 28,
                        color: Colors.blueAccent,
                      ),
                      onPressed: _insert,
                    ),
                    hintText: "Say something...",
                  ),
                  controller: _queryController,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.send,
                  focusNode: inputFieldNode,
                  onSubmitted: (msg) => _insert(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _insert() {
    String msg = _queryController.text;
    if (msg.length > 0) {
      print(msg);
      setState(() {
        _data.add([true, msg]);
        _data.add([false, '<bot>']);
      });
      _queryController.clear();
      _getResponse(_data.length - 1, msg);
      // to automatically scrolldown after sending request
      Timer(
        Duration(milliseconds: 200),
        () => _sc.animateTo(
          _sc.position.maxScrollExtent,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeOut,
        ),
      );
      FocusScope.of(context)
          .requestFocus(inputFieldNode); // to keep the keyboard open
    }
  }

  void _getResponse(int index, String msg) {
    var client = http.Client();
    try {
      client.post(
        BOT_URL,
        body: {"query": msg},
      )..then((response) {
          print(response.body);
          Map<String, dynamic> data = jsonDecode(response.body);
          setState(() {
            _data[index] = [true, data['response'] + "<bot>"];
          });
          Timer(
            Duration(milliseconds: 100),
            () => _sc.animateTo(
              _sc.position.maxScrollExtent,
              duration: Duration(milliseconds: 500),
              curve: Curves.easeOut,
            ),
          );
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
          ? Bubble(
              elevation: 8,
              // nip: BubbleNip.leftTop,
              alignment: Alignment.topLeft,
              margin: BubbleEdges.only(left: 8, right: 30),
              radius: Radius.circular(15),
              child: item[0]
                  ? SelectableText(
                      item[1].replaceAll("<bot>", ""),
                      style: GoogleFonts.merienda(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    )
                  : CollectionScaleTransition(
                      children: [
                        Text(
                          '●',
                          style: GoogleFonts.merienda(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          '●',
                          style: GoogleFonts.merienda(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          '●',
                          style: GoogleFonts.merienda(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        )
                      ],
                    ),
              color: Colors.deepPurple,
              padding: BubbleEdges.all(10),
            )
          : Bubble(
              elevation: 8,
              // nip: BubbleNip.rightTop,
              alignment: Alignment.topRight,
              margin: BubbleEdges.only(left: 30, right: 8),
              radius: Radius.circular(15),
              child: SelectableText(
                item[1],
                style: GoogleFonts.merienda(fontSize: 16, color: Colors.white),
              ),
              color: Colors.lightBlue,
              padding: BubbleEdges.all(10),
            ),
    );
  }
}
