import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as stripe;
import 'resources/chat.dart';
import 'package:url_launcher/url_launcher.dart';
import 'resources/prompts.dart';
import 'package:path/path.dart' as path;
import 'package:video_player/video_player.dart';
import 'package:camera/camera.dart';
import 'dart:math';
import 'package:flutter_signature_pad/flutter_signature_pad.dart';
import 'package:flutter_drawing_board/flutter_drawing_board.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:timer_count_down/timer_count_down.dart';
import 'package:timer_count_down/timer_count_down.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:record/record.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'login.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import '../fitnessBot.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_helper.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:camera/camera.dart';
import 'dart:io';
import 'package:calendar_timeline/calendar_timeline.dart';
import 'package:flutter_emoji_feedback/flutter_emoji_feedback.dart';

Future<List> fetchExercises() async {
  final url = Uri.parse(
      'https://exercisedb.p.rapidapi.com/exercises'); //BEST_MATCH also

  final headers = {
    'X-RapidAPI-Key': '24d7fdb755mshe9ad7b273211de1p160e9bjsn32244367e3e3',
    'X-RapidAPI-Host': 'exercisedb.p.rapidapi.com',
  };

  final response = await http.get(url, headers: headers);

  if (response.statusCode == 200) {
    // Request succeeded, parse the response
    var data = json.decode(response.body);
    // Handle the data
    return (data);
  } else {
    // Request failed
    print('Request failed with status: ${response.statusCode}');
    return ([]);
  }
}


class StarRating extends StatelessWidget {
  final double rating;
  final double size;
  final Color color;
  final Color emptyColor;

  StarRating({
    required this.rating,
    this.size = 12,
    this.color = Colors.amber,
    this.emptyColor = Colors.amber,
  });

  @override
  Widget build(BuildContext context) {
    int starCount = 5;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        starCount,
        (index) => Icon(
          index < rating.floor()
              ? Icons.star
              : (index < rating.ceil() ? Icons.star_half : Icons.star_border),
          size: size,
          color: index < rating.floor() ? color : emptyColor,
        ),
      ),
    );
  }
}

void showProfileMenu(BuildContext context) {
  final RenderBox appBarRenderBox = context.findRenderObject() as RenderBox;

  final double gapOnRight =
      0; // Replace this with the desired gap on the right side

  final screenWidth = MediaQuery.of(context).size.width;

  final double rightOffset = screenWidth - gapOnRight;
  final Offset tapPosition = appBarRenderBox.localToGlobal(Offset.zero);

  showMenu(
    context: context,
    position: RelativeRect.fromLTRB(
      rightOffset,
      tapPosition.dy + kToolbarHeight,
      screenWidth,
      0,
    ),
    items: [
      PopupMenuItem(
        value: "settings",
        child: Text("Settings"),
      ),
      PopupMenuItem(
        value: "learn_more",
        child: Text("Learn More"),
      ),
      PopupMenuItem(
        value: "logout",
        child: Text("Log Out", style: TextStyle(color: Colors.red)),
      ),
    ],
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  ).then((value) {
    if (value == "logout") {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => LoginPage()));
    } else if (value == "learn_more") {
      // Handle learn more action
    }
  });
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Column row;
  final Function() onProfilePressed;

  CustomAppBar({required this.title,required this.row, required this.onProfilePressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration:BoxDecoration(color:Colors.white),
      //   flexibleSpace: Container(
      //   decoration: const BoxDecoration(
      //     gradient: LinearGradient(
      //       begin: Alignment.topLeft,
      //       end: Alignment.bottomRight,
      //       colors: <Color>[Color.fromARGB(255, 202, 244, 255), Color.fromARGB(255, 209, 230, 255)]),
      //   ),
      // ),
      child: 
      Column(
        children:[
        Container(height:MediaQuery.of(context).size.height*0.04),
        Row(
        children: [
          Container(width:MediaQuery.of(context).size.width*0.01),
          // Icon(Icons.account_circle,
          //     color: Color(0xFF0F4FA6), size: MediaQuery.of(context).size.height*0.06), // Profile Icon
          IconButton(icon:Icon(Icons.arrow_back, color: Color(0xFF0F4FA6), size: MediaQuery.of(context).size.height*0.045),onPressed:(){Navigator.pop(context);}),
          Container(width:MediaQuery.of(context).size.width*0.05),// Add some space between the icon and title
          Text(
            title,
            style: GoogleFonts.raleway(
                color: Colors.black, fontWeight: FontWeight.bold, fontSize:30),
          ),
          Container(width:MediaQuery.of(context).size.width*0.45),
          row,
        ],
      ),
      ]
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class ChatScreen extends StatefulWidget with Functions {
  const ChatScreen({super.key, required this.user});
  final user;
  @override
  @override
  _ChatScreenState createState() => _ChatScreenState(user: user);
}

class _ChatScreenState extends State<ChatScreen> {
  _ChatScreenState({required this.user}) : super();
  @override
  initState() {
    // ignore: avoid_print
    Future.delayed(Duration.zero, () {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Note'),
            content: Text('Please note that this is not meant to serve as a diagnoser. We can only assess symptoms and provide a opinion that is not proefessional. We hope you enjoy your experience, and thanks!'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
   });
    
  }
  var user;
  List messages = [
    Message(
        sender: 'Bot',
        text:
            'Hello, my name is Eva, and I am your healthcare assistant. How may I help you today?',
        list: []),
  ];
  var chat_history =
      '\nEva: Hello, my name is Eva, and I am your healthcare assistant. How may I help you today? <END_OF_TURN>';
  var chat_history2 = [
    {
      "role": "assistant",
      "content":
          "Hello, my name is Eva, and I am your healthcare assistant. How may I help you today?"
    },
  ];
  TextEditingController _textEditingController = TextEditingController();
  int currentProductIndex = 0;
  var currentPhotoIndex = 0;
  var _isfocusssed=false;
  ScrollController _scrollController = ScrollController();

  _scrollToBottom() {
    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
  }

  Future<void> _sendMessage(user,credits) async {
    //credits later
    if (_textEditingController.text.isNotEmpty) {
      setState(() {
        String text = _textEditingController.text;
        Message newMessage = Message(sender: 'You', text: text, list: []);
        messages.add(newMessage);
        var scrollPosition = _scrollController.position;
        if (scrollPosition.viewportDimension < scrollPosition.maxScrollExtent) {
          _scrollController.animateTo(
            scrollPosition.maxScrollExtent,
            duration: new Duration(milliseconds: 200),
            curve: Curves.easeOut,
          );
        }
        chat_history =
            chat_history + "\n" + "User: " + newMessage.text + " <END_OF_TURN>";
        chat_history2 = chat_history2 +
            [
              {"role": "user", "content": newMessage.text}
            ];
        _textEditingController.clear();
        // Simulate bot response
        _scrollToBottom();
        if(credits>0){
          _simulateBotResponse(credits);
        }else{
          Message errorMessage= Message(sender: 'Error', text: "There are insufficient credits. Please buy more.", list: []);
         messages.add(errorMessage);
         messages.remove(true);
        }
      });
    }
  }

  Future<void> _simulateBotResponse(credits) async {
    // Simulating a delayed bot response
    setState(() {
      messages.add(true);
    });
    List<dynamic> response = await Functions.responser2(chat_history2);
    print(response);
    if(response[1]=='fail' || response[3]=='fail'){
      if(response[0]=='fail' || response[2]=='fail'){
         Message errorMessage= Message(sender: 'Error', text: "There was an error in sending a message. Please try again later.", list: []);
         messages.add(errorMessage);
         messages.remove(true);
      }else{
        if(credits>0){
          await FirebaseFirestore.instance.collection('audios').doc('$user').update({'Credits': credits-1});
        }
        var sentence = response[0];
        sentence = sentence.replaceAll('<END_OF_TURN>', '');
        sentence = sentence.replaceAll('\n', '');

        Message botMessage = Message(sender: 'Bot', text: sentence, list: []);
          chat_history =
              chat_history + "\n" + "Eva: " + botMessage.text + " <END_OF_TURN>";
          chat_history2 = chat_history2 +
              [
                {"role": "assistant", "content": botMessage.text}
              ];
          setState(() {
            messages.add(botMessage);
             if (response[2] == '3') {
              Message errorMessage = Message(sender: 'Error', text: "There was an error in finding products. Please try again later.", list: []);
              messages.add(errorMessage);
             }
            messages.remove(true);
          });
      }
    }
    else{
      if(credits>0){
        await FirebaseFirestore.instance.collection('audios').doc('$user').update({'Credits': credits-1});
      }
      var sentence = response[0];
      sentence = sentence.replaceAll('<END_OF_TURN>', '');
      sentence = sentence.replaceAll('\n', '');

      Message botMessage = Message(sender: 'Bot', text: sentence, list: []);
        chat_history =
            chat_history + "\n" + "Eva: " + botMessage.text + " <END_OF_TURN>";
        chat_history2 = chat_history2 +
            [
              {"role": "assistant", "content": botMessage.text}
            ];
        setState(() {
          messages.add(botMessage);
          if (response[2] == '3') {
            Message productMessage = Message(
                sender: 'Shopper',
                text: "Heres a few items  you can buy:",
                list: response[3]);
            messages.add(productMessage);
          }
          messages.remove(true);
        });
    }
    Future.delayed(Duration(seconds: 6), () {
      setState(() {
        _scrollToBottom();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future:
            FirebaseFirestore.instance.collection('audios').doc('$user').get(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text("Something went wrong");
          }
          if (snapshot.connectionState == ConnectionState.done) {
            final items = snapshot.data;
            var data = (items as DocumentSnapshot).data() as Map;
    return Scaffold(
        appBar: CustomAppBar(
          title: "Eva",
          row:Column(children: <Widget>[
            Container(height:MediaQuery.of(context).size.height*0.01),
            Text('Credits: ${data['Credits']}', style:TextStyle(fontSize:12.0, color:Colors.black), textAlign: TextAlign.right),
            TextButton(
              child:Text("Add more", style:TextStyle(fontSize:15), textAlign: TextAlign.right), 
              style:TextButton.styleFrom(
                minimumSize: Size.zero,
                padding: EdgeInsets.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed:(){
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SubscriptionPage(currentCredits:data['Credits'], user:user),
                  ),
                );
              }
            )
          ]),
          onProfilePressed: () {
            showProfileMenu(context);
          },
        ),
        body: Container(
          decoration: BoxDecoration(color: Color.fromARGB(255, 255, 255, 255)),
          child: Column(
            children: <Widget>[
              Container(height: MediaQuery.of(context).size.height * 0.005),
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  reverse: false, // Show the latest message at the bottom
                  itemCount: messages.length,
                  itemBuilder: (BuildContext context, int index) {
                    final message = messages[index];
                    if (message == true) {
                      return Container(
                          width: MediaQuery.of(context).size.width * 0.1,
                          child: Stack(children: [
                            Container(
                                width: MediaQuery.of(context).size.width * 0.1,
                                child: SpinKitThreeBounce(
                                  color: Colors.black,
                                  size: 10.0,
                                )),
                            Container(
                                width: MediaQuery.of(context).size.width * 0.1,
                                child: Icon(Icons.messenger_outline_outlined))
                          ]));
                    } else if (message.sender == 'You') {
                      return _buildMessageBubble(message);
                    } else if (message.sender == 'Bot') {
                      return _buildBotMessageBubble(message, Color.fromARGB(255, 215, 215, 215));
                    } else if (message.sender == 'Error') {
                      return _buildBotMessageBubble(message, Color.fromARGB(255, 255, 86, 74));
                    }else {
                      return _buildProductListMessage(message);
                    }
                  },
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.15,
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                        color: Colors.grey), // Customize the top outline color
                    bottom: BorderSide(color: Colors.grey),
                  ),
                ),
                child:Column(children:[ 
                  Container(height:MediaQuery.of(context).size.height*0.01),
                  Text(
                      'Cannot exceed 100 characters.',
                      style: TextStyle(color: Color(0xFF0F4FA6)),
                    ),
                  Container(height:MediaQuery.of(context).size.height*0.02),
                  Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        controller: _textEditingController,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(100),
                        ],
                         onTap: () {
                            var _isfocusssed= true;

                        },
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Type your message...',
                          contentPadding: EdgeInsets.all(12.0),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.send, color: Colors.black),
                      onPressed: (() {
                        _sendMessage(user,data['Credits']);
                      }), //Add data['Credits'] later
                    ),
                  ],
                ),
                ]
                ),
              ),
            ],
          ),
        ));
    }
      return Center(
        child: CircularProgressIndicator(color:Color(0xFF0F4FA6)),
      );
    });
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
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                  topLeft: Radius.circular(16)),
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  Colors.blue,
                  Color.fromARGB(255, 128, 173, 255),
                ],
              ),
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

  Widget _buildBotMessageBubble(Message message, color) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Eva',
            style: TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 4.0),
          color == Color.fromARGB(255, 255, 86, 74)
          ?Container(
            padding: EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                  topRight: Radius.circular(16)),
            ),
            child:Text(
              message.text,
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.white,
              ),
            ),
          )
        :Container(
            padding: EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                  topRight: Radius.circular(16)),
            ),
            child:Text(
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

  Widget _buildProductListMessage(Message message) {
    double width = MediaQuery.of(context).size.width;
    double length = MediaQuery.of(context).size.height;
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
              color: Color.fromARGB(255, 214, 214, 214),
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
                          if (currentProductIndex > 0) {
                            currentProductIndex--;
                          }
                          _scrollToBottom();
                        });
                      },
                    ),
                    Container(
                      width: width * 0.5,
                      height: length * 0.05,
                      child: Text(
                        message.list[currentProductIndex]['product_title'],
                        overflow: TextOverflow.fade,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.arrow_forward),
                      onPressed: () {
                        setState(() {
                          if (currentProductIndex < message.list.length - 1) {
                            currentProductIndex++;
                          }
                          _scrollToBottom();
                        });
                      },
                    ),
                  ],
                ),
                SizedBox(height: 8.0),
                Text(
                  'Rating: ${message.list[currentProductIndex]['product_rating']}',
                  style: TextStyle(fontSize: 16.0),
                ),
                SizedBox(height: 8.0),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 245, 245,
                        245), // Match the container background color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          12.0), // Adjust the button border radius
                    ),
                  ),
                  onPressed: () {
                    if (message.list[currentProductIndex]['product_photos'] ==
                        null) {
                      message.list[currentProductIndex]['product_photos'].add(
                          'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAH8AAAB/CAMAAADxY+0hAAAAY1BMVEX///8AAAAuLi4mJibn5+fY2NjOzs4jIyPJycnS0tLV1dW9vb0ODg7t7e3CwsIJCQkdHR0VFRUzMzOioqJoaGg8PDxFRUWAgID39/eWlpZXV1fe3t6Ghoaqqqp5eXmcnJxfX1+3S2YiAAADlElEQVRoge2bW3erIBCFnSRoTCQac2ku9vL/f+WJGpRBNAojnAf3Q9vVmvXRYTbiVoNg0aJFixYtCngcc494lgNcmTc8f+Ff2vnixxUeotgvH8DTFPDrm38M/QyAiQIcPVVgF4kReOqBpgUiTy5gRzECTwMIxQAi303oy4axaMLKhmG+stbvtAHskA0PYK+pA0A23KbW/NU0fhCKD1Y23DvnSzYsp2DrnK/YcL82VWTIV2zIN4YKI0N+a8PEZiHarE35rQ0zi4XIlF/+z4zgbGjKzw+BbEPjAZjyV7B9fWWJ3IRu+en+9S3MRA8YNqE5H+oKgF0FbPhQVqCxYWpUASt+VF6MNVuyYRt+F1/F6UbLX2/KH5nogQEbnt5HfKkjIOCPsGHRdMlZuX6l4Aes2QHop+AOrc4z8D/Y8JlJfDjMwG9tmGoqcJLx8DMHv7UhdCvwQPwcdQAVX7oy6lRghfjJPPwBG14QP5uJH4TCBaoNfxD/gZYAQn7vuQBfIeC9PiU/CEUTKjaUGxCXn5bfViBh2l9Dfc6ajd9nw51oweNB+QAxv8+GvF6Cv57q8dR8yYZKQMGZLjol5weh2BOO2pTS86dtyYj5j2pTigIKl/y7sin9nBOS8k/C4ONzQkp+vQ9LywqMzgkJ+U8RCZRrzNickI5/a1b5pGrCJqAYnAI6/hlajb8yIuPLe1zlyki14Y23KyEVX83AygrgnFAoLh6Xy/nOSfkMVPXYkDfTdL/R8fmlw09LF3RseJMOPNPxryq9FLZhNQU3tBUvqPgF6JRiG1aJET5iS8P/1uJBZ0OclGYk/IH4F9mwygkPifz3goDPj9AvZMOsG9fH3JavaX21Aqw/rl89V5b8v0E8JN2cEM3X2ZKvb31Z3ZywG9eb8vmIWw+anLDzKUN+Pu7OxycbGvOTDEapmxNiG5ryRwttyTQ2nJtfnwuwDZ3yP9hwdv67CVFOKFXAAX/Qhg74ig1TVAEnfGxDkG3oht9vQ0f82oYoJ9w65dc2RDnh3iW/71zgjg8aG6Yu+bgCSV0Bl3ydDXOXfGzDKiecfuvOhq/Y0OhBJit+bcNJOSEpn+DWrSUfpuaE1PypOSE5XwkoplbAnj8tJ1T1a82flhN2dLJ/7i2vnp8blxPOJ+/PE9rYkET6nNDlAJbHeo++m1AM4OrpBQfmuQWaLZkv/tuGub8XTNj1hff3eon312sWLVq0aNF/o39WNiw0rpsKKgAAAABJRU5ErkJggg==');
                    }
                    if (message.list[currentProductIndex]['product_rating'] ==
                        null) {
                      message.list[currentProductIndex]['product_rating'] = 0;
                    }
                    if (message.list[currentProductIndex]
                            ['typical_price_range'] ==
                        null) {
                      message.list[currentProductIndex]
                          ['typical_price_range'] = ["Unknown", "Unknown"];
                    }
                    message.list[currentProductIndex]['product_rating'] =
                        message.list[currentProductIndex]['product_rating']
                            .toDouble();
                    showModalBottomSheet(
                      context: context,
                      builder: (context) {
                        return Container(
                            height: MediaQuery.of(context).size.height * 0.8,
                            child: StatefulBuilder(
                              builder: (context, setState) {
                                return SingleChildScrollView(
                                    child: Wrap(
                                  children: [
                                    Container(
                                      height: length * 0.02,
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(width * 0.02),
                                      // ignore: unnecessary_new
                                      child: new InkWell(
                                          child: RichText(
                                            text: TextSpan(
                                              children: [
                                                TextSpan(
                                                    text:
                                                        '${message.list[currentProductIndex]['product_title']}   ',
                                                    style: TextStyle(
                                                        color: Colors.black)),
                                                const WidgetSpan(
                                                  child: Icon(Icons.link),
                                                ),
                                              ],
                                            ),
                                          ),
                                          onTap: () => launchUrl(
                                              Uri.parse(message
                                                      .list[currentProductIndex]
                                                  ['product_page_url']),
                                              mode: LaunchMode
                                                  .externalApplication)),
                                    ),
                                    Container(
                                      height: length * 0.02,
                                    ),
                                    Container(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          IconButton(
                                            icon: Icon(Icons.arrow_back),
                                            onPressed: () {
                                              setState(() {
                                                if (currentPhotoIndex > 0) {
                                                  currentPhotoIndex--;
                                                }
                                              });
                                            },
                                          ),
                                          Container(
                                            height: length * 0.3,
                                            width: width * 0.7,
                                            decoration: BoxDecoration(
                                              image: DecorationImage(
                                                  image: NetworkImage(
                                                      "${message.list[currentProductIndex]['product_photos'][currentPhotoIndex]}"),
                                                  fit: BoxFit.fill),
                                            ),
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.arrow_forward),
                                            onPressed: () {
                                              setState(() {
                                                if (currentPhotoIndex <
                                                    message
                                                            .list[
                                                                currentProductIndex]
                                                                [
                                                                'product_photos']
                                                            .length -
                                                        1) {
                                                  currentPhotoIndex++;
                                                }
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                    Align(
                                        alignment: Alignment.center,
                                        child: Text(
                                          "${currentPhotoIndex + 1} of ${message.list[currentProductIndex]['product_photos'].length}",
                                          textAlign: TextAlign.center,
                                        )),
                                    Container(height: length * 0.02),
                                    Divider(
                                      color: Color.fromARGB(255, 190, 190, 190),
                                      height: 1,
                                      thickness: 1,
                                    ),
                                    Padding(
                                        padding: EdgeInsets.all(width * 0.05),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: width * 0.17,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "${message.list[currentProductIndex]['product_rating']}",
                                                    style: TextStyle(
                                                        fontSize: 30,
                                                        fontWeight:
                                                            FontWeight.w900),
                                                  ),
                                                  Container(
                                                      height: length * 0.005),
                                                  StarRating(
                                                    rating: message.list[
                                                            currentProductIndex]
                                                        ['product_rating'],
                                                  ),
                                                  Container(
                                                      height: length * 0.01),
                                                  Container(
                                                    width: width * 0.15,
                                                    child: FittedBox(
                                                        fit: BoxFit.fitWidth,
                                                        child: Text(
                                                            "${message.list[currentProductIndex]['product_num_reviews']} ratings")),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(width: width * 0.41),
                                            Container(
                                                width: width * 0.28,
                                                child: FittedBox(
                                                    fit: BoxFit.fitWidth,
                                                    child: Text(
                                                      "${message.list[currentProductIndex]['typical_price_range'][0]} - ${message.list[currentProductIndex]['typical_price_range'][1]}",
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w900,
                                                        fontSize: 20.0,
                                                      ),
                                                    )))
                                          ],
                                        )),
                                    Divider(
                                      color: Color.fromARGB(255, 190, 190, 190),
                                      height: 1,
                                      thickness: 1,
                                    ),
                                    Padding(
                                        padding: EdgeInsets.all(width * 0.05),
                                        child: Container(
                                          child: SingleChildScrollView(
                                              child: Text(
                                                  '${message.list[currentProductIndex]['product_description']}')),
                                        )),
                                  ],
                                ));
                              },
                            ));
                      },
                    ).then((value) {
                      // Function to run when the modal is exited
                      currentPhotoIndex = 0;
                    });
                  },
                  child: Text(
                    'Learn More',
                    style: TextStyle(
                      color: Colors.black, // Set the text color to black
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Message {
  final String sender;
  final String text;
  final List list;

  Message({required this.sender, required this.text, required this.list});
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MobileAds.instance.initialize();
  stripe.Stripe.publishableKey =
      "pk_live_51Od38RFqQTPds4FKYNCyxuCu8TPjZpvzmg0TKQOC8i5Ii5YqoQfVeeoT4faHoddV7WpXdlgszEtp69YrWUftN0cL005BkBNg1u";
  await dotenv.load(fileName: "assets/.env");
  await Firebase.initializeApp();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var email = prefs.getString("email");
  final List<Widget> _widgetOptions = [
    HomePage(user: "$email"),
    ChallengeScreen(user: "$email"),
    Planner(user: "$email"),
    // Planner(user: "$email"),
    JournalPage(user: "$email"),
    // PostPage(currentUser: "$email"),    // ProfilePage(user:"$email"),
  ];
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((value) => runApp(MaterialApp(
            theme:ThemeData(
              useMaterial3: false,
            ),
            title: 'Readerly',
            debugShowCheckedModeBanner: false,
            home: (email == null || email == "")
                ? LoginPage()
                : MyHomePage(widgets: _widgetOptions, selectedIndex: 0),
          )));
}

class SmallRoutineCard extends StatelessWidget {
  final Map routineName;
  final List ExerciseList;
  Widget build(BuildContext context) {
    return Column(children: [
      Row(
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.04,
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.015,
            height: MediaQuery.of(context).size.height * 0.09,
            child: const DecoratedBox(
              decoration: const BoxDecoration(color: Color(0xFF0F4FA6)),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.04,
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              DateFormat('d')
                  .format(DateTime.parse("${routineName['date']} 00:00:00")),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              DateFormat('MMMM')
                  .format(DateTime.parse("${routineName['date']} 00:00:00")),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ]),
          Container(width: MediaQuery.of(context).size.width * 0.065),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              '${routineName['name']}'.length > 16
                  ? '${routineName['name']}'.substring(0, 16) +
                      "..." // Truncate text if it exceeds the character limit
                  : '${routineName['name']}',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Equipment: ${routineName['equipment']}',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
          ]),
        ],
      ),
      Container(height: MediaQuery.of(context).size.height * 0.035),
    ]);
  }

  SmallRoutineCard({required this.routineName, required this.ExerciseList});
}

class RoutineCard extends StatelessWidget {
  final Map routineName;
  final List ExerciseList;
  String getGifUrlForExercise(String exerciseName) {
    try {
      var exerciseData =
          ExerciseList.firstWhere((data) => data['name'] == exerciseName);
      return exerciseData['gifUrl'];
    } catch (e) {
      return ''; // Return an empty string if exerciseName is not found
    }
  }

  RoutineCard({required this.routineName, required this.ExerciseList});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              routineName['name'],
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: Image.network(
                '${getGifUrlForExercise(routineName['name'])}', // Replace with your actual image URL
                height: MediaQuery.of(context).size.height * 0.3,
                width: MediaQuery.of(context).size.height * 0.3,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Target: ${routineName['target']}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 5),
            Text(
              'Body Part: ${routineName['bodyPart']}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 5),
            Text(
              'Equipment: ${routineName['equipment']}',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class AddExercisePage extends StatefulWidget {
  @override
  _AddExercisePageState createState() => _AddExercisePageState();
}

class _AddExercisePageState extends State<AddExercisePage> {
  // Dummy data for exercises
  var _dataFuture;
  var bob = "NO";
  var temp;
  List _searchResult = [];
  var _bannerAd;
  void initState() {
    super.initState();
    BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      request: AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _bannerAd = ad as BannerAd;
          });
        },
        onAdFailedToLoad: (ad, err) {
          print('Failed to load a banner ad: ${err.message}');
          ad.dispose();
        },
      ),
    ).load();
    _dataFuture = FirebaseFirestore.instance.collection('Exercises').doc('List').get();
    _dataFuture.then((snapshot) {
      final data = snapshot.data();
      var items = data!['list'];
      setState(() {
        _searchResult = List.from(items);
      });
    });
  }
  bool listContains(Map<String, dynamic> item, List<Map<dynamic, dynamic>> list) {
  for (var element in list) {
    if (element['gifUrl'] == item['gifUrl'] &&
        element['name'] == item['name'] &&
        element['equipment'] == item['equipment'] &&
        element['id'] == item['id'] &&
        element['target'] == item['target'] &&
        element['bodyPart'] == item['bodyPart']) {
      return true;
    }
  }
  return false;
}
Map<String, dynamic>? findDictionaryById(List list, String id) {
  for (var dictionary in list) {
    if (dictionary['id'] == id) {
      return dictionary;
    }
  }
  return null; // If no match is found
}

  List<Map> selectedExercises = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 1,
          iconTheme: IconThemeData(
            color: Colors.black, //change your color here
          ),
          backgroundColor: Colors.white,
          title: Text(
            'Add Exercises',
            style: TextStyle(color: Colors.black),
          ),
        ),
        body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            future: _dataFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(color:Color(0xFF0F4FA6)),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              } else {
                final data = snapshot.data;
                var items=data!['list'];
                void _sortExercises(id) {
                  setState((){
                    temp= findDictionaryById(_searchResult, id);
                    items!.removeWhere((exercise) =>
                      exercise['id'] == temp['id']);
                    items.insert(0, temp);
                    _searchResult.removeWhere((exercise) =>
                        exercise['id'] == temp['id']);
                    _searchResult.insert(0, temp);
                  });
                }

                void _filterSearchResults(String query) {
                  if (query.isNotEmpty) {
                    var tempList = [];
                    items!.forEach((item) {
                      if (item['name']
                              .toLowerCase()
                              .contains(query.toLowerCase()) ||
                          item['target']
                              .toLowerCase()
                              .contains(query.toLowerCase()) ||
                          item['bodyPart']
                              .toLowerCase()
                              .contains(query.toLowerCase()) ||
                          item['equipment']
                              .toLowerCase()
                              .contains(query.toLowerCase())) {
                        tempList.add(item);
                      }
                    });
                    setState(() {
                      _searchResult = tempList
                          .toList(); // Create a new list instance with filtered items
                      bob = "YEA";
                      print(_searchResult);

                    });
                  } else {
                    setState(() {
                      _searchResult = items!.toList();
                    });
                  }
                  for(var tobeadded in selectedExercises){
                        _sortExercises(tobeadded['id']);
                      }
                }

                return SingleChildScrollView(
                    child: Column(
                  children: [
                    Container(height:MediaQuery.of(context).size.height*0.03),
                    Padding(
                      padding: EdgeInsets.all(16.0),
                      child: TextField(
                        onChanged: (value) {
                          _filterSearchResults(value);
                        },
                        decoration: InputDecoration(
                          hintText: 'Search',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                      ),
                    ),
                    Container(height:MediaQuery.of(context).size.height*0.03),
                    // if (_bannerAd != null)
                    //   Align(
                    //     alignment: Alignment.topCenter,
                    //     child: Container(
                    //       width: _bannerAd!.size.width.toDouble(),
                    //       height: _bannerAd!.size.height.toDouble(),
                    //       child: AdWidget(ad: _bannerAd!),
                    //     ),
                    //   ),
                    Stack(children: [
                      Container(
                        height: MediaQuery.of(context).size.height * 0.75,
                        child: ListView.builder(
                          itemCount: _searchResult.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    print(selectedExercises);
                                    print(listContains(_searchResult[index], selectedExercises));
                                    print(_searchResult[index]);
                                    // Toggle exercise selection
                                    if (listContains(_searchResult[index], selectedExercises)) {

                                       selectedExercises.removeWhere((exercise) =>
          exercise['id'] == _searchResult[index]['id']);
                                    } else {
                                      selectedExercises
                                          .add(_searchResult[index]);
                                    }
                                    print(selectedExercises);
                                  });
                                  for (var tobeadded in selectedExercises){
                                    _sortExercises(tobeadded['id']);
                                  }
                                },
                                child: Card(
                                  elevation: 4,
                                  margin: EdgeInsets.all(16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ListTile(
                                          title: Text(
                                            _searchResult[index]['name'],
                                            style: TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          trailing: listContains(_searchResult[index], selectedExercises)
                                              ? Icon(Icons.check,
                                                  color: Colors.green)
                                              : Icon(
                                                  Icons.add,
                                                  color: Color(0xFF0F4FA6),
                                                ),
                                        ),
                                        SizedBox(height: 10),
                                        Text(
                                          'Target: ${_searchResult[index]['target']}',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                          'Body Part: ${_searchResult[index]['bodyPart']}',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                          'Equipment: ${_searchResult[index]['equipment']}',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                        SizedBox(height: 20),
                                        Center(
                                          child: Image.network(
                                            '${_searchResult[index]['gifUrl']}', // Replace with your actual image URL
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.3,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.3,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ));
                          },
                        ),
                      ),
                      Positioned(
                        bottom: 64.0,
                        right: 12.0,
                        child: FloatingActionButton(
                          backgroundColor: Color(0xFF0F4FA6),
                          onPressed: () {
                            // Save selected exercises and navigate back to the previous page
                            Navigator.pop(context, selectedExercises);
                          },
                          child: Icon(Icons.check, color:Colors.white),
                        ),
                      ),
                    ])
                  ],
                ));
              }
            }));
  }
}

// return Scaffold(
//       appBar: AppBar(
//         title: Text('Add Exercises'),
//       ),
//       body: ListView.builder(
//         itemCount: exercises.length,
//         itemBuilder: (context, index) {
//           String exercise = exercises[index];
//           return ListTile(
//             title: Text(exercise),
//             trailing: selectedExercises.contains(exercise)
//                 ? Icon(Icons.check, color: Colors.green)
//                 : Icon(Icons.add, color:Colors.blue,),
//             onTap: () {
//               setState(() {
//                 // Toggle exercise selection
//                 if (selectedExercises.contains(exercise)) {
//                   selectedExercises.remove(exercise);
//                 } else {
//                   selectedExercises.add(exercise);
//                 }
//               });
//             },
//           );
//         },
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           // Save selected exercises and navigate back to the previous page
//           Navigator.pop(context, selectedExercises);
//         },
//         child: Icon(Icons.check),
//       ),
//     );

// class SearchBarPage extends StatefulWidget {
//   const SearchBarPage({super.key});

//   @override
//   _SearchBarPageState createState() => _SearchBarPageState();
// }

// class _SearchBarPageState extends State<SearchBarPage> {
//   late var _dataFuture;
//   var bob = "NO";
//   List _searchResult = [];
//   void initState() {
//     super.initState();
//     _dataFuture = FirebaseFirestore.instance.collection('Exercises').doc('List').get();
//     _dataFuture['list'].then((items) {
//       setState(() {
//         _searchResult = List.from(
//             items); // Create a new list with the same contents as items
//       });
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         body: FutureBuilder<List>(
//             future: _dataFuture,
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return Center(
//                   child: CircularProgressIndicator(),
//                 );
//               } else if (snapshot.hasError) {
//                 return Center(
//                   child: Text('Error: ${snapshot.error}'),
//                 );
//               } else {
//                 final items = snapshot.data;

//                 void _filterSearchResults(String query) {
//                   if (query.isNotEmpty) {
//                     var tempList = [];
//                     items!.forEach((item) {
//                       if (item['name']
//                               .toLowerCase()
//                               .contains(query.toLowerCase()) ||
//                           item['target']
//                               .toLowerCase()
//                               .contains(query.toLowerCase()) ||
//                           item['bodyPart']
//                               .toLowerCase()
//                               .contains(query.toLowerCase()) ||
//                           item['equipment']
//                               .toLowerCase()
//                               .contains(query.toLowerCase())) {
//                         tempList.add(item);
//                       }
//                     });
//                     setState(() {
//                       _searchResult = tempList
//                           .toList(); // Create a new list instance with filtered items
//                       bob = "YEA";
//                     }); 
//                   } else {
//                     setState(() {
//                       _searchResult = items!.toList();
//                     });
//                   }
//                   if(query==""){
//                     setState(() {
//                       _searchResult = items!.toList();
//                     });
//                   }
//                 }

//                 return Column(
//                   children: [
//                     Container(height: MediaQuery.of(context).size.height * 0.1),
//                     Padding(
//                       padding: EdgeInsets.all(16.0),
//                       child: TextField(
//                         onChanged: (value) {
//                           _filterSearchResults(value);
//                         },
//                         decoration: InputDecoration(
//                           hintText: 'Search',
//                           prefixIcon: Icon(Icons.search),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(10.0),
//                           ),
//                         ),
//                       ),
//                     ),
//                     Expanded(
//                       child: ListView.builder(
//                         itemCount: _searchResult.length,
//                         itemBuilder: (context, index) {
//                           return Card(
//                             elevation: 4,
//                             margin: EdgeInsets.all(16),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                             child: Padding(
//                               padding: EdgeInsets.all(16),
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     _searchResult[index]['name'],
//                                     style: TextStyle(
//                                       fontSize: 24,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                   SizedBox(height: 10),
//                                   Text(
//                                     'Target: ${_searchResult[index]['target']}',
//                                     style: TextStyle(fontSize: 16),
//                                   ),
//                                   SizedBox(height: 5),
//                                   Text(
//                                     'Body Part: ${_searchResult[index]['bodyPart']}',
//                                     style: TextStyle(fontSize: 16),
//                                   ),
//                                   SizedBox(height: 5),
//                                   Text(
//                                     'Equipment: ${_searchResult[index]['equipment']}',
//                                     style: TextStyle(fontSize: 16),
//                                   ),
//                                   SizedBox(height: 20),
//                                   Center(
//                                     child: Image.network(
//                                       '${_searchResult[index]['gifUrl']}', // Replace with your actual image URL
//                                       height:
//                                           MediaQuery.of(context).size.height *
//                                               0.3,
//                                       width:
//                                           MediaQuery.of(context).size.height *
//                                               0.3,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                   ],
//                 );
//               }
//             }));
//   }
// }

class Planner extends StatefulWidget {
  const Planner({super.key, required this.user});
  final user;
  @override
  _PlannerState createState() => _PlannerState(user: user);
}

class _PlannerState extends State<Planner> {
  _PlannerState({required this.user}) : super();
  var _calendarController = DateRangePickerController();
  final String user;
  var data;
  var now = DateTime.now();
  var value =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day)
          .toString()
          .replaceAll(' 00:00:00.000', '');
  late List workoutRoutines;
  CollectionReference login = FirebaseFirestore.instance.collection('audios');
  void initState() {
    super.initState();
  }

  Future<List> futureData() async {
    // Simulate fetching data from a source (e.g., Firestore)
    return [await login.doc(user).get(), await FirebaseFirestore.instance.collection('Exercises').doc('List').get()];
  }

  Widget build(BuildContext context) {
    return FutureBuilder(
        future: futureData(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text("Something went wrong");
          }
          if (snapshot.connectionState == ConnectionState.done) {
            final List? items = snapshot.data;
            var exerciseItems = items![1]['list'];
            data = (items![0] as DocumentSnapshot).data() as Map;
            if (data['planner'] == null) {
              data['planner'] = {};
            }
            if (data['planner'].containsKey(value)) {
              workoutRoutines = data['planner'][value];
            } else {
              workoutRoutines = [];
            }
            void _navigateToAddExercisePage() async {
              // Navigate to the AddExercisePage and wait for the result (selected exercises)

              final selectedExercises = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddExercisePage(),
                ),
              );

              // Process the selected exercises (e.g., save them to the database or a routine)
              if (selectedExercises != null && selectedExercises.isNotEmpty) {
                // Handle the selected exercises here
                // You can add them to a routine or save them in any way you want
                setState(() {
                  workoutRoutines.addAll(selectedExercises);
                  data['planner'][value] = workoutRoutines;
                });
                await login.doc(user).update({'planner': data['planner']});
              }
            }

            return Scaffold(
                body: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                            height: MediaQuery.of(context).size.height * 0.05),
                        Text(
                          'Your Fitness Planner',
                          style: GoogleFonts.raleway(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 16),
                        // Placeholder for user's fitness goals and progress
                        // You can add charts or progress indicators here

                        SizedBox(height: 24),
                        Text(
                          'Workout Calendar',
                          style: GoogleFonts.raleway(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(height:MediaQuery.of(context).size.height*0.02),
                        Container(
                          height: MediaQuery.of(context).size.height * 0.38,
                          width: MediaQuery.of(context).size.width * 0.9,
                          child: SfDateRangePicker(
                            todayHighlightColor: Color(0xFF0F4FA6),
                            selectionColor: Color(0xFF0F4FA6),
                            initialSelectedDate:
                                DateTime(now.year, now.month, now.day),
                            controller: _calendarController,
                            selectionMode: DateRangePickerSelectionMode
                                .single, // Add this line
                            onSelectionChanged:
                                (DateRangePickerSelectionChangedArgs args) {
                              setState(() {
                                if (args.value is DateTime) {
                                  value = (args.value).toString();
                                  value = value.replaceAll(' 00:00:00.000', '');
                                }
                              });
                            },
                          ),
                        ),
                        Row(children: [
                          Text(
                            'My Routines',
                            style: GoogleFonts.raleway(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                              width: MediaQuery.of(context).size.width * 0.42),
                          FloatingActionButton(
                            elevation: 0.0,
                            backgroundColor: Colors.white,
                            onPressed: () {
                              _navigateToAddExercisePage();
                            },
                            child: Icon(Icons.add, color: Color(0xFF0F4FA6)),
                          ),
                        ]),
                        Stack(children: [
                          SizedBox(
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: workoutRoutines.length,
                              itemBuilder: (context, index) {
                                var routine = workoutRoutines[index];
                                return Stack(children: [
                                  RoutineCard(
                                      routineName: routine,
                                      ExerciseList: exerciseItems),
                                  Positioned(
                                      top: 25,
                                      right: 25,
                                      child: GestureDetector(
                                          onTap: () {
                                            // Handle the click event here
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title:
                                                      Text('Confirm Deletion'),
                                                  content: Text(
                                                      'Are you sure you want to delete this item?'),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      child: Text('Cancel'),
                                                    ),
                                                    TextButton(
                                                      onPressed: () async {
                                                        // Close the dialog without performing any action
                                                        Navigator.of(context)
                                                            .pop();
                                                        setState(() {
                                                          workoutRoutines
                                                              .removeAt(index);
                                                          data['planner']
                                                                  [value] =
                                                              workoutRoutines;
                                                        });
                                                        await login
                                                            .doc(user)
                                                            .update({
                                                          'planner':
                                                              data['planner']
                                                        });
                                                      },
                                                      child: Text('Yes'),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          },
                                          child: Icon(Icons.delete,
                                              color: Colors.red))),
                                ]);
                              },
                            ),
                          ),
                        ])
                      ],
                    ),
                  ),
                ),
                floatingActionButton: FloatingActionButton(
                  backgroundColor: Color(0xFF0F4FA6),
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) =>
                            ChatDialog(data: data, user: user));
                  },
                  child: Icon(Icons.chat),
                ));
          }
          return Center(
            child: CircularProgressIndicator(color:Color(0xFF0F4FA6)),
          );
        });
  }
}

class NewsPage extends StatefulWidget {
  const NewsPage({super.key, required this.totalData});
  final totalData;
  @override
  _NewsPageState createState() => _NewsPageState(totalData: totalData);
}

class _NewsPageState extends State<NewsPage> {
  _NewsPageState({required this.totalData}) : super();
  var totalData;
  late Future<List> newsArticles;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: Colors.black, //change your color here
          ),
          elevation: 0,
          backgroundColor: Colors.white,
          title: Text('News Articles', style: TextStyle(color: Colors.black)),
        ),
        body: Container(
          decoration: BoxDecoration(color: Colors.white),
          child: ListView.builder(
            itemCount: totalData.length,
            itemBuilder: (context, index) {
              final article = totalData[index];
              return NewsArticleCard(article: article);
            },
          ),
        ));
  }
}

class NewsArticleCard extends StatelessWidget {
  final Map<String, dynamic> article;

  NewsArticleCard({required this.article});

  @override
  Widget build(BuildContext context) {
    final String formattedDate = article['date'];
    final String imageUrl = article['image'] != null
        ? article['image']
        : 'https://st3.depositphotos.com/23594922/31822/v/450/depositphotos_318221368-stock-illustration-missing-picture-page-for-website.jpg';
    return Card(
      margin: EdgeInsets.all(10),
      child: ExpansionTile(
        title: Text(
          article['title'], // Title displayed in bold
          style: TextStyle(
            fontWeight: FontWeight.bold, // Make the title bold
          ),
        ),
       leading: Image.network(
        imageUrl,
        width: 50,
        height: 50,
        errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
          // This function gets called when an error occurs while loading the image
          // You can return a different widget here, like another Image.network with a fallback image URL
          return Image.network(
            'https://st3.depositphotos.com/23594922/31822/v/450/depositphotos_318221368-stock-illustration-missing-picture-page-for-website.jpg', // Provide the URL of the fallback image here
            width: 50,
            height: 50,
          );
        },
      ),
        subtitle: Text(formattedDate),
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(article['body']), // Display the entire description
                OutlinedButton(
                  onPressed: () {
                    launchUrl(Uri.parse(article['url']),
                        mode: LaunchMode.externalApplication);
                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.transparent, // Transparent background
                    side:
                        BorderSide(color: Color(0xFF007BFF)), // Add an outline
                  ),
                  child: Text(
                    'Read More',
                    style: TextStyle(
                      color: Color(0xFF007BFF), // Text color
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required this.user});
  final user;
  @override
  _ProfilePageState createState() => _ProfilePageState(user: user);
}

class _ProfilePageState extends State<ProfilePage> {
  _ProfilePageState({required this.user}) : super();
  var user;
  TextEditingController answerController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future:
            FirebaseFirestore.instance.collection('audios').doc('$user').get(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text("Something went wrong");
          }
          if (snapshot.connectionState == ConnectionState.done) {
            final items = snapshot.data;
            var data = (items as DocumentSnapshot).data() as Map;
            var questionAnswerList = data['Information'];
            return Scaffold(
                appBar: AppBar(title: Text('Profile'), backgroundColor: Color(0xFF0F4FA6),),
                body: SingleChildScrollView(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                              height:
                                  MediaQuery.of(context).size.height * 0.025),
                          CircleAvatar(
                            backgroundColor: Color(0xFF0F4FA6),
                            radius: 60.0,
                            child: Icon(
                              Icons.account_circle,
                              size: 120.0,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 16.0),
                          Text(
                            '${data['User']}',
                            style: TextStyle(
                                fontSize: 24.0, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8.0),
                          Text(
                            '${user}',
                            style: TextStyle(fontSize: 16.0),
                          ),
                          Container(
                              height:
                                  MediaQuery.of(context).size.height * 0.025),
                          Divider(
                            color: Color.fromARGB(255, 190, 190, 190),
                            height: 1,
                            thickness: 1,
                          ),
                          Container(
                              height:
                                  MediaQuery.of(context).size.height * 0.025),
                          Text("INFORMATION",
                              style: TextStyle(
                                  fontSize: 24.0, fontWeight: FontWeight.bold)),
                          Container(
                              height:
                                  MediaQuery.of(context).size.height * 0.025),
                          for (var index = 0;
                              index < questionAnswerList.length;
                              index++)
                            Card(
                                elevation: 2,
                                margin: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        questionAnswerList[index]['question'] ??
                                            '',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        questionAnswerList[index]['answer'] ??
                                            '',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                      SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              // Set initial value of the controller
                                              answerController.text =
                                                  questionAnswerList[index]
                                                      ['answer'];

                                              // Open a modal bottom sheet for editing the answer
                                              showModalBottomSheet(
                                                context: context,
                                                isScrollControlled: true,
                                                builder:
                                                    (BuildContext context) {
                                                  return SingleChildScrollView(
                                                    child: Padding(
                                                      padding: EdgeInsets.only(
                                                        bottom: MediaQuery.of(
                                                                context)
                                                            .viewInsets
                                                            .bottom,
                                                      ),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Container(height:MediaQuery.of(context).size.height*0.03),
                                                          Padding(padding: EdgeInsets.fromLTRB(10,0,0,0),
                                                          
                                                          child:Text(
                                                            'Edit Answer',
                                                            style: TextStyle(
                                                                fontSize: 18,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                          ),
                                                          Container(height:MediaQuery.of(context).size.height*0.05),
                                                          Padding(padding:EdgeInsets.fromLTRB(15, 0, 0, 0), child:Text(
                                                            questionAnswerList[
                                                                        index][
                                                                    'question'] ??
                                                                '',
                                                            style: TextStyle(
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          )),
                                                          SizedBox(height: 16),
                                                          Padding(
                                                          padding:EdgeInsets.fromLTRB(MediaQuery.of(context).size.width*0.05,0,0,0),
                                                          child:Container(
                                                            width:MediaQuery.of(context).size.width*0.9,
                                                            child: TextField(
                                                              controller:
                                                                  answerController,
                                                              maxLines: 3,
                                                              decoration:
                                                                  InputDecoration(
                                                                border:
                                                                    OutlineInputBorder(),
                                                                hintText:
                                                                    'Enter your answer...',
                                                              ),
                                                            ),
                                                          )),
                                                          Container(height:MediaQuery.of(context).size.height*0.03),
                                                          Padding(
                                                            padding:EdgeInsets.fromLTRB(MediaQuery.of(context).size.width*0.8,0,0,0),
                                                            child:ElevatedButton(
                                                            style: ElevatedButton.styleFrom(
                                                              backgroundColor: Color(0xFF0F4FA6),
                                                              shape: RoundedRectangleBorder(
                                                              borderRadius: BorderRadius.circular(15.0),
                                                            ),),
                                                            onPressed:
                                                                () async {
                                                              // Save the updated answer and close the bottom sheet
                                                              questionAnswerList[
                                                                          index]
                                                                      [
                                                                      'answer'] =
                                                                  answerController
                                                                      .text;
                                                              await FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                      'audios')
                                                                  .doc(user)
                                                                  .update({
                                                                'Information':
                                                                    questionAnswerList
                                                              });
                                                              Navigator.pop(
                                                                  context);
                                                              setState(() {});
                                                            },
                                                            child: Text('Save'),
                                                          ),
                                                          ),
                                                          Container(height:MediaQuery.of(context).size.height*0.03),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                },
                                              );
                                            },
                                            child: Icon(
                                              Icons.edit,
                                              color: Color(0xFF0F4FA6), // Customize the icon color
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                )),
                        ],
                      ),
                    ),
                  ),
                ));
          }
          return Center(
            child: CircularProgressIndicator(color:Color(0xFF0F4FA6)),
          );
        });
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({
    super.key,
    required this.widgets,
    required this.selectedIndex,
  });
  final widgets;
  var selectedIndex;
  _MyHomePageState createState() =>
      _MyHomePageState(widgets: widgets, selectedIndex: selectedIndex);
}

class _MyHomePageState extends State<MyHomePage> {
  _MyHomePageState({required this.widgets, required this.selectedIndex})
      : super();
  final widgets;
  var selectedIndex;

  void _onItemTapped(int index) async {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widgets.elementAt(selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        backgroundColor: Colors.white,
        selectedLabelStyle: TextStyle(color: Color(0xFF0F4FA6)),
        unselectedLabelStyle: TextStyle(color: Colors.black),
        selectedItemColor: Color(0xFF0F4FA6),
        unselectedItemColor: Colors.black,
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
            ),
            label: 'Hub',
            backgroundColor: Colors.white,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.health_and_safety_sharp),
            label: 'Talk',
            backgroundColor: Colors.white,
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.fitness_center,
            ),
            label: 'Fitness Planner',
            backgroundColor: Colors.white,
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.book,
            ),
            label: 'Posts',
            backgroundColor: Colors.white,
          ),
        ],
        currentIndex: selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

class PostPage extends StatefulWidget {
  final String currentUser;

  PostPage({required this.currentUser});

  @override
  _PostPageState createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  String selectedTitle = 'Posts'; // Default selected title

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.04,
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.97,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 2),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedTitle = 'Posts';
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: selectedTitle == 'Posts'
                          ? Border(
                              bottom: BorderSide(
                                width: 2,
                                color: Colors.black,
                              ),
                            )
                          : null,
                    ),
                    child: Text(
                      'ALL POSTS',
                      style: GoogleFonts.raleway(
                          fontSize: 16,
                          color: selectedTitle == 'Posts'
                              ? Colors.black
                              : Colors.black),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedTitle = 'My Posts';
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: selectedTitle == 'My Posts'
                          ? Border(
                              bottom: BorderSide(
                                width: 2,
                                color: Colors.black,
                              ),
                            )
                          : null,
                    ),
                    child: Text(
                      'MY POSTS',
                      style: TextStyle(
                        fontSize: 16,
                        color: selectedTitle == 'My Posts'
                            ? Colors.black
                            : Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Container(
          //   height:MediaQuery.of(context).size.height*0.125,
          //   color: Colors.grey.shade300, // Background color of the bar
          //   padding: EdgeInsets.symmetric(vertical: 10),
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.center,
          //     children: [
          //       GestureDetector(
          //         onTap: () {
          //           setState(() {
          //             selectedTitle = 'Posts';
          //           });
          //         },
          //         child: Container(
          //           padding: EdgeInsets.symmetric(horizontal: 20),
          //           child: Text(
          //             "All Posts",
          //             style: TextStyle(
          //               fontWeight: FontWeight.bold,
          //               fontSize: 25.0,
          //               decoration: selectedTitle == 'Posts' ? TextDecoration.underline : TextDecoration.none,
          //               color: selectedTitle == 'Posts' ? Colors.blue : Colors.black,
          //             ),
          //           ),
          //         ),
          //       ),
          //       SizedBox(width: 20), // Add spacing between titles
          //       GestureDetector(
          //         onTap: () {
          //           setState(() {
          //             selectedTitle = 'My Posts';
          //           });
          //         },
          //         child: Container(
          //           padding: EdgeInsets.symmetric(horizontal: 20),
          //           child: Text(
          //             "My Posts",
          //             style: TextStyle(
          //               fontWeight: FontWeight.bold,
          //               fontSize: 25.0,
          //               decoration: selectedTitle == 'My Posts' ? TextDecoration.underline : TextDecoration.none,
          //               color: selectedTitle == 'My Posts' ? Colors.blue : Colors.black,
          //             ),
          //           ),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
          Expanded(
              child: PostList(
                  currentUser: widget.currentUser,
                  selectedTitle: selectedTitle)),
          PostForm(currentUser: widget.currentUser),
        ],
      ),
    );
  }
}

class PostList extends StatelessWidget {
  final String currentUser;
  final String selectedTitle; // Declare a parameter

  // Constructor to receive the parameter
  PostList({required this.currentUser, required this.selectedTitle});
  @override
  Future UserName(String userId) async {
    try {
      var docSnapshot = await FirebaseFirestore.instance
          .collection('audios')
          .doc(userId)
          .get();

      if (docSnapshot.exists) {
        Map<String, dynamic> data =
            await docSnapshot.data() as Map<String, dynamic>;
        String userName = data['User'] as String;
        return userName;
      } else {
        print("Document does not exist");
        return null;
      }
    } catch (error) {
      print("Error fetching data: $error");
      return null;
    }
  }

  Future<bool> hasUserLiked(String type, String itemId, String userId) async {
    var querySnapshot = await FirebaseFirestore.instance
        .collection('likes')
        .where('type', isEqualTo: type)
        .where('itemId', isEqualTo: itemId)
        .where('userId', isEqualTo: userId)
        .get();

    return querySnapshot.docs.isNotEmpty;
  }

  Future<void> likePost(String postId, String userId) async {
    // Add a new like document
    await FirebaseFirestore.instance.collection('likes').add({
      'type': 'post',
      'itemId': postId,
      'userId': userId,
    });

    // Update likesCount in the corresponding post document
    await FirebaseFirestore.instance.collection('posts').doc(postId).update({
      'likesCount': FieldValue.increment(1),
    });
  }

  Future<void> unlikePost(String postId, String userId) async {
    // Remove the corresponding like document from the 'likes' collection
    var querySnapshot = await FirebaseFirestore.instance
        .collection('likes')
        .where('type', isEqualTo: 'post')
        .where('itemId', isEqualTo: postId)
        .where('userId', isEqualTo: userId)
        .get();

    for (var doc in querySnapshot.docs) {
      await doc.reference.delete();
    }

    // Update likesCount in the corresponding post document
    await FirebaseFirestore.instance.collection('posts').doc(postId).update({
      'likesCount': FieldValue.increment(-1),
    });
  }

  Future<void> deletePost(String docId) async {
    // Remove the corresponding like document from the 'likes' collection
    var querySnapshot =
        await FirebaseFirestore.instance.collection('posts').get();

    for (var doc in querySnapshot.docs) {
      if (doc.id == docId) await doc.reference.delete();
    }

    // Update likesCount in the corresponding post documen
  }

  void _showPostDetailsAndComments(BuildContext context, String postId,
      String text, String userId, String currentUser) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return FutureBuilder(
          future: UserName(userId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator(color:Color(0xFF0F4FA6)); // While waiting for the data
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              String? userName = snapshot.data;

              return Container(
                height: MediaQuery.of(context).size.height *
                    0.9, // Set your desired height here
                padding: EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("$text",
                          style: TextStyle(
                              fontWeight: FontWeight.w400, fontSize: 20)),
                      SizedBox(height: 5),
                      Text(
                        "Posted By: $userName",
                      ),
                      SizedBox(height: 30),
                      Divider(
                        color: Color.fromARGB(255, 190, 190, 190),
                        height: 1,
                        thickness: 1,
                      ),
                      SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: () {
                          _showCommentPopup(context, postId,
                              currentUser); // Show the comment popup
                        },
                        child: Text('Add Comment'),
                      ),
                      SizedBox(height: 16),
                      Text('Comments:',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      CommentList(postId: postId, user: currentUser),
                      SizedBox(height: 16),
                    ],
                  ),
                ),
              );
            }
          },
        );
      },
    );
  }

  void _showCommentPopup(BuildContext context, String postId, name) {
    TextEditingController _commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add a Comment'),
          content: TextFormField(
            controller: _commentController,
            decoration: InputDecoration(
              labelText: 'Enter your comment...',
            ),
            maxLines: 3,
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                String commentText = _commentController.text;
                if (commentText.isNotEmpty) {
                  await FirebaseFirestore.instance.collection('comments').add({
                    'postId': postId,
                    'userId': currentUser,
                    'userName':
                        await UserName(name), // Replace with actual user ID
                    'text': commentText,
                    'timestamp': FieldValue.serverTimestamp(),
                  });

                  _commentController.clear();
                  Navigator.pop(context); // Close the dialog
                }
              },
              child: Text('Post Comment'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('posts').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator(color:Color(0xFF0F4FA6));
        }
        var posts = snapshot.data!.docs;

        return ListView.builder(
          itemCount: posts.length,
          itemBuilder: (context, index) {
            var post = posts[index];
            var postLikesCount = post['likesCount'] ?? 0;
            var text = post['text'];
            var userId = post['userId'];
            bool isAuthor = userId == currentUser;
            var dateTime = post['timestamp'];
            var formattedDate;
            if (dateTime != null) {
              dateTime = dateTime.toDate();
              formattedDate = DateFormat('M/d/y').format(dateTime);
            } else {
              formattedDate = "Loading...";
            }
            if (selectedTitle == 'My Posts') {
              if (isAuthor) {
                return Container(
                    child: GestureDetector(
                        onTap: () {
                          _showPostDetailsAndComments(
                              context, post.id, text, userId, currentUser);
                        },
                        child: Card(
                          elevation:
                              2, // Adjust the elevation as needed for the desired shadow effect.
                          margin: EdgeInsets.all(10),
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(text,
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                SizedBox(height: 10),
                                Text('Posted: ${formattedDate}'),
                                SizedBox(height: 10),
                                Row(
                                  children: [
                                    FutureBuilder(
                                        future: hasUserLiked(
                                            'post', post.id, currentUser),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return Icon(
                                              Icons.favorite_border,
                                              color: Colors.blue.shade400,
                                            );
                                          }
                                          bool? userLiked = snapshot.data;
                                          return IconButton(
                                            icon: Icon((userLiked ?? false)
                                                ? Icons.favorite
                                                : Icons.favorite_border),
                                            onPressed: () async {
                                              if (userLiked == true) {
                                                // Unlike the post
                                                await unlikePost(
                                                    post.id, currentUser);
                                              } else {
                                                // Like the post
                                                await likePost(
                                                    post.id, currentUser);
                                              }
                                            },
                                            color: Colors.blue.shade400,
                                          );
                                        }),
                                    SizedBox(width: 5),
                                    Text("${postLikesCount}"),
                                    Spacer(), // Adds spacing between like count and delete button
                                    if (isAuthor)
                                      IconButton(
                                        icon: Icon(Icons.delete,
                                            color: Colors.red),
                                        onPressed: () {
                                          // Show a confirmation dialog and delete the post if confirmed
                                          showDialog(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: Text('Delete Post'),
                                              content: Text(
                                                  'Are you sure you want to delete this post?'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(
                                                        context); // Close the dialog
                                                  },
                                                  child: Text('Cancel'),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    // Delete the post and navigate back to the posts page
                                                    // You need to implement the delete function
                                                    deletePost(post.id);
                                                    Navigator.pop(
                                                        context); // Close the dialog
                                                  },
                                                  child: Text('Delete'),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        )));
              }
            } else {
              return Container(
                  child: GestureDetector(
                      onTap: () {
                        _showPostDetailsAndComments(
                            context, post.id, text, userId, currentUser);
                      },
                      child: Card(
                        elevation:
                            2, // Adjust the elevation as needed for the desired shadow effect.
                        margin: EdgeInsets.all(10),
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(text,
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              SizedBox(height: 10),
                              Text('Posted: ${formattedDate}'),
                              SizedBox(height: 10),
                              Row(
                                children: [
                                  FutureBuilder(
                                      future: hasUserLiked(
                                          'post', post.id, currentUser),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return Icon(Icons.favorite_border);
                                        }
                                        bool? userLiked = snapshot.data;
                                        return IconButton(
                                          icon: Icon(
                                              color: Colors.blue.shade400,
                                              (userLiked ?? false)
                                                  ? Icons.favorite
                                                  : Icons.favorite_border),
                                          onPressed: () async {
                                            if (userLiked == true) {
                                              // Unlike the post
                                              await unlikePost(
                                                  post.id, currentUser);
                                            } else {
                                              // Like the post
                                              await likePost(
                                                  post.id, currentUser);
                                            }
                                          },
                                        );
                                      }),
                                  SizedBox(width: 5),
                                  Text("${postLikesCount}"),
                                  Spacer(), // Adds spacing between like count and delete button
                                  if (isAuthor)
                                    IconButton(
                                      icon:
                                          Icon(Icons.delete, color: Colors.red),
                                      onPressed: () {
                                        // Show a confirmation dialog and delete the post if confirmed
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: Text('Delete Post'),
                                            content: Text(
                                                'Are you sure you want to delete this post?'),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(
                                                      context); // Close the dialog
                                                },
                                                child: Text('Cancel'),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  // Delete the post and navigate back to the posts page
                                                  // You need to implement the delete function
                                                  deletePost(post.id);
                                                  Navigator.pop(
                                                      context); // Close the dialog
                                                },
                                                child: Text('Delete'),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      )));
            }
          },
        );
      },
    );
  }
}

class CommentList extends StatelessWidget {
  final String postId;
  final String user;

  CommentList({required this.postId, required this.user});
  Future<void> deleteComment(String docId) async {
    // Remove the corresponding like document from the 'likes' collection
    var querySnapshot =
        await FirebaseFirestore.instance.collection('comments').get();

    for (var doc in querySnapshot.docs) {
      if (doc.id == docId) await doc.reference.delete();
    }

    // Update likesCount in the corresponding post documen
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('comments')
          .where('postId', isEqualTo: postId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator(color:Color(0xFF0F4FA6));
        }

        var comments = snapshot.data!.docs;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var comment in comments)
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200], // Set comment background color
                  borderRadius: BorderRadius.circular(8.0),
                ),
                margin: EdgeInsets.symmetric(vertical: 4.0),
                padding: EdgeInsets.all(8.0),
                child: ListTile(
                  trailing: comment['userId'] == user
                      ? IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            deleteComment(comment.id);
                          },
                        )
                      : null,
                  title: Text(comment['text']),
                  subtitle: Text('User: ${comment['userName']}'),
                ),
              ),
          ],
        );
      },
    );
  }
}

class SubscriptionPage extends StatefulWidget {
  var currentCredits;
  var user;
  SubscriptionPage({required this.currentCredits, required this.user});
  @override
  _SubscriptionPageState createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  var paymentIntent;
  Future<void> makePayment(var amount, var creditsToAdd) async {
    try {
      //STEP 1: Create Payment Intent
      paymentIntent = await createPaymentIntent('$amount', 'USD');
      //STEP 2: Initialize Payment Sheet
      await stripe.Stripe.instance
          .initPaymentSheet(
              paymentSheetParameters: stripe.SetupPaymentSheetParameters(
                  paymentIntentClientSecret: paymentIntent[
                      'client_secret'], //Gotten from payment intent
                  style: ThemeMode.light,
                  merchantDisplayName: 'Ikay'))
          .then((value) {});
      //STEP 3: Display Payment sheet
      await displayPaymentSheet(creditsToAdd);
    } catch (err) {
      throw Exception(err);
    }
  }

  createPaymentIntent(String amount, String currency) async {
    try {
      //Request body
      Map<String, dynamic> body = {
        'amount': "$amount",
        'currency': currency,
      };

      //Make post request to Stripe
      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer ${dotenv.env['STRIPE_SECRET']}',
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: body,
      );
      return json.decode(response.body);
    } catch (err) {
      throw Exception(err.toString());
    }
  }

  displayPaymentSheet(var creditsToAdd) async {
    try {
      await stripe.Stripe.instance.presentPaymentSheet().then((value) async {
        //Clear paymentIntent variable after successful payment
        paymentIntent = null;
        await FirebaseFirestore.instance
            .collection('audios')
            .doc('${widget.user}')
            .update({'Credits': widget.currentCredits + creditsToAdd});
        Navigator.pop(context);
        setState(() {});
      }).onError((error, stackTrace) {
        throw Exception(error);
      });
    } on stripe.StripeException catch (e) {
      print('Error is:---> $e');
    } catch (e) {
      print('$e');
    }
  }

  var _amount;
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Purchase Page'),
        backgroundColor: Color(0xFF0F4FA6),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 20.0),
            Padding(
              padding: EdgeInsets.all(15),
              child: Text(
                'Enter the amount of credits you would like to purchase.',
                style: TextStyle(fontSize: 20.0),
                textAlign:TextAlign.center,
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height*0.001),
            Padding(
              padding: EdgeInsets.all(15),
              child: Text(
                '(A minimum of 100 credits is required for purchase)',
                style: TextStyle(fontSize: 13.0, color:Colors.grey),
                textAlign:TextAlign.center,
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height*0.05),
            AmountTextField(
              onChanged: (amount) {
                // Use the entered amount in your logic
                setState(() {
                  _amount = amount;
                });
              },
            ),
            Container(height:MediaQuery.of(context).size.height*0.02),
            Container(
            width:MediaQuery.of(context).size.width*0.9,
            height:MediaQuery.of(context).size.height*0.05,
            child:ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF0F4FA6)),
              onPressed: () {
                if(_amount>=100){
                  makePayment((_amount * 1).round(), _amount);
                }
                // Implement payment logic here
                // You can navigate to a payment screen or handle payment processing.
                // For simplicity, we'll just display a message for now.
                // fetchOffers,
              },
              child: Text('Pay Now'),
            ),
            ),
            SizedBox(height: 20.0),
          ],
        ),
      ),
    );
  }
}

class PostForm extends StatefulWidget {
  final String currentUser; // Declare the parameter

  PostForm({required this.currentUser});
  @override
  _PostFormState createState() => _PostFormState();
}

class _PostFormState extends State<PostForm> {
  TextEditingController _postController = TextEditingController();

  void _createPost() async {
    String postText = _postController.text;
    if (postText.isNotEmpty) {
      // Get the current user's ID (this depends on your authentication setup)
      String currentUserId = widget.currentUser; // Replace with actual user ID

      // Save the post to Firebase Firestore
      DocumentReference postRef =
          await FirebaseFirestore.instance.collection('posts').add({
        'text': postText,
        'userId': currentUserId,
        'timestamp': FieldValue.serverTimestamp(),
        'likesCount': 0,
      });

      _postController.clear();
      setState(() {});

      // Create a comment for the newly created post
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Stack(
          alignment:
              Alignment.bottomRight, // Aligns content to the bottom right
          children: [
            TextFormField(
              controller: _postController,
              decoration: InputDecoration(
                labelText: 'Write your post...',
              ),
              maxLines: 2,
            ),
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: _createPost,
                child: Icon(Icons.send, color: Colors.black),
              ),
            ),
          ],
        ));
  }
}

class AmountTextField extends StatefulWidget {
  final ValueChanged<int> onChanged;

  AmountTextField({Key? key, required this.onChanged}) : super(key: key);

  @override
  _AmountTextFieldState createState() => _AmountTextFieldState();
}

class _AmountTextFieldState extends State<AmountTextField> {
  TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_updateFormattedAmount);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateFormattedAmount() {
    final enteredText = _controller.text;
    int cents = 0;
    var amount;

    if (enteredText.isNotEmpty) {
      amount = double.tryParse(enteredText) ?? 0.0;
    }

    // Notify the parent widget about the changed amount in cents
    widget.onChanged(amount.round());
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _controller,
        keyboardType: TextInputType.numberWithOptions(),
        decoration: InputDecoration(
          labelText: 'Enter Amount',
          prefixIcon: Icon(Icons.stars_rounded),
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.user});
  final user;
  @override
  _HomePageState createState() => _HomePageState(user: user);
}

class _HomePageState extends State<HomePage> {
  var user;
  var data;
  _HomePageState({required this.user}) : super();
  var value =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  // .toString()
  // .replaceAll(' 00:00:00.000', '');
  String value2 =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day)
          .toString()
          .replaceAll(' 00:00:00.000', '');
  late var combinedList = [];
  late var newData = {};
  late List workoutRoutines;
  var _newstrue=false;
  var _isLoading=true;
  final ValueNotifier<String> selectedFeeling = ValueNotifier<String>('');
  CollectionReference login = FirebaseFirestore.instance.collection('audios');
  void initState() {
    combinedList = [];
    super.initState();
    fetchNews();
  }
  var article = [];
  List NewsData(int index) {
    final desc = article[index]['body'];
    final name = article[index]['title'];
    final url = article[index]['url'];
    final String formattedDate = article[index]['date'];
    final String imageUrl = article![index]['image'] != null &&
            article[index]['image']!= null
        ? article[index]['image']
        : (article[index]['image'] != null
            ? article[0]['image']
            : 'https://st3.depositphotos.com/23594922/31822/v/450/depositphotos_318221368-stock-illustration-missing-picture-page-for-website.jpg');
    return ([name, desc, formattedDate, imageUrl, url]);
  }

Future<void> fetchNews() async {
  final headers = {
    "content-type": "application/json",
    "X-RapidAPI-Key": "24d7fdb755mshe9ad7b273211de1p160e9bjsn32244367e3e3",
    "X-RapidAPI-Host": "google-api31.p.rapidapi.com"
  };
  Map<String, dynamic> payload = {
    "text": "Health",
    "region": "us-en,",
    "max_results": 100
};

  var response = await http.post(
    Uri.parse(
        'https://google-api31.p.rapidapi.com/'),
    headers: headers,
    body: json.encode(payload),
  );

  if (response.statusCode == 200) {
    // Request succeeded, parse the response
    var data = json.decode(response.body);
    // Handle the data
    combinedList=[];
    setState(() {
      article=data["news"];
      _isLoading = false;
      _newstrue=true;
    });
  } else {
    // Request failed
    setState((){
      _isLoading=false;
      _newstrue=false;
    });
  }
}

  Future<List> futureData() async {
    // Simulate fetching data from a source (e.g., Firestore)
    return [
      await login.doc(user).get(),
      await FirebaseFirestore.instance.collection('Exercises').doc('List').get(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: FutureBuilder(
            future: futureData(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text("Something went wrong");
              }
              if (snapshot.connectionState == ConnectionState.done) {
                final List? items = snapshot.data;
                var exerciseItems = items![1]['list'];
                var quote = items![1]['quote'];
                combinedList = [];
                data = (items![0] as DocumentSnapshot).data() as Map;
                if (data['planner'] == null) {
                  data['planner'] = {};
                }

                var thresholdDateString = DateTime(DateTime.now().year,
                    DateTime.now().month, DateTime.now().day);
                newData = data['planner'];
                (newData).forEach((date, listOfDicts) {
                  DateTime dt1 = DateTime.parse("$date 00:00:00");
                  for (var i = 0; i < listOfDicts.length; i++) {
                    listOfDicts[i]['date'] = date;
                  }
                  if (dt1.compareTo(thresholdDateString) >= 0) {
                    if(combinedList!=listOfDicts){
                      combinedList.addAll(listOfDicts);
                    }
                  }

                  combinedList.sort((a, b) {
                    DateTime dt1 = DateTime.parse("${a["date"]} 00:00:00");
                    DateTime dt2 = DateTime.parse("${b["date"]} 00:00:00");
                    return dt1.compareTo(dt2);
                  });
                });
                var files = [];

                Future<void> saveGifsAsFiles(var gifUrls) async {
                  var index=0;
                  for (var url in gifUrls) {
                    if(index>1220){
                      File file = await DefaultCacheManager().getSingleFile(url['gifUrl']);
                      files.add(file);
                    }
                    index=index+1;
                  }
                }

                Future<void> uploadGifsToFirebaseStorage(List files, gifUrls) async {
                  final FirebaseStorage storage = FirebaseStorage.instance;
                  var index=1221;
                  for (File file in files) {
                    // Create a reference to the location you want to upload to
                    Reference ref = storage.ref().child('gifs/${gifUrls[index]['name']}.gif');
                    index=index+1;

                    // Upload the file to Firebase Storage
                    await ref.putFile(file);
                  }
                }
                Future<void> addListToDocument(List<dynamic> listData) async {
                  try {
                    // Reference to the document in the "Exercises" collection
                    DocumentReference docRef = FirebaseFirestore.instance.collection('Exercises').doc('List');

                    // Update the document with the list data
                    await docRef.set({
                      'list': listData,
                    }, SetOptions(merge: true)); // Use merge to merge the new data with existing data if the document exists
                  } catch (error) {
                    print('Error adding list to document: $error');
                    throw error; // Throw the error for handling at a higher level if needed
                  }
                }

                Future<void> processUpload(gifUrls) async {
                  await saveGifsAsFiles(exerciseItems); // Wait for GIFs to be saved
                  await uploadGifsToFirebaseStorage(files, gifUrls); // Wait for GIFs to be uploaded
                }
                Future<void> convertToFirestore() async{
                  var data=exerciseItems;
                  for (int i = 0; i < data.length; i++) {
                    if(data[i]['name']=='3/4 sit-up'){
                      data[i]['gifUrl']="https://firebasestorage.googleapis.com/v0/b/healthcare-393311.appspot.com/o/gifs%2F3%3A4%20sit-up.gif?alt=media&token=13e74d4d-cc73-4eb0-b38c-398c90021bbd";
                    }
                    else{
                      Reference ref = FirebaseStorage.instance.ref().child('gifs/${data[i]['name']}.gif');
                      String downloadURL = await ref.getDownloadURL();
                      data[i]['gifUrl']="${downloadURL}";
                    }
                  }
                  addListToDocument(data);
                  
                }



                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      // Welcome Message
                      Container(
                          height: MediaQuery.of(context).size.height * 0.05),
                      Row(children: [
                        _buildTitle('Welcome back,'),
                        Text(
                          '${data['User']}',
                          style: GoogleFonts.raleway(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Spacer(),
                        _buildProfile(),
                      ]),
                      if (data[value2] == null)
                        Divider(thickness: 1.0, color: Colors.black),
                      if (data[value2] == null)
                        Container(
                            height: MediaQuery.of(context).size.height * 0.01),
                      Container(
                          height: MediaQuery.of(context).size.height * 0.01),
                      GestureDetector(
                      onTap:(){
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>ChatScreen(user:"$user"),
                            //MyHomePage(widgets: [
                            //   HomePage(user: "$user"),
                            //   ChatScreen(user: "$user"),
                            //   Planner(user: "$user"),
                            //   JournalPage(user: "$user"),
                            //   // ProfilePage(user:"$email"),
                            // ], selectedIndex: 1),
                          ),
                        );
                      },
                      child:Align(
                          alignment: Alignment.center,
                          child: Container(
                              width: MediaQuery.of(context).size.width * 0.95,
                              height: MediaQuery.of(context).size.height * 0.2,
                              child: Stack(
                                children: [
                                  Positioned(
                                    left: 0,
                                    top: 0,
                                    child: Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.95,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.2,
                                      decoration: ShapeDecoration(
                                        color: Color(0xFF0F4FA6),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(13),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: MediaQuery.of(context).size.width *
                                        0.06,
                                    top: MediaQuery.of(context).size.height *
                                        0.055,
                                    child: SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.4,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.1,
                                      child: Text(
                                        'Not Feeling It?\nHave a Talk.',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontFamily: 'Raleway',
                                          fontWeight: FontWeight.w700,
                                          height: 0,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: MediaQuery.of(context).size.width *
                                        0.06,
                                    top: MediaQuery.of(context).size.height *
                                        0.115,
                                    child: _buildTalkButton(),
                                  ),
                                  Positioned(
                                    left: MediaQuery.of(context).size.width *
                                        0.52,
                                    top: MediaQuery.of(context).size.height *
                                        0.001,
                                    child: Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.4,
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.2,
                                        child: Image.asset(
                                            'assets/images/homepagehealth.png')),
                                  ),
                                ],
                              )))),
                      Container(
                          height: MediaQuery.of(context).size.height * 0.02),
                      // Today's Exercises
                      _buildSectionTitle("Upcoming Exercises"),
                      Container(
                          height: MediaQuery.of(context).size.height * 0.01),
                      if (combinedList.length == 0)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.05,
                            width: MediaQuery.of(context).size.width * 0.9,
                            decoration:BoxDecoration(color:const Color.fromARGB(255, 203, 203, 203), borderRadius:BorderRadius.circular(12.0),),
                            alignment:Alignment.center,
                            child:Text(
                              "No exercises at the moment",
                              style: GoogleFonts.raleway(
                                fontSize: 16,
                              ),
                            ),
                          )
                        ),
                        Container(
                            height: MediaQuery.of(context).size.height * 0.0025),
                      if (combinedList.length != 0)
                        Container(
                            height: MediaQuery.of(context).size.height * 0.3,
                            child: SingleChildScrollView(
                                child: ListView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: combinedList.length,
                                    itemBuilder: (context, index) {
                                      var routine = combinedList[index];
                                      return Stack(children: [
                                        SmallRoutineCard(
                                            routineName: routine,
                                            ExerciseList: exerciseItems)
                                      ]);
                                    }))),
                      Container(
                          height: MediaQuery.of(context).size.height * 0.01),
                      // You can add your exercise list here

                      // Divider
                      Row(children: [
                        _buildSectionTitle("Latest News"),
                        Container(
                            width: MediaQuery.of(context).size.width * 0.25),
                        _isLoading
                          ?Center(
                            
                          )
                          :_newstrue
                            ?GestureDetector(
                              child: Text("View All"),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        NewsPage(totalData: article),
                                  ),
                                );
                              })
                              :Center(
                            
                              )
                      ]),

                      Container(
                          height: MediaQuery.of(context).size.height * 0.01),
                      _isLoading
                      ?Center(
                        child: CircularProgressIndicator(color:Color(0xFF0F4FA6)),
                      )
                      :_newstrue
                        ?Container(
                          height: MediaQuery.of(context).size.height * 0.4,
                          width: MediaQuery.of(context).size.width,
                          child: ListView(
                            scrollDirection:
                                Axis.horizontal, // Horizontal scrolling
                            children: <Widget>[
                              SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.03),
                              NewsItemWidget(
                                  title: NewsData(0)[0],
                                  image: NewsData(0)[3],
                                  description: NewsData(0)[1],
                                  url: NewsData(0)[4]),
                              SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.03),
                              NewsItemWidget(
                                  title: NewsData(1)[0],
                                  image: NewsData(1)[3],
                                  description: NewsData(1)[1],
                                  url: NewsData(1)[4]),
                              SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.03),
                              NewsItemWidget(
                                  title: NewsData(2)[0],
                                  image: NewsData(2)[3],
                                  description: NewsData(2)[1],
                                  url: NewsData(2)[4]),
                              SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.03),
                              NewsItemWidget(
                                  title: NewsData(3)[0],
                                  image: NewsData(3)[3],
                                  description: NewsData(3)[1],
                                  url: NewsData(3)[4]),
                              SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.03),
                              // Add more items as needed
                            ],
                          ),
                        )
                        :Center(child:Text("Failed to load news articles. Please try again later.")),
                        
                      Container(
                          height: MediaQuery.of(context).size.height * 0.01),
                      // Row(children: [
                      //   Container(
                      //       width: MediaQuery.of(context).size.width * 0.05),
                      //   ElevatedButton(
                      //       child: Text("View All"),
                      //       onPressed: () {
                      //         Navigator.push(
                      //           context,
                      //           MaterialPageRoute(
                      //             builder: (context) =>
                      //                 NewsPage(totalData: article),
                      //           ),
                      //         );
                      //       }),
                      //   Container(
                      //       width: MediaQuery.of(context).size.width * 0.2),
                      // ]),
                      Container(
                          height: MediaQuery.of(context).size.height * 0.01),
                      // You can add your exercise list here

                      _buildSectionTitle('Quote Of The Day'),
                      Container(
                          height: MediaQuery.of(context).size.height * 0.025),
                      _buildRandomQuote(quote),

                      // Divider
                    ],
                  ),
                );
              }
              return Center(
                child: CircularProgressIndicator(color:Color(0xFF0F4FA6)),
              );
            }));
  }

  Widget buildFeelingEmoji(String emoji, String feeling) {
    return GestureDetector(
      onTap: () async {
        setState(() {
          selectedFeeling.value = feeling;
        });
        await FirebaseFirestore.instance
            .collection('audios')
            .doc('$user')
            .update({'$value2': selectedFeeling.value});
      },
      child: Container(
        margin: EdgeInsets.all(10),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          color: selectedFeeling.value == feeling ? Colors.blue : Colors.grey,
        ),
        child: Text(
          emoji,
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.55,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          text,
          style: GoogleFonts.raleway(
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildProfile() {
    return PopupMenuButton<String>(
      icon: Icon(Icons.person_rounded, color: Color(0xFF0F4FA6)),
      onSelected: (value) async {
        // Handle item selection here
        if (value == 'Logout') {
          SharedPreferences pref = await SharedPreferences.getInstance();
          pref.setString("email", "");
          FirebaseAuth.instance.signOut();
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => LoginPage()));
        } else if (value == 'Profile') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProfilePage(user: user),
            ),
          );
        } else if (value == 'Feedback') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FeedbackPage(user: user),
            ),
          );
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: 'Profile',
          child: Text('Profile'),
        ),
        PopupMenuItem<String>(
          value: 'Feedback',
          child: Text(
            'Feedback',
            style: TextStyle(color: Colors.black),
          ),
        ),
        PopupMenuItem<String>(
          value: 'Logout',
          child: Text(
            'Logout',
            style: TextStyle(color: Colors.red),
          ),
        ),
      ],
    );
  }

  Widget _buildTitle(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 5.0, 16.0),
      child: Text(
        text,
        style: GoogleFonts.raleway(
          fontSize: 24, // Adjust the font size as needed
          // Adjust the font weight as needed
          // You can also set other text styles here
        ),
      ),
    );
  }

  Widget _buildSectionSubtitle(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  Widget _buildTalkButton() {
    return Row(children: [
      Text(
        'Talk to Eva',
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontFamily: 'Raleway',
          height: 0,
        ),
      ),
      IconButton(
        icon: const Icon(Icons.arrow_circle_right_outlined),
        color: Colors.white,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>ChatScreen(user:"$user"),
              //MyHomePage(widgets: [
              //   HomePage(user: "$user"),
              //   ChatScreen(user: "$user"),
              //   Planner(user: "$user"),
              //   JournalPage(user: "$user"),
              //   // ProfilePage(user:"$email"),
              // ], selectedIndex: 1),
            ),
          );
        },
      )
    ]);
  }

  Widget _buildRandomQuote(quote) {
    // You can add your random quote widget here
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Text(
        "$quote",
        style: TextStyle(
          fontSize: 16,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
}

class NewsItemWidget extends StatelessWidget {
  final String image;
  final String title;
  final String description;
  final String url;
  NewsItemWidget({
    required this.image,
    required this.title,
    required this.description,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.3,
      width: MediaQuery.of(context).size.width * 0.5,
      decoration: BoxDecoration(
        color: Color(0xFF0F4FA6),
        border: Border.all(
          color: Colors.black, // Border color
          width: 2.0, // Border width
        ),
      ),
      child: Center(
        child: Column(
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            Container(
              height: MediaQuery.of(context).size.height * 0.06,
              child: Text(
                title.length > 15 ? title.substring(0, 15) + "..." : title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            Container(
              height:
                  MediaQuery.of(context).size.height * 0.16, // Adjusted height
              width: MediaQuery.of(context).size.height * 0.16,
              child: Image.network(
                "$image",
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            Container(
              height: MediaQuery.of(context).size.height * 0.05,
              padding: EdgeInsets.only(left: 16.0),
              child: Text(
                description.length > 60
                    ? description.substring(0, 60) + "..."
                    : description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (BuildContext context) {
                    return SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              '${title}',
                              style: TextStyle(
                                fontSize: 24.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 12.0),
                            Image.network(
                              '${image}', // Replace with your news image URL
                              fit: BoxFit.cover,
                            ),
                            SizedBox(height: 12.0),
                            Text(
                              '${description}',
                              style: TextStyle(fontSize: 16.0),
                            ),
                            SizedBox(height: 16.0),
                            OutlinedButton(
                              onPressed: () {
                                launchUrl(Uri.parse(url),
                                    mode: LaunchMode.externalApplication);
                              },
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Colors
                                    .transparent, // Transparent background
                                side: BorderSide(
                                    color: Color(0xFF007BFF)), // Add an outline
                              ),
                              child: Text(
                                'Read More',
                                style: TextStyle(
                                  color: Color(0xFF007BFF), // Text color
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              child: Container(
                alignment: Alignment.center,
                height: MediaQuery.of(context).size.height * 0.063,
                decoration: BoxDecoration(color: Colors.white),
                child: Text("Learn More"),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class ShadedContainer extends StatelessWidget {
  final color;
  final Widget child;

  ShadedContainer({required this.color, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.45,
      height: MediaQuery.of(context).size.height * 0.2,
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        image: DecorationImage(
          colorFilter: ColorFilter.mode(
            Colors.white
                .withOpacity(0.45), // Adjust the opacity value as needed
            BlendMode.srcOver,
          ),
          image: NetworkImage("$color"),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.circular(10.0),
        // boxShadow: [
        //   BoxShadow(
        //     spreadRadius: 2,
        //     blurRadius: 5,
        //     offset: Offset(0, 3),
        //   ),
        // ],
      ),
      child: child,
    );
  }
}

class ContainerContent extends StatelessWidget {
  final String title;
  final String description;

  ContainerContent({required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10), // Rounded corners
          ),
          child: Text(
            title.length > 9
                ? title.substring(0, 9) +
                    "..." // Truncate text if it exceeds the character limit
                : title,
            style: TextStyle(
              fontSize: 20,
              shadows: [
                // Shadow(
                //   color: Colors.white, // Shadow color
                //   offset: Offset(1, 1), // Shadow offset
                //   blurRadius: 2, // Shadow blur radius
                // ),
              ],
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        SizedBox(height: 8.0),
        Container(
          height: MediaQuery.of(context).size.height * 0.11,
          width: MediaQuery.of(context).size.width * 0.3,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10), // Rounded corners
          ),
          child: Text(
            description.length > 35
                ? description.substring(0, 35) +
                    "..." // Truncate text if it exceeds the character limit
                : description,
            style: TextStyle(
              shadows: [
                // Shadow(
                //   color: Colors.white, // Shadow color
                //   offset: Offset(1, 1), // Shadow offset
                //   blurRadius: 2, // Shadow blur radius
                // ),
              ],
              fontSize: 16,
              color: Colors.black,
            ),
          ),
        )
      ],
    );
  }
}
class JournalPage extends StatefulWidget {
  const JournalPage(
      {super.key, required this.user});
  final user;
  @override
  _JournalPageState createState() =>
      _JournalPageState(user: user);
}

class _JournalPageState extends State<JournalPage> {
  var user;
  _JournalPageState({
    required this.user,
  });
  var currentDate=DateTime.now();
  var randomprompt=(getUserTypeFirebase().toList()..shuffle()).first;
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future:
            FirebaseFirestore.instance.collection('audios').doc('$user').get(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text("Something went wrong");
          }
          if (snapshot.connectionState == ConnectionState.done) {
            final items = snapshot.data;
            var data = (items as DocumentSnapshot).data() as Map;
            var journalList = data['journal'];
            return Scaffold(
                body: SingleChildScrollView(child:Column(
                  children: [
                    Container(
                        height: MediaQuery.of(context).size.height * 0.07),
                    Container(
                      width:MediaQuery.of(context).size.width*0.95,
                      child:
                      CalendarTimeline(
                        initialDate: currentDate,
                        firstDate: DateTime(2015, 1, 1),
                        onDateSelected: (date)=>setState((){currentDate=date;}),
                        lastDate: DateTime(2025, 12, 31),
                        leftMargin: 20,
                        monthColor: Colors.blueGrey,
                        dayColor: Colors.teal[200],
                        activeDayColor: Colors.white,
                        activeBackgroundDayColor: Color(0xFF0F4FA6),
                        dotsColor: Colors.white,
                      ),
                    ),
                    Container(
                        height: MediaQuery.of(context).size.height * 0.04),
                    GestureDetector(onTap:(){
                              Navigator.push(
                              context,
                              MaterialPageRoute(
                                 builder: (context) =>
                                  AddEntryPage(journalList: journalList, user: user, isprompt:true, prompt:"${randomprompt}"),
                              ));
                            }, child:Container(
                      width:MediaQuery.of(context).size.width * 0.9,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0),
                        border: Border.all(color: Color(0xFF0F4FA6), width: 2.0),
                      ),
                      child: Column(
                        children: [
                          Container(
                            height: MediaQuery.of(context).size.height * 0.01),
                          Text(
                            "Random Prompt",
                            style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10.0),
                          Container(
                          width:MediaQuery.of(context).size.width * 0.8,
                          child:Text(
                            "${randomprompt}",
                            style: TextStyle(fontSize: 16.0),
                          )),
                          SizedBox(height: 10.0),
                          Row(children:[Container(width:MediaQuery.of(context).size.width*0.77), Icon(Icons.arrow_forward, color:Color(0xFF0F4FA6))]),
                          Container(height:MediaQuery.of(context).size.height*0.01)
                          // Align(
                          
                          // alignment:Alignment.center,
                          // child:ElevatedButton(
                          //   style:ElevatedButton.styleFrom(backgroundColor:Colors.white, side:BorderSide(color:Color(0xFF0F4FA6))),
                          //   onPressed: (){
                          //     Navigator.push(
                          //     context,
                          //     MaterialPageRoute(
                          //        builder: (context) =>
                          //         AddEntryPage(journalList: journalList, user: user, isprompt:true, prompt:"${randomprompt}"),
                          //     ));
                          //   },
                          //   child: Text("Answer", style:TextStyle(color:Colors.black)),
                          // ),)
                        ],
                      ),
                    )),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding:
                            const EdgeInsets.fromLTRB(16.0, 16.0, 5.0, 0.0),
                        child: Text(
                          "Your Journals",
                          style: GoogleFonts.raleway(
                            fontSize: 24,
                            fontWeight: FontWeight
                                .bold, // Adjust the font size as needed
                            // Adjust the font weight as needed
                            // You can also set other text styles here
                          ),
                        ),
                      ),
                    ),
                    Container(
                        height: MediaQuery.of(context).size.height * 0.00),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.425,
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: ListView.builder(
                        itemCount: journalList.length, // Number of items
                        itemBuilder: (context, index) {
                          if(DateFormat('yyyy-MM-dd').format(DateFormat('yyyy-MM-dd').parse(journalList[index]['date']))==DateFormat('yyyy-MM-dd').format(currentDate)){
                            return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ViewEntryPage(
                                          journalList: journalList[index], user:user, totalJournals:journalList),
                                    ),
                                  );
                                },
                                child: Column(children: [
                                  Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.black,
                                          width: 1,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      width: MediaQuery.of(context).size.width *
                                          0.85,
                                      height: MediaQuery.of(context).size.height *
                                          0.1,
                                      child: Row(children: [
                                        Container(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.1,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.1,
                                            decoration: BoxDecoration(
                                                color: Color(0xFF0F4FA6),
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            child: Center(
                                                child: Column(children: [
                                              Container(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.016),
                                              Text("${DateFormat('MMM').format(DateTime.parse(journalList[index]['date']))}",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 18.0)),
                                              Text('${DateFormat('dd').format(DateTime.parse(journalList[index]['date']))}',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.white,
                                                      fontSize: 18.0))
                                            ]))),
                                        Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.04),
                                        Container(
                                          child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                    height: MediaQuery.of(context)
                                                            .size
                                                            .height *
                                                        0.01),
                                                Container(
                                                    child: Text(
                                                        '${journalList[index]['title']}'
                                                                    .length >20
                                                              
                                                            ? '${journalList[index]['title']}'
                                                                    .substring(
                                                                        0, 20) +
                                                                "..." // Truncate text if it exceeds the character limit
                                                            : '${journalList[index]['title']}',
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 18.0))),
                                                Container(
                                                    height: MediaQuery.of(context)
                                                            .size
                                                            .height *
                                                        0.01),
                                                Container(
                                                    child: Text(
                                                  '${journalList[index]['description']}'
                                                              .length >
                                                          25
                                                      ? '${journalList[index]['description']}'
                                                              .substring(0, 25) +
                                                          "..." // Truncate text if it exceeds the character limit
                                                      : '${journalList[index]['description']}',
                                                  overflow: TextOverflow.ellipsis,
                                                  style: GoogleFonts.raleway(
                                                    fontSize: 15,
                                                    // Adjust the font size as needed
                                                    // Adjust the font weight as needed
                                                    // You can also set other text styles here
                                                  ),
                                                )),
                                              ]),
                                        )
                                      ])),
                                  Container(
                                      height: MediaQuery.of(context).size.height *
                                          0.02),
                                ]
                              )
                            );
                          }else {
                            return SizedBox.shrink(); // Return an empty widget if the condition is not met
                          }
                          },
                        ),
                    ),
                  ],
                ),
                ),
                floatingActionButton: FloatingActionButton(
                  backgroundColor: Color(0xFF0F4FA6),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AddEntryPage(journalList: journalList, user: user, isprompt:false, prompt:""),
                      ),
                    ).then((value) { setState(() {});});
                  },
                  child: Icon(Icons.add,),
                ));
          }
          return Center(
            child: CircularProgressIndicator(color:Color(0xFF0F4FA6)),
          );
        });
  }
}

class AddEntryPage extends StatefulWidget {
  const AddEntryPage(
      {super.key, required this.journalList, required this.user, required this.isprompt, required this.prompt});
  final journalList;
  final user;
  final isprompt;
  final prompt;
  @override
  _AddEntryPageState createState() =>
      _AddEntryPageState(journalList: journalList, user: user, isprompt:isprompt, prompt:prompt);
}

class _AddEntryPageState extends State<AddEntryPage> {
  _AddEntryPageState({required this.journalList, required this.user, required this.isprompt, required this.prompt}) : super();
  var isprompt;
  var journalList;
  var prompt;
  var user;
  String title = 'Journal Entry';
  String description = 'No description provided';
  String audioFilePath = '';
  final List<XFile> recordedVideos = [];
  String imageFilePath = '';
  var audioRecord=Record();
  int selectedContainerIndex = 0;
  var dateControl = DateTime.now();
  String type = 'Journal Entry';
  List<String> _recordedAudioPaths = [];
  AudioPlayer _audioPlayer = AudioPlayer();
  File? _pickedImage;
  List<File> _pickedImages = [];
  List<File> _pickedVideos = [];
  var pickedFile;
  bool _isImageGood = false;
   List<VideoPlayerController> _controllers = [];
  String imageName = DateTime.now().toString();
  var listToAdd = [];
  void initState() {
    super.initState();
  }

  


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(height: MediaQuery.of(context).size.height * 0.04),
            Row(children: [
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Container(
                  child: Center(
                      child: Icon(
                          color: Color(0xFF0F4FA6), Icons.arrow_back_rounded)),
                  height: MediaQuery.of(context).size.height * 0.04,
                  width: MediaQuery.of(context).size.width * 0.18,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10), // Curved edges
                  ),
                ),
              ),
              Container(width: MediaQuery.of(context).size.width * 0.14),
              isprompt
                ?Text(
                  "Answer an Prompt",
                  style: GoogleFonts.raleway(
                    fontSize: 13,
                    // Adjust the font size as needed
                    // Adjust the font weight as needed
                    // You can also set other text styles here
                  ),
                )
                :Text(
                  "Write An Entry",
                  style: GoogleFonts.raleway(
                    fontSize: 15,
                    // Adjust the font size as needed
                    // Adjust the font weight as needed
                    // You can also set other text styles here
                  ),
                ),
              
              Container(width: MediaQuery.of(context).size.width * 0.14),
              GestureDetector(
                onTap: () async {
                  if(isprompt){
                    type='Prompt';
                  }
                  Navigator.pop(context);
                  journalList.add({
                    'date': '${imageName}',
                    'title': title,
                    'description': description,
                    'type': "${type}",
                    'Prompt': "${prompt}",
                  });
                  await FirebaseFirestore.instance
                      .collection('audios')
                      .doc('$user')
                      .update({'journal': journalList});
                  setState(() {});
                  _pickedImages.forEach((File image) {
                    uploadImageToFirebase(image);
                  });
                },
                child: Container(
                  child: Center(
                      child: Text("Finish",
                          style: TextStyle(color: Color(0xFF0F4FA6)))),
                  height: MediaQuery.of(context).size.height * 0.04,
                  width: MediaQuery.of(context).size.width * 0.17,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10), // Curved edges
                  ),
                ),
              ),
            ]),
            Container(height: MediaQuery.of(context).size.height * 0.04),
            !isprompt
              ?Text("Type", style:TextStyle(fontWeight:FontWeight.bold, fontSize:17))
              :Text("Question:", style:TextStyle(fontWeight:FontWeight.bold, fontSize:17)),
            Container(height: MediaQuery.of(context).size.height * 0.01),
            !isprompt
              ?Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.1,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 2, // Number of containers
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedContainerIndex = index;
                          if (index == 0) {
                            type = 'Journal Entry';
                          } else {
                            type = "To-do";
                          }
                        });
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.4,
                        height: MediaQuery.of(context).size.height *
                            0.07, // Adjust the width as needed
                        margin: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: selectedContainerIndex == index
                                ? Color(0xFF0F4FA6)
                                : Colors.black,
                            width: selectedContainerIndex == index ? 2.5 : 1.5,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: index == 0
                              ? Text("Journal Entry",
                                  style: TextStyle(color: Colors.black))
                              : Text("To-do",
                                  style: TextStyle(color: Colors.black)),
                        ),
                      ),
                    );
                  },
                ),
              )
              :Container(child:Text("${prompt}")),
            Container(height: MediaQuery.of(context).size.height * 0.02),
            Text("Title", style:TextStyle(fontWeight:FontWeight.bold, fontSize:17)),
            TextField(
              style: TextStyle(fontWeight: FontWeight.bold),
              onChanged: (value) {
                setState(() {
                  title = value;
                });
              },
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Name Your Entry',
              ),
            ),
            Container(height: MediaQuery.of(context).size.height * 0.01),
            !isprompt
              ?Text("Description", style:TextStyle(fontWeight:FontWeight.bold, fontSize:17))
              :Text("Answer", style:TextStyle(fontWeight:FontWeight.bold, fontSize:17)),
            Container(height: MediaQuery.of(context).size.height * 0.01),
            !isprompt
              ?Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height *
                    0.18, // Set the width to expand across the screen
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      description = value;
                    });
                  },
                  maxLines: null, // Set maxLines to null for multiple lines
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Write about your day...',
                  ),
                ),
              )
              :Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height *
                    0.18, // Set the width to expand across the screen
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      description = value;
                    });
                  },
                  maxLines: null, // Set maxLines to null for multiple lines
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Write your answer...',
                  ),
                ),
              ),
            Container(height: MediaQuery.of(context).size.height * 0.02),
            Text("Images:", style:TextStyle(fontWeight:FontWeight.bold, fontSize:17)),
            Container(height: MediaQuery.of(context).size.height * 0.02),
            _pickedImages.isNotEmpty ? Container(
            width:MediaQuery.of(context).size.width * 1,
            height:MediaQuery.of(context).size.height * 0.22,
            child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 4.0,
                        mainAxisSpacing: 4.0,
                      ),
                      itemCount: _pickedImages.length,
                      itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Stack(
                    alignment: Alignment.topRight,
                    children: [
                      Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          image: DecorationImage(
                            image: FileImage(_pickedImages[index]),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color:Colors.red),
                        onPressed: () {
                          setState(() {
                            _pickedImages.removeAt(index);
                          });
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ) : Container(height:MediaQuery.of(context).size.height * 0.22,child:Text("NO IMAGES YET")), 
          // Container(height: MediaQuery.of(context).size.height * 0.00),
          //   _pickedVideos.isNotEmpty ? Container(
          //   width:MediaQuery.of(context).size.width * 1,
          //   height:MediaQuery.of(context).size.height * 0.17,
          //   child: ListView.builder(
          //     scrollDirection: Axis.horizontal,
          //     itemCount: _pickedVideos.length,
          //     itemBuilder: (BuildContext context, int index) {
          //       return Padding(
          //         padding: const EdgeInsets.all(8.0),
          //         child: Stack(
          //           alignment: Alignment.topRight,
          //           children: [
          //             Container(
          //               width: 150,
          //               height: 150,
          //               child:VideoPlayer(_controllers[index]),
          //             ),
          //             IconButton(
          //               icon: Icon(Icons.close, color:Colors.red),
          //               onPressed: () {
          //                 setState(() {
          //                   _pickedVideos.removeAt(index);
          //                 });
          //               },
          //             ),
          //           ],
          //         ),
          //       );
          //     },
          //   ),
          // ) : Container(height:MediaQuery.of(context).size.height * 0.17,child:Text("NO VIDEOS YET")), 
            
          !isprompt
            ?Container(height: MediaQuery.of(context).size.height * 0.02)
            :Container(height: MediaQuery.of(context).size.height * 0.08),
            Align(alignment: Alignment.center,
            child:PopupMenuButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15.0))
                ),
                child: Container(
                  width:MediaQuery.of(context).size.height * 0.07,
                  height:MediaQuery.of(context).size.height * 0.07,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Color(0xFF0F4FA6), // Set the desired border color here
                      width: 2.0, // Set the desired border width here
                    ),
                  ),
                  child: Icon(Icons.add, color:Color(0xFF0F4FA6))
              ),
              onSelected: (value) {
                if (value == "Image") {
                  showOptions(context, "image");
                }else if(value == "photo"){
                  showOptions(context, "photo");
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry>[
                PopupMenuItem(
                  value: "Image",
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Icon(Icons.image),
                      ),
                      const Text(
                        'Select a Image',
                        style: TextStyle(fontSize: 15),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: "photo",
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Icon(Icons.camera_alt)
                      ),
                      const Text(
                        'Take a Photo',
                        style: TextStyle(fontSize: 15),
                      ),
                    ],
                  ),
                ),
                
              ],
            )
            ),
            
          ],
        ),
      ),
    ));
  }
  // void showVideoOptions(BuildContext context) async {
  //   final pickedVideo = await showDialog<File>(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text("Take a Video"),
  //         content: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             ElevatedButton(
  //               style:ElevatedButton.styleFrom(backgroundColor: Color(0xFF0F4FA6)),
  //               onPressed: () async {
  //                 pickedFile = await ImagePicker().pickVideo(source: ImageSource.camera);
  //                 print("PICKED FILE:${pickedFile}");
  //                 if (pickedFile != null) {
  //                   setState(() {
  //                     print("${pickedFile.path}");
  //                     _pickedVideos.add(File(pickedFile.path));
  //                     _isImageGood = true;
  //                     _controller=VideoPlayerController.file(File(pickedFile.path))..initialize().then((_){setState(){_controller.play();}});
  //                     _controllers.add();
  //                     print("PICKED VIDS:${_pickedVideos}");
  //                   });
  //                 }
  //               },
                
  //               child: Text("Take a Video"),
  //             ),
  //             ElevatedButton(
  //               style:ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 82, 5, 0)),
  //               onPressed: () {
  //                 if (true==true) {
  //                   Navigator.pop(context, _pickedImage);
  //                 } else {
  //                   showDialog(
  //                     context: context,
  //                     builder: (context) {
  //                       return AlertDialog(
  //                         title: Text('Please take a video first'),
  //                         actions: [
  //                           TextButton(
  //                             onPressed: () => Navigator.pop(context),
  //                             child: Text('OK'),
  //                           ),
  //                         ],
  //                       );
  //                     },
  //                   );
  //                 }
  //               },
  //               child: Text('Cancel'),
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //   );

  //   if (pickedVideo != null) {
  //     // Upload the image to Firebase Storage
      
  //   }
  // }


  void showOptions(BuildContext context, type) async {
    final pickedImage = await showDialog<File>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: type=="photo"
                ? Text('Take a photo')
                : Text("Select a image"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                style:ElevatedButton.styleFrom(backgroundColor: Color(0xFF0F4FA6)),
                onPressed: () async {
                  if(type=="photo"){
                    pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
                  }else{
                    pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
                  }
                  
                  if (pickedFile != null) {
                    setState(() {
                      _pickedImages.add(File(pickedFile.path));
                      _isImageGood = true;
                    });
                  }
                },
                
                child: type=="photo"
                  ? Text('Take a photo')
                  : Text("Choose an image"),
              ),
              ElevatedButton(
                style:ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 82, 5, 0)),
                onPressed: () {
                  if (true==true) {
                    Navigator.pop(context, _pickedImage);
                  } else {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text('Please take a photo first'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
                child: Text('Cancel'),
              ),
            ],
          ),
        );
      },
    );

    if (pickedImage != null) {
      // Upload the image to Firebase Storage
      
    }
  }

  Future<void> uploadImageToFirebase(File imageFile) async {
    try {
      FirebaseStorage storage = FirebaseStorage.instance;
      Reference ref = storage.ref().child('${user}/images/$imageName/${path.basename(imageFile.path)}');
      UploadTask uploadTask = ref.putFile(imageFile);
    } catch (e) {
      print('Error uploading image: $e');
      // Handle error accordingly
    }
  }
  Future<void> uploadVideoeToFirebase(File imageFile) async {
    try {
      FirebaseStorage storage = FirebaseStorage.instance;
      Reference ref = storage.ref().child('${user}/videos/$imageName/${path.basename(imageFile.path)}');
      UploadTask uploadTask = ref.putFile(imageFile);
      await uploadTask.whenComplete(() => print('Image uploaded to Firebase'));
    } catch (e) {
      print('Error uploading image: $e');
      // Handle error accordingly
    }
  }
}

class JournalEntry {
  final String title;
  final String description;
  final String audioFilePath;
  final String imageFilePath;

  JournalEntry({
    required this.title,
    required this.description,
    this.audioFilePath = '',
    this.imageFilePath = '',
  });
}


class ViewEntryPage extends StatefulWidget {
  const ViewEntryPage({super.key, required this.journalList, required this.user, required this.totalJournals});
  final journalList;
  final totalJournals;
  final user;
  @override
  _ViewEntryPageState createState() =>
      _ViewEntryPageState(journalList: journalList, user:user, totalJournals:totalJournals);
}

class _ViewEntryPageState extends State<ViewEntryPage> {
  _ViewEntryPageState({required this.journalList, required this.user, required this.totalJournals}) : super();
  var totalJournals;
  var journalList;
  var user;
  String? _selectedImageUrl;
  List<String> _imageUrls = [];
  bool _isLoading = true;
  void initState() {
    super.initState();
    // Fetch image URLs from Firebase Storage
    fetchImageUrls();
  }

  Future<void> fetchImageUrls() async {
    try {
      // Replace 'images' with your Firebase Storage directory
       final ListResult result =
        await FirebaseStorage.instance.ref('${user}/images/${journalList['date']}').listAll();

      List<String> urls = [];

      for (Reference ref in result.items) {
        // Get download URL for each image
        String url = await ref.getDownloadURL();
        urls.add(url);
      }

      setState(() {
        _imageUrls = urls;
        _isLoading = false;
      });
    } catch (error) {
      print('Error fetching image URLs: $error');
      setState(() {
        _isLoading = false;
      });
    }
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
            child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(height: MediaQuery.of(context).size.height * 0.04),
        Row(children: [
          GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Container(
              child: Center(
                  child:
                      Icon(color: Color(0xFF0F4FA6), Icons.arrow_back_rounded)),
              height: MediaQuery.of(context).size.height * 0.04,
              width: MediaQuery.of(context).size.width * 0.12,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10), // Curved edges
              ),
            ),
          ),
          Container(width: MediaQuery.of(context).size.width * 0.03),
          Text(
            "${journalList['title']}".length > 14
                  ? "${journalList['title']}".substring(0, 14) +
                      "..." // Truncate text if it exceeds the character limit
                  : "${journalList['title']}",
            style: GoogleFonts.raleway(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              // Adjust the font size as needed
              // Adjust the font weight as needed
              // You can also set other text styles here
            ),
          ),
          Spacer(),
          Text(
            "${DateFormat('MM/dd/yyyy').format(DateTime.parse(journalList['date']))}",
            style: GoogleFonts.raleway(
              fontSize: 15,
              // Adjust the font size as needed
              // Adjust the font weight as needed
              // You can also set other text styles here
            ),
          )
        ]),
        Container(height: MediaQuery.of(context).size.height * 0.04),
        journalList["type"]=='Prompt'
          ?Column(children:[Row(children:[Container(width:MediaQuery.of(context).size.width*0.3,child:Text("${journalList['type']}", style:TextStyle(fontSize:20, fontWeight:FontWeight.bold))), Container(width:MediaQuery.of(context).size.width*0.6)]),Container(height:MediaQuery.of(context).size.height*0.02,), Text("${journalList['Prompt']}", style:TextStyle(fontSize:17))])
          :Text("${journalList['type']}", style:TextStyle(fontSize:17)),
        
        Container(height: MediaQuery.of(context).size.height * 0.02),
        journalList["type"]!='Prompt'
          ?Text("Description", style: TextStyle(fontWeight: FontWeight.bold, fontSize:20))
          :Text("Your Answer", style: TextStyle(fontWeight: FontWeight.bold, fontSize:20)),
        Container(height: MediaQuery.of(context).size.height * 0.02),
        Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height *
              0.26, // Set the width to expand across the screen
          child: SingleChildScrollView(child:Text("${journalList['description']}",style:TextStyle(fontSize:17))),
        ),
        Text("Images:", style: TextStyle(fontWeight: FontWeight.bold, fontSize:20)),
        _isLoading
          ? Center(
              child: CircularProgressIndicator(color:Color(0xFF0F4FA6)),
            )
          : _imageUrls.isEmpty
              ? Container(height:MediaQuery.of(context).size.height*0.2,child:Center(
                  child: Text('No images found'),
                ))
              : Stack(
                  children: [
                    Container(
                    height:MediaQuery.of(context).size.height*0.2,
                    child:GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 4.0,
                        mainAxisSpacing: 4.0,
                      ),
                      itemCount: _imageUrls.length,
                      itemBuilder: (BuildContext context, int index) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedImageUrl = _imageUrls[index];
                            });
                          },
                          child: Image.network(
                            height:MediaQuery.of(context).size.height*0.1,
                            width:MediaQuery.of(context).size.height*0.15,
                            _imageUrls[index],
                            fit: BoxFit.cover,
                          ),
                        );
                      },
                    )),
                    if (_selectedImageUrl != null)
                      Container(
                        color: Colors.black.withOpacity(0.5),
                        child: Center(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedImageUrl = null;
                              });
                            },
                            child: Image.network(
                              _selectedImageUrl!,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
      journalList["type"]!='Prompt'
      ?Container(height:MediaQuery.of(context).size.height*0.18)
      :Container(height:MediaQuery.of(context).size.height*0.14),
       Align(alignment:Alignment.bottomRight, child:Row(children:[Container(width:MediaQuery.of(context).size.width*0.74),FloatingActionButton(
      onPressed:(){},
      backgroundColor: Colors.transparent,
      elevation: 0,
      child:Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.red, width: 2.0),
        ),
        child: IconButton(
          icon: Icon(Icons.delete, color: Colors.red),
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text("Confirm Delete"),
                  content: Text("Are you sure you want to delete?"),
                  actions: [
                    TextButton(
                      onPressed: () {
                        // Close the dialog
                        Navigator.pop(context);
                      },
                      child: Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MyHomePage(widgets: [
                          HomePage(user: user),
                          ChallengeScreen(user: user),
                          Planner(user: user),
                          // Planner(user: "$email"),
                          JournalPage(user: user),
                          // PostPage(currentUser: "$email"),    // ProfilePage(user:"$email"),
                        ], selectedIndex:3),
                        ));
                        totalJournals.remove(journalList);
                        await FirebaseFirestore.instance.collection('audios')
                                                            .doc(user)
                                                            .update({
                                                          'journal':
                                                              totalJournals
                                                        });
                        // Close the dialog
                      setState((){});
                      // ).then((value) {
                      //   // Handle the popped data here
                      //   setState(() {
                      //     // Update the state or perform any necessary actions
                      //   });
                      // });
                
                        // Call the delete function
                      },
                      child: Text("Delete"),
                    ),
                  ],
                );
              }, // Add your delete functionality here
            );
          }
      ),
    ),)]),

            )]),
    )));
  }
}
class FeedbackPage extends StatefulWidget {
  final String user;

  const FeedbackPage({Key? key, required this.user}) : super(key: key);

  @override
  _FeedbackPageState createState() => _FeedbackPageState(user:user);
}

class _FeedbackPageState extends State<FeedbackPage> {
  _FeedbackPageState({required this.user}) : super();
  String _feedback = '';
  var response;
  var user;

  void _submitFeedback(user) async {
  if (_feedback.isNotEmpty) {
    // Get the current timestamp
    Timestamp timestamp = Timestamp.now();
    
    // Reference to the feedback document
    DocumentReference feedbackDoc = FirebaseFirestore.instance.collection('Recommendations').doc('List');
    feedbackDoc.set(
      {'${timestamp}':{
      "text":_feedback,
      "user":"${user}",
      "emotion":"${response}",
      }},
      SetOptions(merge: true))
    ;

    // Show a confirmation dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Feedback Submitted'),
          content: Text('Thank you for your feedback!'),
          actions: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                    backgroundColor:Color(0xFF0F4FA6),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );

    // Clear the feedback text field
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(child:Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(height:MediaQuery.of(context).size.height*0.05),
            Row(children:[ Container(width:MediaQuery.of(context).size.width*0.02,),GestureDetector(child:Icon(Icons.arrow_back_rounded), onTap:(){Navigator.pop(context);}), Container(width:MediaQuery.of(context).size.width*0.02,), Text("Feedback")]),
            Container(height:MediaQuery.of(context).size.height*0.04),
            Row(children:[Container(width:MediaQuery.of(context).size.width*0.03,), Text("Rate Your Experience", style:TextStyle(fontWeight:FontWeight.bold, fontSize:17),)]),
            Container(height:MediaQuery.of(context).size.height*0.025),

            Row(children:[
              Container(width:MediaQuery.of(context).size.width*0.025),
              Container( 
              width:MediaQuery.of(context).size.width*0.95,
              child:
                EmojiFeedback(
                animDuration: const Duration(milliseconds: 300),
                curve: Curves.bounceIn,
                inactiveElementScale: .5,
                onChanged: (value) {
                  response=value;
                },
              ),
            ),]),
            Container(height:MediaQuery.of(context).size.height*0.05),
            Row(children:[Container(width:MediaQuery.of(context).size.width*0.02,), Text("Write Your Comment", style:TextStyle(fontWeight:FontWeight.bold, fontSize:17),)]),
            Container(height:MediaQuery.of(context).size.height*0.03),
            Row(children: [
              Container(width:MediaQuery.of(context).size.width*0.05),
              Container(
                width:MediaQuery.of(context).size.width*0.9,
                child:TextField(
                onChanged: (value) {
                  setState(() {
                    _feedback = value;
                  });
                },
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Enter your feedback here',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              )),
              Container(width:MediaQuery.of(context).size.width*0.05),
            ],), 
            Container(height:MediaQuery.of(context).size.height*0.05),
            Row(children:[
              Container(
                width:MediaQuery.of(context).size.width*0.05,),
              Container(
                width:MediaQuery.of(context).size.width*0.9,
                height:MediaQuery.of(context).size.height*0.06,
                child:ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:Color(0xFF0F4FA6),// Match the container background color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          12.0), // Adjust the button border radius
                    ),
                  ),
              onPressed: _feedback.isEmpty ? null : (){_submitFeedback(user);},
              child: Text('Submit Feedback'),
            ),)]),
          ],
        ),
      ),
      ),
    );
  }
}


class ChallengeCard extends StatelessWidget {
  final Color color;
  final String title;
  final String data;
  final onpress;

  const ChallengeCard({
    required this.color,
    required this.title,
    required this.data,
    required this.onpress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.3,
      width: MediaQuery.of(context).size.width * 0.44,
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.0),
              Text('Challenge: $data'),
              SizedBox(height: 8.0),
            ],
          ),
          Positioned(
            bottom: MediaQuery.of(context).size.width*0.00,
            right: MediaQuery.of(context).size.width*0.00,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color.fromARGB(255, 147, 127, 239),
                    spreadRadius: 2.0,
                  ),
                ],
              ),
              child: IconButton(
                icon: Icon(Icons.play_arrow),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => onpress),
                  );// S
                },
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
class RelaxationPage extends StatefulWidget {
  @override
  RelaxationPage({required this.level, required this.data}); 
  final level;// Constructor with the parameter
  final data;
  _RelaxationPageState createState() => _RelaxationPageState(level:level, data:data);
}


class _RelaxationPageState extends State<RelaxationPage> {
  _RelaxationPageState({required this.level, required this.data}) : super();
  final level;
  final data;
  AudioPlayer audioPlayer = AudioPlayer();
  int audioDurationInSeconds = 10000000000000;
  late Timer _timer;
  var x=0;

  @override
  void initState() {
    super.initState();
    playAudio();
    startTimer();
    if(x==1){
      audioPlayer.dispose();
      _timer.cancel();
    }
  }
  @override
  void dispose() {
    audioPlayer.dispose();
    _timer.cancel();
    x=1;
    Future.delayed(Duration(milliseconds: 4000), (){
      audioPlayer.dispose();
      _timer.cancel();
    });
    super.dispose();
  }

  Future<void> playAudio() async {
    // Load the audio file from assets
    // final ByteData data = await rootBundle.load('https://firebasestorage.googleapis.com/v0/b/healthcare-393311.appspot.com/o/audios%2Fdeep-meditation-192828.mp3?alt=media&token=8132aaf7-373a-4e87-bac2-b1feb04a0a93');
    // final buffer = data.buffer.asUint8List();
    
    // Play the audio from the loaded buffer
    await audioPlayer.play(
      'https://firebasestorage.googleapis.com/v0/b/healthcare-393311.appspot.com/o/audios%2Fdeep-meditation-192828.mp3?alt=media&token=8132aaf7-373a-4e87-bac2-b1feb04a0a93', isLocal:false,
    );
    audioPlayer.onDurationChanged.listen((Duration duration) {
      setState(() {
        if(level=='medium'){
          audioDurationInSeconds=480;
        }else if(level=='easy'){
          audioDurationInSeconds=240;
        }else{
          audioDurationInSeconds = duration.inSeconds;
        }

      });
      print('Audio Duration: $audioDurationInSeconds seconds');
    });
    // Future.delayed(Duration(seconds: 5), () async {
    //   // Code to execute after a 2-second delay
    //   var audioDuration = await audioPlayer.getDuration();
    //   if (audioDuration != null) {
    //     setState(() {
    //       audioDurationInSeconds = audioDuration;
    //       audioDurationInSeconds=(audioDurationInSeconds/1000).ceil();
    //     });
    //     print('Audio Duration: $audioDurationInSeconds seconds');
    //   }
    // });
  }
   void startTimer() {
    const oneSecond = Duration(seconds: 1);
    _timer = Timer.periodic(oneSecond, (timer) {
      setState(() {
        if (audioDurationInSeconds > 0) {
          if(audioDurationInSeconds!=10000000000000){
            audioDurationInSeconds--;
          }
        } else {
          _timer.cancel(); 
          audioPlayer.dispose();
          
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CongratulationsPage(message:"Great Job with your meditating exercise!", data:data)),
            );// Stop the timer when countdown reaches zero
        }
      });
    });
  }
  String getFormattedTime(int seconds) {
  int minutes = seconds ~/ 60;
  int remainingSeconds = seconds % 60;
  String formattedMinutes = minutes.toString().padLeft(2, '0');
  String formattedSeconds = remainingSeconds.toString().padLeft(2, '0');
  return '$formattedMinutes:$formattedSeconds';
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        child: Column(
          children: [
            Container(height: MediaQuery.of(context).size.height * 0.06),
            Row(children: [
              IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white, size:MediaQuery.of(context).size.height * 0.04),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
              ),
              Container(width: MediaQuery.of(context).size.width * 0.8)
            ]),
            Container(height: MediaQuery.of(context).size.width * 0.12),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height * 0.2,
                    child: AnimatedTextKit(
                      animatedTexts: [
                        TypewriterAnimatedText(
                          'Relax your body...\nFocus on breathing...\nSlowly close your eyes...',
                          textAlign: TextAlign.center,
                          textStyle: const TextStyle(
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          speed: const Duration(milliseconds: 200),
                        ),
                      ],
                      totalRepeatCount: 1,
                      pause: const Duration(milliseconds: 200),
                    ),
                  ),
                  Image.asset(
                    'assets/images/pulsating_gif.gif',
                    scale: 0.5,
                  ),
                  Container(height:MediaQuery.of(context).size.height*0.03),
                  audioDurationInSeconds==10000000000000
                    ?Text("Loading...", style:TextStyle(color:Colors.white, fontSize: 24, fontWeight: FontWeight.bold))
                    :Text(
                      '${getFormattedTime(audioDurationInSeconds)}',
                      style: TextStyle(fontSize: 40, color:Colors.white,fontWeight:FontWeight.w400),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CongratulationsPage extends StatefulWidget {
  @override
  CongratulationsPage({required this.message, required this.data}); 
  final message;// Constructor with the parameter
  final data;
  _CongratulationsPageState createState() => _CongratulationsPageState(message:message, data:data);
}




class _CongratulationsPageState extends State<CongratulationsPage> {
  final String message; // Field to hold the message
  final data;


  _CongratulationsPageState({required this.message, required this.data,}):super(); // Constructor with message parameter
  var label;
  var sentence;
  var newdata;
  var done;
  void initState() {
     super.initState();
      String formattedDate = DateFormat('MMMM d, y').format(DateTime.now());
      if(message=="Great Job with your breathing exercise!"){
        label="breathe";
        sentence="completed a breathing routine on ${formattedDate}";
      }else if(message=="Great Job with your drawing! Make sure to try again for new prompts/ideas."){
        label="draw";
        sentence="completed a drawing practice on ${formattedDate}";
      }else if(message=="Great Job with your meditating exercise!"){
        label="meditate";
        sentence="completed a meditating session on ${formattedDate}";
      }else{
        label="memory";
        sentence="completed a memory exercise on ${formattedDate}";
      }
      print("HIII ${data[1]}");
      newdata={label:sentence};
      print(newdata);
      List finished=data[1];
      finished.insert(0, newdata);
      done=finished;
      print(done);
      print(finished);

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 1, 8, 84), // Background color
      body: Column(
        children: [
          Container(height: MediaQuery.of(context).size.height * 0.05),
          Image.asset('assets/images/award-gif-unscreen.gif'),
          Container(height: MediaQuery.of(context).size.height * 0.05),
          Text("Congratulations!", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 40)),
          Container(height: MediaQuery.of(context).size.height * 0.03),
          Container(
            width: MediaQuery.of(context).size.width * 0.8,
            child: Text(
              message, // Display the message passed from outside
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 17),
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.height * 0.07,
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.6,
            height: MediaQuery.of(context).size.height * 0.06,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.0),
                ),
                backgroundColor: Color.fromARGB(255, 111, 228, 243), // Button color
              ),
              onPressed: () async {
                Navigator.pop(context);
                Navigator.pop(context);
                Navigator.pop(context);
                await FirebaseFirestore.instance.collection('audios').doc('${data[0]}').update({'activity': done});
                setState(){};
              },
              child: Text('Continue', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
            ),
          ),
        ],
      ),
    );
  }
}



class SudokuScreen extends StatefulWidget {
 @override
 _SudokuScreenState createState() => _SudokuScreenState();
}
class _SudokuScreenState extends State<SudokuScreen> {
 List<List<int>> _puzzle = [];
 List<List<int>> _solution = [];
 int _selectedRow = -1;
 int _selectedCol = -1;
 bool _isComplete = false;
@override
 void initState() {
 super.initState();
 _generatePuzzle();
 }
void _generatePuzzle() {
 // Generate a new Sudoku puzzle using an existing library or algorithm
 // For simplicity, we'll just generate a random puzzle here
 var rng = Random();
 _solution = List.generate(9, (_) => List.generate(9, (_) => rng.nextInt(9) + 1));
 _puzzle = List.generate(9, (_) => List.generate(9, (_) => 0));
 for (int i = 0; i < 9; i++) {
 for (int j = 0; j < 9; j++) {
 if (rng.nextDouble() < 0.5) {
 _puzzle[i][j] = _solution[i][j];
 }
 }
 }
 }
void _checkComplete() {
 // Check if the puzzle is complete
 _isComplete = true;
  for (int i = 0; i < 9; i++) {
    for (int j = 0; j < 9; j++) {
      if (_puzzle[i][j] == 0) {
        _isComplete = false;
      return;
      }
      if (_puzzle[i][j] != _solution[i][j]) {
        _isComplete = false;
      }
    }
  }
 }
void _selectCell(int row, int col) {
 setState(() {
 _selectedRow = row;
 _selectedCol = col;
 });
 }
void _enterNumber(int number) {
 if (_selectedRow != -1 && _selectedCol != -1) {
 setState(() {
 _puzzle[_selectedRow][_selectedCol] = number;
 _checkComplete();
 });
 }
 }
@override
 Widget build(BuildContext context) {
 return Scaffold(
 appBar: AppBar(
 title: Text('Sudoku'),
 ),
 body: Column(
 children: <Widget>[
 Expanded(
 child: GridView.count(
 crossAxisCount: 9,
 children: List.generate(81, (index) {
 int row = index ~/ 9;
 int col = index % 9;
 return GestureDetector(
 onTap: () {
 _selectCell(row, col);
 },
 child: Container(
 alignment: Alignment.center,
 decoration: BoxDecoration(
 border: Border.all(
 color: Colors.grey,
 ),
 color: _selectedRow == row && _selectedCol == col
 ? Colors.yellow
 : Colors.white,
 ),
 child: Text(
 _puzzle[row][col] == 0 ? '' : _puzzle[row][col].toString(),
 style: TextStyle(
 fontSize: 24,
 fontWeight: FontWeight.bold,
 color: _puzzle[row][col] == _solution[row][col]
 ? Colors.green
 : Colors.black,
 ),
 ),
 ),
 );
 }),
 ),
 ),
 SizedBox(height: 16),
 _isComplete
 ? Text(
 'Congratulations! You solved the puzzle!',
 style: TextStyle(
 fontSize: 20,
 fontWeight: FontWeight.bold,
 color: Colors.green,
 ),
 )
 : SizedBox(),
 SizedBox(height: 16),
 Column(children:[
  Row()
 ]),
 Row(
 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
 children: <Widget>[
 _buildNumberButton(1),
 _buildNumberButton(2),
 _buildNumberButton(3),
 _buildNumberButton(4),
 _buildNumberButton(5),
 _buildNumberButton(6),
 _buildNumberButton(7),
 _buildNumberButton(8),
 _buildNumberButton(9),
 ],
 ),
 SizedBox(height: 16),
 ElevatedButton(
 child: Text('New Game'),
 onPressed: () {
 setState(() {
 _generatePuzzle();
 _selectedRow = -1;
 _selectedCol = -1;
 _isComplete = false;
 });
 },
 ),
 SizedBox(height: 16),
],
 ),
 );
 }
Widget _buildNumberButton(int number) {
 return ElevatedButton(
 child: Text(number.toString()),
 onPressed: () {
 _enterNumber(number);
 },
 );
 }
}



class MemoryGameScreen extends StatefulWidget {
  @override// Define the parameter

  MemoryGameScreen({required this.level, required this.data}); // Constructor with the parameter
  final level; 
  final data;

  @override
  _MemoryGameScreenState createState() => _MemoryGameScreenState(level:level, data:data);
}

class _MemoryGameScreenState extends State<MemoryGameScreen> {

  _MemoryGameScreenState({required this.level, required this.data}) : super();
  final level;
  final data;
  List<int> numbers = [];
  List<int> visibleNumbers = [];
  bool canTap = true;
  int attempts = 0;
  int firstIndex = -1;
  var grids;

  @override
  void initState() {
    super.initState();
    initializeGame();
  }

  returnIcon(size, index){
    final Map<int, Icon> memoryGameIcons = {
      1: Icon(Icons.ac_unit,size:size, color:Colors.white),
      2: Icon(Icons.access_alarm,size:size, color:Colors.white),
      3: Icon(Icons.music_note,size:size, color:Colors.white),
      4: Icon(Icons.camera_alt,size:size, color:Colors.white),
      5: Icon(Icons.coffee,size:size, color:Colors.white),
      6: Icon(Icons.account_circle,size:size, color:Colors.white),
      7: Icon(Icons.home,size:size, color:Colors.white),
      8: Icon(Icons.book,size:size, color:Colors.white),
      9: Icon(Icons.add_box,size:size, color:Colors.white),
      10: Icon(Icons.shopping_bag,size:size, color:Colors.white),
      11: Icon(Icons.bed, size:size, color:Colors.white),
      12: Icon(Icons.phone, size:size, color:Colors.white),
      13: Icon(Icons.key, size:size, color:Colors.white),
      14: Icon(Icons.fire_truck, size:size, color:Colors.white),
      15: Icon(Icons.umbrella, size:size, color:Colors.white), 
    };
    return(memoryGameIcons[numbers[index]]);

  }

  void initializeGame() {
    if(level=="difficult"){
      grids=30;
    }else if(level=="medium"){
      grids=20;
    }else{
      grids=10;
    }
    numbers = List.generate(grids, (index) => index ~/ 2 + 1);
    numbers.shuffle();
    visibleNumbers = List.filled(numbers.length, 0);
    canTap = true;
    attempts = 0;
    firstIndex = -1;
  }

  void handleTap(int index) {
    if (!canTap || visibleNumbers[index] != 0) return;

    setState(() {
      visibleNumbers[index] = 1;
    });

    if (firstIndex == -1) {
      firstIndex = index;
    } else {
      canTap = false;
      Timer(Duration(seconds: 1), () {
        setState(() {
          checkMatch(index);
        });
      });
    }
  }

  void checkMatch(int secondIndex) {
    if (numbers[firstIndex] == numbers[secondIndex]) {
      visibleNumbers[firstIndex] = 2;
      visibleNumbers[secondIndex] = 2;
    } else {
      visibleNumbers[firstIndex] = 0;
      visibleNumbers[secondIndex] = 0;
    }

    firstIndex = -1;
    canTap = true;
    attempts++;
    checkGameEnd();
  }

  void checkGameEnd() {
    if (visibleNumbers.every((element) => element == 2)) {
       Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CongratulationsPage(message:"Great Job finishing the memory game!\n You took $attempts turns to solve it. ", data:data)),
            );
      // showDialog(
      //   context: context,
      //   builder: (BuildContext context) {
      //     return AlertDialog(
      //       title: Text('Game Over'),
      //       content: Text('You completed the game in $attempts attempts!'),
      //       actions: [
      //         TextButton(
      //           onPressed: () {
      //             Navigator.of(context).pop();
      //             initializeGame();
      //           },
      //           child: Text('Play Again'),
      //         ),
      //       ],
      //     );
      //   },
      // );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children:[
          Container(height:MediaQuery.of(context).size.height*0.05),
           Row(
        children: [
          Container(width:MediaQuery.of(context).size.width*0.01),
          // Icon(Icons.account_circle,
          //     color: Color(0xFF0F4FA6), size: MediaQuery.of(context).size.height*0.06), // Profile Icon
          IconButton(icon:Icon(Icons.arrow_back, color: Color(0xFF0F4FA6), size: MediaQuery.of(context).size.height*0.045),onPressed:(){Navigator.pop(context);Navigator.pop(context);}),
        ]),
          Container(height:MediaQuery.of(context).size.height*0.03),
          Text("Memory  Game!", textAlign: TextAlign.center,style:TextStyle(fontSize: 30,letterSpacing:3.00, fontWeight:FontWeight.w500, color:Color.fromARGB(255, 99, 70, 203))),
          Container(height:MediaQuery.of(context).size.height*0.02),
          Text("Play a memory game by flipping two cards per turn to find matching pairs of icons. Remember the positions of previously flipped cards to match pairs efficiently and clear the board.", textAlign:TextAlign.center,  style:GoogleFonts.raleway(
                color: Colors.black, fontSize:14),
          ),
          Container(height:MediaQuery.of(context).size.height*0.02),
          Container(height:MediaQuery.of(context).size.height*0.64,width:MediaQuery.of(context).size.width*0.9,child:GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            mainAxisSpacing: 8.0,
            crossAxisSpacing: 8.0,
          ),
          itemCount: numbers.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () => handleTap(index),
              child: Container(
                // width:MediaQuery.of(context).size.width*0.1,
                // height:MediaQuery.of(context).size.width*0.1,
                decoration: BoxDecoration(
                  color: visibleNumbers[index] == 2 ? Colors.green : Colors.lightBlue,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Center(
                  child: visibleNumbers[index] == 0
                      ? Text(
                          'Tap to reveal',
                          textAlign:TextAlign.center,
                          style: TextStyle(fontSize: 16.0),
                        )
                      : returnIcon(MediaQuery.of(context).size.width*0.08, index)
                      // : Text(
                      //     numbers[index].toString(),
                      //     style: TextStyle(fontSize: 24.0),
                      //   ),
                ),
              ),
            );
          },
        )),]
      ),
    );
  }
}

class GifPage extends StatefulWidget {
  @override
   final level;
   final data; // Define the parameter

  GifPage({required this.level, required this.data});
  _GifPageState createState() => _GifPageState(level:level, data:data);
}

class _GifPageState extends State<GifPage> with SingleTickerProviderStateMixin {
   _GifPageState({required this.level, required this.data}) : super();
  final level;
  final data;
  late Timer _timer;
  int _secondsRemaining = 600; // 10 minutes in seconds
  bool _timerFinished = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    if(level=='difficult'){
      _secondsRemaining=600;
    }else if(level=='medium'){
      _secondsRemaining=300;
    }else{
      _secondsRemaining=120;
    }
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        _timer.cancel();
        setState(() {
          _timerFinished = true;
        });
         Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CongratulationsPage(message:"Great Job with your breathing exercise!", data:data)),
            );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Widget _buildTimerContainer() {
  int minutes = _secondsRemaining ~/ 60;
  int seconds = _secondsRemaining % 60;
  String timerText = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

  return Container(
    width:MediaQuery.of(context).size.width*0.176,
    padding: EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      timerText,
      style: TextStyle(fontSize: MediaQuery.of(context).size.width*0.045),
    ),
  );
}

  Widget _buildTimerFinishedContainer() {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        'Finished',
        style: TextStyle(fontSize: 16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFffac94),
      body: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.045),
          Row(
            children: [
              SizedBox(width: MediaQuery.of(context).size.width * 0.01),
              IconButton(
                icon: Icon(Icons.arrow_back,
                    color: Colors.white,
                    size: MediaQuery.of(context).size.height * 0.045),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
              ),
              Container(width:MediaQuery.of(context).size.width*0.66), // Add some space between back arrow and timer
              _timerFinished
                  ? _buildTimerFinishedContainer()
                  : _buildTimerContainer(),
            ],
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.04),
          Text("Breathing Quest",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: MediaQuery.of(context).size.width*0.11,
                  fontWeight: FontWeight.bold)),
          SizedBox(height: MediaQuery.of(context).size.height * 0.1),
          Image.asset('assets/images/XbH6gP4.gif', scale: 0.5),
        ],
      ),
    );
  }
}

class DrawPage extends StatelessWidget {
  final level;
  final data;

  DrawPage({required this.level, required this.data});
  @override
  List<String> selfCareTopics = [
    "taking a walk in nature",
    "reading a favorite book",
    "drinking a cup of tea",
    "listening to calming music",
    "doing yoga exercises",
    "watching a beautiful sunset",
    "journaling your thoughts",
    "taking a relaxing bath",
    "having a spa day at home",
    "cooking a favorite meal",
    "connecting with friends",
    "doing a workout session",
    "growing plants or gardening",
    "trying a new recipe",
    "setting personal boundaries",
    "learning a new skill",
    "exploring creativity",
    "doing a diy project",
    "practicing mindfulness",
    "trying meditation",
    "learning to manage stress",
    "practicing self-compassion",
    "taking a mental health break",
    "creating a self-care routine",
    "reflecting on your goals",
    "having a gratitude practice",
    "taking time for hobbies",
    "practicing self-reflection",
    "doing a digital detox",
    "exploring mindful activities",
    "trying relaxation techniques",
    "setting aside relaxation time",
    "a sport that you like ",
    "having a gratitude journal",
    "trying laughter therapy",
    "exploring coloring activities",
    "trying guided imagery",
    "creating a self-care playlist",
    "taking time for self-care rituals",
  ];
  List<String> hardToDraw = [
  "listening to calming music",
  "watching a beautiful sunset",
  "creating a self-care routine",
  "trying laughter therapy",
];
List<String> notTooHardToDraw = [
  "taking a walk in nature",
  "reading a favorite book",
  "drinking a cup of tea",
  "journaling your thoughts",
  "taking a relaxing bath",
  "having a spa day at home",
  "cooking a favorite meal",
  "trying a new recipe",
  "setting personal boundaries",
  "exploring creativity",
  "trying relaxation techniques",
  "setting aside relaxation time",
  "trying guided imagery",
];
List<String> easyToDraw = [
  "doing yoga exercises",
  "watching a beautiful sunset",
  "connecting with friends",
  "doing a workout session",
  "growing plants or gardening",
  "learning a new skill",
  "practicing mindfulness",
  "trying meditation",
  "learning to manage stress",
  "practicing self-compassion",
  "taking a mental health break",
  "reflecting on your goals",
  "having a gratitude practice",
  "taking time for hobbies",
  "practicing self-reflection",
  "doing a digital detox",
  "exploring mindful activities",
  "setting personal boundaries",
  "trying guided imagery",
  "creating a self-care playlist",
  "taking time for self-care rituals",
  "a sport that you like",
  "having a gratitude journal",
];



  randomtopic(){
    if(level=='difficult'){
      hardToDraw.shuffle();
      return(hardToDraw[0]);
    }else if(level=='medium'){
      notTooHardToDraw.shuffle();
      return(notTooHardToDraw[0]);
    }else{
      easyToDraw.shuffle();
      return(easyToDraw[0]);
    }
    }

  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(child:SingleChildScrollView(child:Column(children:[
        Container(height:MediaQuery.of(context).size.height*0.04,),
        Row(
            children: [
              SizedBox(width: MediaQuery.of(context).size.width * 0.01),
              IconButton(
                icon: Icon(Icons.arrow_back,
                    color: Colors.black,
                    size: MediaQuery.of(context).size.height * 0.035),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
              ),
              Container(width:MediaQuery.of(context).size.width*0.66), // Add some space between back arrow and timer
              TextButton(
                onPressed: () {
                  // Add your finish button functionality here
                  Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CongratulationsPage(message:"Great Job with your drawing! Make sure to try again for new prompts/ideas.", data:data), fullscreenDialog: true),
                );//
                },
                child: Text(
                  'Finish',
                  style: TextStyle(fontSize: 17, color:Color(0xFF0F4FA6)),
                ),
              ),

            ]
        ),
        Container(height:MediaQuery.of(context).size.height*0.04,),
        Container(width:MediaQuery.of(context).size.width*0.95,child:
        Text("Draw something about ${randomtopic()}",
        textAlign:TextAlign.center,
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),),
        Container(height:MediaQuery.of(context).size.height*0.05,),
        Container(
          width:MediaQuery.of(context).size.width*1,
          height:MediaQuery.of(context).size.height*0.75,
          child:DrawingBoard(
      boardConstrained : true,
  background: Container(width:MediaQuery.of(context).size.width*1, height:MediaQuery.of(context).size.height*1, color: Colors.white),
  showDefaultActions: true, /// Enable default action options
  showDefaultTools: true,   /// Enable default toolbar
),)])),),
    );
  }
}

class DifficultySelectionPage extends StatefulWidget {
  @override
  @override
   final page; // Define the parameter
   final data;

  DifficultySelectionPage({required this.page, required this.data});

  _DifficultySelectionPageState createState() => _DifficultySelectionPageState(page:page, data:data);
}

class _DifficultySelectionPageState extends State<DifficultySelectionPage> {
  _DifficultySelectionPageState({required this.page, required this.data}) : super();
  final page;
  final data;

  String selectedLevel = 'easy';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          children: [
            Container(height:MediaQuery.of(context).size.height*0.05),
            Row(children: [
              SizedBox(width: MediaQuery.of(context).size.width * 0.01),
              IconButton(
                icon: Icon(Icons.arrow_back,
                    color: Colors.white,
                    size: MediaQuery.of(context).size.height * 0.045),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              Container(width:MediaQuery.of(context).size.width*0.6),
              FloatingActionButton.extended(
              onPressed: () {
                if(page=='Drawing Challenge'){
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => DrawPage(level:selectedLevel, data:data,), fullscreenDialog: true),
                  );
                }else if(page=='Memory Challenge'){
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MemoryGameScreen(level:selectedLevel, data:data)),
                  );
                }else if(page=='Breathing Challenge'){
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => GifPage(level:selectedLevel, data:data)),
                  );
                }else if(page=='Meditation Challenge'){
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RelaxationPage(level:selectedLevel, data:data)),
                  );
                }
              },
              label: Text(
                'Next',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: MediaQuery.of(context).size.width*0.05,
                ),
              ),
              backgroundColor: Colors.cyan,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            ],),
            Container(height:MediaQuery.of(context).size.height*0.1),
            Text(
              'Choose A Level',
              style: TextStyle(
                color: Colors.white,
                fontSize: MediaQuery.of(context).size.width*0.12,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(height:MediaQuery.of(context).size.height*0.02),
            Text(
              'This is for the ${page}',
              style: TextStyle(
                color: Colors.white,
                fontSize: MediaQuery.of(context).size.width*0.06,
                fontWeight: FontWeight.w300,
              ),
            ),
            Container(height:MediaQuery.of(context).size.height*0.3),
            ElevatedButton(
              onPressed: () {
                _showDifficultyDialog();
              },
              style: ElevatedButton.styleFrom(
                shape: StadiumBorder(),
                backgroundColor: Colors.blue,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Text(
                  'Select Difficulty: $selectedLevel',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDifficultyDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Difficulty'),
          content: DropdownButton<String>(
            value: selectedLevel,
            items: <String>['easy', 'medium', 'difficult'].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                selectedLevel = newValue!;
              });
              Navigator.of(context).pop();
            },
          ),
        );
      },
    );
  }
}

class Timeline extends StatelessWidget {
  const Timeline({
    Key? key,
    required this.children,
    this.indicators,
    this.isLeftAligned = true,
    this.itemGap = 12.0,
    this.gutterSpacing = 4.0,
    this.padding = const EdgeInsets.all(8),
    this.controller,
    this.lineColor = Colors.grey,
    this.physics,
    this.shrinkWrap = true,
    this.primary = false,
    this.reverse = false,
    this.indicatorSize = 30.0,
    this.lineGap = 4.0,
    this.indicatorColor = Colors.blue,
    this.indicatorStyle = PaintingStyle.fill,
    this.strokeCap = StrokeCap.butt,
    this.strokeWidth = 2.0,
    this.style = PaintingStyle.stroke,
  })  : itemCount = children.length,
        assert(itemGap >= 0),
        assert(lineGap >= 0),
        assert(indicators == null || children.length == indicators.length),
        super(key: key);

  final List<Widget> children;
  final double itemGap;
  final double gutterSpacing;
  final List<Widget>? indicators;
  final bool isLeftAligned;
  final EdgeInsets padding;
  final ScrollController? controller;
  final int itemCount;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final bool primary;
  final bool reverse;

  final Color lineColor;
  final double lineGap;
  final double indicatorSize;
  final Color indicatorColor;
  final PaintingStyle indicatorStyle;
  final StrokeCap strokeCap;
  final double strokeWidth;
  final PaintingStyle style;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: padding,
      separatorBuilder: (_, __) => SizedBox(height: itemGap),
      physics: physics,
      shrinkWrap: shrinkWrap,
      itemCount: itemCount,
      controller: controller,
      reverse: reverse,
      primary: primary,
      itemBuilder: (context, index) {
        final child = children[index];
        final _indicators = indicators;

        Widget? indicator;
        if (_indicators != null) {
          indicator = _indicators[index];
        }

        final isFirst = index == 0;
        final isLast = index == itemCount - 1;

        final timelineTile = <Widget>[
          CustomPaint(
            foregroundPainter: _TimelinePainter(
              hideDefaultIndicator: indicator != null,
              lineColor: lineColor,
              indicatorColor: indicatorColor,
              indicatorSize: indicatorSize,
              indicatorStyle: indicatorStyle,
              isFirst: isFirst,
              isLast: isLast,
              lineGap: lineGap,
              strokeCap: strokeCap,
              strokeWidth: strokeWidth,
              style: style,
              itemGap: itemGap,
            ),
            child: SizedBox(
              height: double.infinity,
              width: indicatorSize,
              child: indicator,
            ),
          ),
          SizedBox(width: gutterSpacing),
          Expanded(child: child),
        ];

        return IntrinsicHeight(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children:
                isLeftAligned ? timelineTile : timelineTile.reversed.toList(),
          ),
        );
      },
    );
  }
}

class _TimelinePainter extends CustomPainter {
  _TimelinePainter({
    required this.hideDefaultIndicator,
    required this.indicatorColor,
    required this.indicatorStyle,
    required this.indicatorSize,
    required this.lineGap,
    required this.strokeCap,
    required this.strokeWidth,
    required this.style,
    required this.lineColor,
    required this.isFirst,
    required this.isLast,
    required this.itemGap,
  })  : linePaint = Paint()
          ..color = lineColor
          ..strokeCap = strokeCap
          ..strokeWidth = strokeWidth
          ..style = style,
        circlePaint = Paint()
          ..color = indicatorColor
          ..style = indicatorStyle;

  final bool hideDefaultIndicator;
  final Color indicatorColor;
  final PaintingStyle indicatorStyle;
  final double indicatorSize;
  final double lineGap;
  final StrokeCap strokeCap;
  final double strokeWidth;
  final PaintingStyle style;
  final Color lineColor;
  final Paint linePaint;
  final Paint circlePaint;
  final bool isFirst;
  final bool isLast;
  final double itemGap;

  @override
  void paint(Canvas canvas, Size size) {
    final indicatorRadius = indicatorSize / 2;
    final halfItemGap = itemGap / 2;
    final indicatorMargin = indicatorRadius + lineGap;

    final top = size.topLeft(Offset(indicatorRadius, 0.0 - halfItemGap));
    final centerTop = size.centerLeft(
      Offset(indicatorRadius, -indicatorMargin),
    );

    final bottom = size.bottomLeft(Offset(indicatorRadius, 0.0 + halfItemGap));
    final centerBottom = size.centerLeft(
      Offset(indicatorRadius, indicatorMargin),
    );

    if (!isFirst) canvas.drawLine(top, centerTop, linePaint);
    if (!isLast) canvas.drawLine(centerBottom, bottom, linePaint);

    if (!hideDefaultIndicator) {
      final Offset offsetCenter = size.centerLeft(Offset(indicatorRadius, 0));

      canvas.drawCircle(offsetCenter, indicatorRadius, circlePaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class Activity extends StatelessWidget {
  final data;
  final user;

  const Activity({required this.data, required this.user});
  List<Widget> generateContainerList(List dataList) {
  List<Widget> containerList = [];

  for (var item in dataList) {
    final value = item.values.first;

    containerList.add(Container(
      alignment: Alignment.center,
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.all(5),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text("$user $value"),
    ));
  }

  return containerList;
}
  
  List<IconData> generateIconList(List dataList) {
  List<IconData> iconList = [];

  for (var item in dataList) {
    final key = item.keys.first;

    IconData? iconData;
    switch (key) {
      case 'memory':
        iconData = Icons.lightbulb;
        break;
      case 'draw':
        iconData = Icons.create;
        break;
      case 'meditate':
        iconData = Icons.self_improvement;
        break;
      case 'breathe':
        iconData = Icons.air;
        break;
      default:
        iconData = Icons.question_mark;
    }

    if (iconData != null) {
      iconList.add(iconData);
    }
  }

  return iconList;
}
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar:AppBar(leading: IconButton(icon:Icon(Icons.arrow_back, color: Color(0xFF0F4FA6), size: MediaQuery.of(context).size.height*0.045),onPressed:(){Navigator.pop(context);}), elevation:0.0, backgroundColor: Colors.transparent,foregroundColor:Colors.transparent, shadowColor: Colors.transparent,surfaceTintColor: Colors.transparent,scrolledUnderElevation: 0.0,),
        body: Container(
          child: SingleChildScrollView(child:Column(
            children: [
              Container(height:MediaQuery.of(context).size.height*0.045),
        //       Row(
        // children: [
        //   Container(width:MediaQuery.of(context).size.width*0.01),
        //   // Icon(Icons.account_circle,
        //   //     color: Color(0xFF0F4FA6), size: MediaQuery.of(context).size.height*0.06), // Profile Icon
        //   IconButton(icon:Icon(Icons.arrow_back, color: Color(0xFF0F4FA6), size: MediaQuery.of(context).size.height*0.045),onPressed:(){Navigator.pop(context);}),]),
              Container(height:MediaQuery.of(context).size.height*0.01),
              SingleChildScrollView(child:Column(children:[
              Text(
                "Activity Log",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(height:MediaQuery.of(context).size.height*0.07),
              SingleChildScrollView(child:
              Timeline(
                children:generateContainerList(data),
              // children: <Widget>[
              //   Container(height: 100, color: Colors.grey),
              //   Container(height: 50, color: Colors.grey),
              //   Container(height: 200, color: Colors.grey),
              //   Container(height: 100, color: Colors.grey),
              // ],
              indicators: generateIconList(data).map((iconData) => Icon(iconData)).toList())),
              // Add other widgets here for your activity log content
            ],
          ),)]),),
        ),
      ),
    );
  }
}
class ChallengeScreen extends StatefulWidget with Functions {
  const ChallengeScreen({super.key, required this.user});
  final user;
  @override
  @override
  _ChallengeScreenState createState() => _ChallengeScreenState(user: user);
}

class _ChallengeScreenState extends State<ChallengeScreen> {
  _ChallengeScreenState({required this.user}) : super();
  @override
  var user;
  CollectionReference login = FirebaseFirestore.instance.collection('audios');
  Future<List> futureData() async {
    // Simulate fetching data from a source (e.g., Firestore)
    return [
      await login.doc(user).get(),
    ];
  }
  initState(){

  }
  Widget build(BuildContext context){
    return Scaffold(
        body: FutureBuilder(
            future: futureData(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text("Something went wrong");
              }
              if (snapshot.connectionState == ConnectionState.done) {
                final List? items = snapshot.data;
                var data = (items![0] as DocumentSnapshot).data() as Map;
                var activities=[user, data['activity']];
                return Container(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.03),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(height:MediaQuery.of(context).size.height*0.08,),
                        Container(child:Text(
                          'Daily Challenges!',
                          style: TextStyle(
                            color: Colors.indigo[400],
                            fontSize: 32.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ),
                        Container(height:MediaQuery.of(context).size.height*0.00,),
                        Row(children:[
                          Column(children:[
                            ChallengeCard(
                              color: Colors.blue,
                              title: 'Meditation Challenge',
                              data: 'Meditate for 10 minutes',
                              onpress:DifficultySelectionPage(page:'Meditation Challenge', data:activities)
                            ),
                            Container(height:MediaQuery.of(context).size.height*0.03,),
                          ChallengeCard(
                          color: Colors.purple,
                          title: 'Breathing Challenge',
                          data: 'Practice a breathing exercise for 10 minutes.',
                          // onpress:GifPage(level:'medium')
                          onpress:DifficultySelectionPage(page:'Breathing Challenge', data:activities)
                        ),
                          ]),
                        Container(width:MediaQuery.of(context).size.width*0.06,),
                        Column(children:[
                          Container(height:MediaQuery.of(context).size.height*0.06,),
                          InkWell(
                            onTap: (){
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => Activity(data:activities[1], user:data['User'])),
                              );// S
                            },
                            borderRadius: BorderRadius.circular(20.0),
                            child: Container(
                              width:MediaQuery.of(context).size.width * 0.44,
                              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(width:MediaQuery.of(context).size.width * 0.00),
                                  Text(
                                    "Activity Log",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16.0,
                                    ),
                                  ),
                                  Container(width:MediaQuery.of(context).size.width * 0.05,),
                                  Icon(
                                    Icons.arrow_forward,
                                    color: Colors.black,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(height:MediaQuery.of(context).size.height*0.02,),
                          ChallengeCard(
                          color: Colors.pink,
                          title: 'Memory Challenge',
                          data: 'Flip and match hidden icons for a challenging memory game experience! ',
                          onpress:DifficultySelectionPage(page:'Memory Challenge', data:activities)
                        ),
                        Container(height:MediaQuery.of(context).size.height*0.03,),
                        ChallengeCard(
                          color: Color.fromARGB(255, 52, 217, 243),
                          title: 'Drawing Challenge',
                          data: 'Draw an image according to a prompt, or your own imagination.',
                          onpress:DifficultySelectionPage(page:'Drawing Challenge', data:activities)
                        ),
                        ]),
                        ]),
                      ],
                    ),
                  ),
                );
              }else{
                return Center(child:CircularProgressIndicator(color:Color(0xFF0F4FA6)));
              }
            }
        )
    );
  }
}


