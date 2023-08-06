import 'package:flutter/material.dart';
import 'resources/chat_fitness.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:rating_bar/rating_bar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'login.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:jumping_dot/jumping_dot.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'resources/chat_fitness.dart';

class Message {
  final String sender;
  final String text;
  final List list;

  Message({required this.sender, required this.text, required this.list});
}

class ChatDialog extends StatefulWidget with Fitness_Functions {
  @override
  _ChatDialogState createState() => _ChatDialogState();
}

class _ChatDialogState extends State<ChatDialog> {
  List messages = [
    Message(sender: 'Bot', text: 'Hi, my name is Jack and I am your personal fitness assistant. How can I help yout today?', list:[]),
  ];
  var chat_history='\nSam: Hello, my name is Sam, and I am your healthcare assistant. How may I help you today? <END_OF_TURN>';
  var chat_history2=[{"role": "assistant", "content": "Hello, my name is Sam, and I am your healthcare assistant. How may I help you today?"},];
  TextEditingController _textEditingController = TextEditingController();
  int currentDoctorIndex=0;
  ScrollController _scrollController=ScrollController();

  _scrollToBottom() {
    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
  }

  void _sendMessage() {
    if (_textEditingController.text.isNotEmpty) {
      setState(() {
        String text = _textEditingController.text;
        Message newMessage = Message(sender: 'You', text: text, list:[]);
        messages.add(newMessage);
        var scrollPosition = _scrollController.position;
        if (scrollPosition.viewportDimension < scrollPosition.maxScrollExtent) {
          _scrollController.animateTo(
            scrollPosition.maxScrollExtent,
            duration: new Duration(milliseconds: 200),
            curve: Curves.easeOut,
          );
        }
        chat_history=chat_history+"\n"+"User: "+newMessage.text+" <END_OF_TURN>";
        chat_history2=chat_history2+[{"role": "user", "content": newMessage.text}];
        _textEditingController.clear();
        // Simulate bot response
         _scrollToBottom();
        _simulateBotResponse();
      });
    }
  }
  Future<void> _simulateBotResponse() async{
    // Simulating a delayed bot response
    setState(() {
      messages.add(true);
    });
    List<dynamic> response = await Fitness_Functions.Fitness_responser(chat_history);
    var sentence=response[0];
    sentence=sentence.replaceAll('<END_OF_TURN>', '');
    sentence=sentence.replaceAll('\n', '');
    Message botMessage = Message(sender: 'Bot', text: sentence, list:[]);
    chat_history=chat_history+"\n"+"Sam: "+botMessage.text+" <END_OF_TURN>";
    chat_history2=chat_history2+[{"role": "assistant", "content": botMessage.text}];
    setState((){
      messages.add(botMessage);
      if(response[1]=='3'){
        Message productMessage = Message(sender: 'Trainer', text: "Heres a few exercises to try:", list:response[2]);
        messages.add(productMessage);
      }
      messages.remove(true);
    });
     Future.delayed(Duration(seconds: 6), () {
        setState(() {
          _scrollToBottom();
       });
      });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        decoration: BoxDecoration(color:Color.fromARGB(255, 237, 237, 237)),
        child:Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              controller:_scrollController,
              reverse: false, // Show the latest message at the bottom
              itemCount: messages.length,
              itemBuilder: (BuildContext context, int index) {
                final message = messages[index];
                if (message==true){
                  return Container(
                    width:MediaQuery. of(context). size. width*0.1,
                    child:Stack(
                      children:[
                        Container(
                          width:MediaQuery. of(context). size. width*0.1,
                          child:SpinKitThreeBounce(
                            color: Colors.black,
                            size: 10.0,
                          )
                        ),
                        Container(
                          width:MediaQuery. of(context). size. width*0.1,
                          child:Icon(Icons.messenger_outline_outlined)
                        )
                      ]
                    )
                  );
                }
                else if (message.sender == 'You') {
                  return _buildMessageBubble(message);
                } else if (message.sender == 'Bot') {
                  return _buildBotMessageBubble(message);
                }else {
                  return _buildExerciseListMessage(message);
                }
              },
            ),
          ),
          Container(
            width:MediaQuery. of(context). size. width,
            height:MediaQuery. of(context). size. height*0.15,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(0, 3), // changes position of shadow
                ),
              ],
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _textEditingController,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Type your message...',
                      contentPadding: EdgeInsets.all(12.0),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color:Color.fromARGB(255, 11, 178, 255)),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    )
    );
  }
  Widget _buildMessageBubble(Message message) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Text(
            message.sender,
            style: TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 4.0),
          Container(
            padding: EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 11, 178, 255),
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Text(
              message.text,
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBotMessageBubble(Message message) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            message.sender,
            style: TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 4.0),
          Container(
            padding: EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Text(
              message.text,
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildExerciseListMessage(Message message) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            message.sender,
            style: TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4.0),
          Container(
            padding: EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  message.text,
                  style: TextStyle(fontSize: 16.0),
                ),
                SizedBox(height: 8.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    IconButton(
                      icon: Icon(Icons.arrow_back),
                      onPressed: () {
                        setState(() {
                          if (currentDoctorIndex > 0) {
                            currentDoctorIndex--;
                          }
                        });
                      },
                    ),
                    Text(
                      message.list[currentDoctorIndex]['name'],
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: Icon(Icons.arrow_forward),
                      onPressed: () {
                        setState(() {
                          if (currentDoctorIndex < message.list.length - 1) {
                            currentDoctorIndex++;
                          }
                        });
                      },
                    ),
                  ],
                ),
                SizedBox(height: 8.0),
                Text(
                  'Specialty: ${message.list[currentDoctorIndex]['equipment']}',
                  style: TextStyle(fontSize: 16.0),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
