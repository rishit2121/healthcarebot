import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as stripe;
import 'resources/chat.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'login.dart';
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

Future<List> fetchExercises() async {
  final url = Uri.parse(
      'https://exercisedb.p.rapidapi.com/exercises'); //BEST_MATCH also

  final headers = {
    'X-RapidAPI-Key': 'b271ecb65fmshd32cd3e3e0dd409p1aaa88jsnf9c93122133f',
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

Future<List> fetchNews() async {
  final headers = {
    'X-BingApis-SDK': 'true',
    'X-RapidAPI-Key': '24d7fdb755mshe9ad7b273211de1p160e9bjsn32244367e3e3',
    'X-RapidAPI-Host': 'bing-news-search1.p.rapidapi.com',
  };

  var response = await http.get(
    Uri.parse(
        'https://bing-news-search1.p.rapidapi.com/news/search?q=Health&count=80&setLang=EN&textFormat=Raw&safeSearch=Off&originalImg=true&freshness=Month'),
    headers: headers,
  );

  if (response.statusCode == 200) {
    // Request succeeded, parse the response
    var data = json.decode(response.body);
    // Handle the data
    return (data["value"]);
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
  final Function() onProfilePressed;

  CustomAppBar({required this.title, required this.onProfilePressed});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(10),
        ),
      ),
      backgroundColor: Colors.white,
      elevation: 1,
      //   flexibleSpace: Container(
      //   decoration: const BoxDecoration(
      //     gradient: LinearGradient(
      //       begin: Alignment.topLeft,
      //       end: Alignment.bottomRight,
      //       colors: <Color>[Color.fromARGB(255, 202, 244, 255), Color.fromARGB(255, 209, 230, 255)]),
      //   ),
      // ),
      title: Row(
        children: [
          Icon(Icons.account_circle,
              color: Color(0xFF007BFF), size: 30), // Profile Icon
          SizedBox(width: 8.0), // Add some space between the icon and title
          Text(
            title,
            style: GoogleFonts.raleway(
                color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ],
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
  ScrollController _scrollController = ScrollController();

  _scrollToBottom() {
    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
  }

  Future<void> _sendMessage(user) async {
    //credits later
    if (_textEditingController.text.isNotEmpty) {
      // await FirebaseFirestore.instance.collection('audios').doc('$user').update({'Credits': credits-1});
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
        _simulateBotResponse();
      });
    }
  }

  Future<void> _simulateBotResponse() async {
    // Simulating a delayed bot response
    setState(() {
      messages.add(true);
    });
    List<dynamic> response = await Functions.responser2(chat_history2);
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
    Future.delayed(Duration(seconds: 6), () {
      setState(() {
        _scrollToBottom();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // return FutureBuilder(
    //     future:
    //         FirebaseFirestore.instance.collection('audios').doc('$user').get(),
    //     builder: (context, snapshot) {
    //       if (snapshot.hasError) {
    //         return Text("Something went wrong");
    //       }
    //       if (snapshot.connectionState == ConnectionState.done) {
    //         final items = snapshot.data;
    //         var data = (items as DocumentSnapshot).data() as Map;
    return Scaffold(
        appBar: CustomAppBar(
          title: "  Eva",
          onProfilePressed: () {
            showProfileMenu(context);
          },
        ),
        body: Container(
          decoration: BoxDecoration(color: Color.fromARGB(255, 255, 255, 255)),
          child: Column(
            children: <Widget>[
              Row(children: <Widget>[
                Container(width: MediaQuery.of(context).size.width * 0.35),
                // Text('Credits: ${data['Credits']}'),
                // TextButton(child:Text("Add more"), onPressed:(){
                //   Navigator.push(
                //     context,
                //     MaterialPageRoute(
                //       builder: (context) => SubscriptionPage(currentCredits:data['Credits'], user:user),
                //     ),
                //   );
                // })
              ]),
              Container(height: MediaQuery.of(context).size.height * 0.02),
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
                      return _buildBotMessageBubble(message);
                    } else {
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
                      icon: Icon(Icons.send, color: Colors.black),
                      onPressed: (() {
                        _sendMessage(user);
                      }), //Add data['Credits'] later
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
    // }
    //   return Center(
    //     child: CircularProgressIndicator(),
    //   );
    // });
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

  Widget _buildBotMessageBubble(Message message) {
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
          Container(
            padding: EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 215, 215, 215),
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                  topRight: Radius.circular(16)),
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
                    primary: Color.fromARGB(255, 245, 245,
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
  final cameras = await availableCameras();
  final firstCamera = cameras.first;
  await MobileAds.instance.initialize();
  stripe.Stripe.publishableKey =
      "pk_test_51NmiBSGseqFBdXVsWiAI51HJYB3Z34pDouqmxbo9jIHvkIK1VYNEYaUVojJGJmOqA7LrXAF7OPje6LlE8GFdko4Y00Y1VYrnvu";
  await dotenv.load(fileName: "assets/.env");
  await Firebase.initializeApp();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var email = prefs.getString("email");
  final List<Widget> _widgetOptions = [
    HomePage(user: "$email"),
    ChatScreen(user: "$email"),
    TakePictureScreen(camera: firstCamera),
    // Planner(user: "$email"),
    JournalPage(),
    // PostPage(currentUser: "$email"),    // ProfilePage(user:"$email"),
  ];
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((value) => runApp(MaterialApp(
            // theme:ThemeData(
            //   fontFamily: GoogleFonts.raleway().fontFamily,
            // ),
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
            width: MediaQuery.of(context).size.width * 0.02,
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.015,
            height: MediaQuery.of(context).size.height * 0.09,
            child: const DecoratedBox(
              decoration: const BoxDecoration(color: Colors.blue),
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
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              DateFormat('MMMM')
                  .format(DateTime.parse("${routineName['date']} 00:00:00")),
              style: TextStyle(
                fontSize: 14,
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
    _dataFuture = fetchExercises();
    _dataFuture.then((items) {
      setState(() {
        _searchResult = List.from(
            items); // Create a new list with the same contents as items
      });
    });
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
        body: FutureBuilder<List>(
            future: _dataFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              } else {
                final items = snapshot.data;
                void _sortExercises(index) {
                  temp = _searchResult[index];
                  items!.remove(_searchResult[index]);
                  items.insert(0, temp);
                  _searchResult.removeAt(index);
                  _searchResult.insert(0, temp);
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
                    });
                  } else {
                    setState(() {
                      _searchResult = items!.toList();
                    });
                  }
                }

                return SingleChildScrollView(
                    child: Column(
                  children: [
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
                                    // Toggle exercise selection
                                    if (selectedExercises
                                        .contains(_searchResult[index])) {
                                      selectedExercises
                                          .remove(_searchResult[index]);
                                    } else {
                                      selectedExercises
                                          .add(_searchResult[index]);
                                    }
                                    _sortExercises(index);
                                  });
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
                                          trailing: selectedExercises.contains(
                                                  _searchResult[index])
                                              ? Icon(Icons.check,
                                                  color: Colors.green)
                                              : Icon(
                                                  Icons.add,
                                                  color: Color(0xFF007BFF),
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
                        bottom: 16.0,
                        right: 16.0,
                        child: FloatingActionButton(
                          onPressed: () {
                            // Save selected exercises and navigate back to the previous page
                            Navigator.pop(context, selectedExercises);
                          },
                          child: Icon(Icons.check),
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

class SearchBarPage extends StatefulWidget {
  const SearchBarPage({super.key});

  @override
  _SearchBarPageState createState() => _SearchBarPageState();
}

class _SearchBarPageState extends State<SearchBarPage> {
  late Future<List> _dataFuture;
  var bob = "NO";
  List _searchResult = [];
  void initState() {
    super.initState();
    _dataFuture = fetchExercises();
    _dataFuture.then((items) {
      setState(() {
        _searchResult = List.from(
            items); // Create a new list with the same contents as items
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: FutureBuilder<List>(
            future: _dataFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              } else {
                final items = snapshot.data;

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
                    });
                  } else {
                    setState(() {
                      _searchResult = items!.toList();
                    });
                  }
                }

                return Column(
                  children: [
                    Container(height: MediaQuery.of(context).size.height * 0.1),
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
                    Expanded(
                      child: ListView.builder(
                        itemCount: _searchResult.length,
                        itemBuilder: (context, index) {
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
                                    _searchResult[index]['name'],
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
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
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.3,
                                      width:
                                          MediaQuery.of(context).size.height *
                                              0.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              }
            }));
  }
}

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
    return [await login.doc(user).get(), await fetchExercises()];
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
            var exerciseItems = items![1];
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
                        Container(
                          height: MediaQuery.of(context).size.height * 0.38,
                          padding: EdgeInsets.all(16),
                          child: SfDateRangePicker(
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
                            child: Icon(Icons.add, color: Color(0xFF007BFF)),
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
                  backgroundColor: Color(0xFF007BFF),
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
            child: CircularProgressIndicator(),
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
    newsArticles = fetchNews();
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
    final DateTime articleDateTime = DateTime.parse(article['datePublished']);
    final String formattedDate =
        '${articleDateTime.year}-${articleDateTime.month.toString().padLeft(2, '0')}-${articleDateTime.day.toString().padLeft(2, '0')}';
    final String imageUrl = article['image'] != null &&
            article['image']['thumbnail'] != null
        ? article['image']['thumbnail']['contentUrl']
        : (article['contentUrl'] != null
            ? article['contentUrl']
            : 'https://st3.depositphotos.com/23594922/31822/v/450/depositphotos_318221368-stock-illustration-missing-picture-page-for-website.jpg');
    return Card(
      margin: EdgeInsets.all(10),
      child: ExpansionTile(
        title: Text(
          article['name'], // Title displayed in bold
          style: TextStyle(
            fontWeight: FontWeight.bold, // Make the title bold
          ),
        ),
        leading: Image.network(imageUrl, width: 50, height: 50),
        subtitle: Text(formattedDate),
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(article['description']), // Display the entire description
                OutlinedButton(
                  onPressed: () {
                    launchUrl(Uri.parse(article['url']),
                        mode: LaunchMode.externalApplication);
                  },
                  style: OutlinedButton.styleFrom(
                    primary: Colors.transparent, // Transparent background
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
                appBar: AppBar(title: Text('Profile')),
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
                            backgroundColor: Color(0xFF007BFF),
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
                                                          Text(
                                                            'Edit Answer',
                                                            style: TextStyle(
                                                                fontSize: 18,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                          SizedBox(height: 8),
                                                          Text(
                                                            questionAnswerList[
                                                                        index][
                                                                    'question'] ??
                                                                '',
                                                            style: TextStyle(
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                          SizedBox(height: 16),
                                                          TextField(
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
                                                          SizedBox(height: 16),
                                                          ElevatedButton(
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
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                },
                                              );
                                            },
                                            child: Icon(
                                              Icons.edit,
                                              color: Colors
                                                  .blue, // Customize the icon color
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
            child: CircularProgressIndicator(),
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
        selectedLabelStyle: TextStyle(color: Color(0xFF007BFF)),
        unselectedLabelStyle: TextStyle(color: Colors.black),
        selectedItemColor: Color(0xFF007BFF),
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
              Icons.view_stream,
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
              return CircularProgressIndicator(); // While waiting for the data
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
          return CircularProgressIndicator();
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
          return CircularProgressIndicator();
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
              ),
            ),
            SizedBox(height: 20.0),
            AmountTextField(
              onChanged: (amount) {
                // Use the entered amount in your logic
                setState(() {
                  _amount = amount;
                });
              },
            ),
            ElevatedButton(
              onPressed: () {
                // Implement payment logic here
                // You can navigate to a payment screen or handle payment processing.
                // For simplicity, we'll just display a message for now.
                makePayment((_amount * 8).round(), _amount);
                // fetchOffers,
              },
              child: Text('Pay Now'),
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
  final ValueNotifier<String> selectedFeeling = ValueNotifier<String>('');
  CollectionReference login = FirebaseFirestore.instance.collection('audios');
  void initState() {
    super.initState();
  }

  Future<List> futureData() async {
    // Simulate fetching data from a source (e.g., Firestore)
    return [
      await login.doc(user).get(),
      await fetchExercises(),
      await fetchNews()
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
                var exerciseItems = items![1];
                data = (items![0] as DocumentSnapshot).data() as Map;
                if (data['planner'] == null) {
                  data['planner'] = {};
                }
                var article = snapshot.data![2];
                final DateTime articleDateTime =
                    DateTime.parse(article![0]['datePublished']);
                List NewsData(int index) {
                  final desc = article[index]['description'];
                  final name = article[index]['name'];
                  final url = article[index]['url'];
                  final String formattedDate =
                      '${articleDateTime.year}-${articleDateTime.month.toString().padLeft(2, '0')}-${articleDateTime.day.toString().padLeft(2, '0')}';
                  final String imageUrl = article![index]['image'] != null &&
                          article[index]['image']['thumbnail'] != null
                      ? article[index]['image']['thumbnail']['contentUrl']
                      : (article[index]['contentUrl'] != null
                          ? article[0]['contentUrl']
                          : 'https://st3.depositphotos.com/23594922/31822/v/450/depositphotos_318221368-stock-illustration-missing-picture-page-for-website.jpg');
                  return ([name, desc, formattedDate, imageUrl, url]);
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
                    combinedList.addAll(listOfDicts);
                  }

                  combinedList.sort((a, b) {
                    DateTime dt1 = DateTime.parse("${a["date"]} 00:00:00");
                    DateTime dt2 = DateTime.parse("${b["date"]} 00:00:00");
                    return dt1.compareTo(dt2);
                  });
                });

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
                            height: MediaQuery.of(context).size.height * 0.02),
                      if (data[value2] == null)
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              'How are you feeling today?',
                              style: TextStyle(fontSize: 18),
                            ),
                            SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                buildFeelingEmoji('😡', 'Angry'),
                                buildFeelingEmoji('😞', 'Sad'),
                                buildFeelingEmoji('😐', 'Neutral'),
                                buildFeelingEmoji('😄', 'Happy'),
                              ],
                            ),
                          ],
                        ),
                      Divider(thickness: 2.0),
                      Container(
                          height: MediaQuery.of(context).size.height * 0.05),
                      Row(children: [
                        Container(
                            height: MediaQuery.of(context).size.height * 0.1,
                            width: MediaQuery.of(context).size.width * 0.05),
                        Container(
                          child: Image.asset(
                              'assets/Screen Shot 2023-09-29 at 7.48.08 PM.png'), // Replace with the actual path to your screenshot image
                        ),
                        Container(
                            width: MediaQuery.of(context).size.width * 0.15),
                        Column(children: [
                          Text('Not feeling well?\nHave a talk.'),
                          _buildTalkButton(),
                        ])
                      ]),
                      Container(
                          height: MediaQuery.of(context).size.height * 0.05),
                      // _buildSectionTitle('Have a talk'),

                      // Divider
                      Divider(thickness: 2.0),

                      // Today's Exercises
                      _buildSectionTitle("Upcoming Exercises"),
                      Container(
                          height: MediaQuery.of(context).size.height * 0.01),
                      if (combinedList.length == 0)
                        Container(
                            height: MediaQuery.of(context).size.height * 0.02),
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
                      Divider(thickness: 2.0),
                      _buildSectionTitle("Latest News"),
                      Container(
                          height: MediaQuery.of(context).size.height * 0.01),
                      // Random Quote
                      Column(
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
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
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              Text(
                                                '${NewsData(0)[0]}',
                                                style: TextStyle(
                                                  fontSize: 24.0,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(height: 12.0),
                                              Image.network(
                                                '${NewsData(0)[3]}', // Replace with your news image URL
                                                fit: BoxFit.cover,
                                              ),
                                              SizedBox(height: 12.0),
                                              Text(
                                                '${NewsData(0)[1]}',
                                                style:
                                                    TextStyle(fontSize: 16.0),
                                              ),
                                              SizedBox(height: 16.0),
                                              OutlinedButton(
                                                onPressed: () {
                                                  launchUrl(
                                                      Uri.parse(NewsData(0)[4]),
                                                      mode: LaunchMode
                                                          .externalApplication);
                                                },
                                                style: OutlinedButton.styleFrom(
                                                  primary: Colors
                                                      .transparent, // Transparent background
                                                  side: BorderSide(
                                                      color: Color(
                                                          0xFF007BFF)), // Add an outline
                                                ),
                                                child: Text(
                                                  'Read More',
                                                  style: TextStyle(
                                                    color: Color(
                                                        0xFF007BFF), // Text color
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
                                child: ShadedContainer(
                                  color: NewsData(0)[3],
                                  child: ContainerContent(
                                    title: '${NewsData(0)[0]}',
                                    description: '${NewsData(0)[1]}',
                                  ),
                                ),
                              ),
                              Container(
                                  height: MediaQuery.of(context).size.height *
                                      0.01),
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
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              Text(
                                                '${NewsData(1)[0]}',
                                                style: TextStyle(
                                                  fontSize: 24.0,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(height: 12.0),
                                              Image.network(
                                                '${NewsData(1)[3]}', // Replace with your news image URL
                                                fit: BoxFit.cover,
                                              ),
                                              SizedBox(height: 12.0),
                                              Text(
                                                '${NewsData(1)[1]}',
                                                style:
                                                    TextStyle(fontSize: 16.0),
                                              ),
                                              SizedBox(height: 16.0),
                                              OutlinedButton(
                                                onPressed: () {
                                                  launchUrl(
                                                      Uri.parse(NewsData(1)[4]),
                                                      mode: LaunchMode
                                                          .externalApplication);
                                                },
                                                style: OutlinedButton.styleFrom(
                                                  primary: Colors
                                                      .transparent, // Transparent background
                                                  side: BorderSide(
                                                      color: Color(
                                                          0xFF007BFF)), // Add an outline
                                                ),
                                                child: Text(
                                                  'Read More',
                                                  style: TextStyle(
                                                    color: Color(
                                                        0xFF007BFF), // Text color
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
                                child: ShadedContainer(
                                  color: NewsData(1)[3],
                                  child: ContainerContent(
                                    title: '${NewsData(1)[0]}',
                                    description: '${NewsData(1)[1]}',
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Container(
                              height:
                                  MediaQuery.of(context).size.height * 0.01),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
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
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              Text(
                                                '${NewsData(2)[0]}',
                                                style: TextStyle(
                                                  fontSize: 24.0,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(height: 12.0),
                                              Image.network(
                                                '${NewsData(2)[3]}', // Replace with your news image URL
                                                fit: BoxFit.cover,
                                              ),
                                              SizedBox(height: 12.0),
                                              Text(
                                                '${NewsData(2)[1]}',
                                                style:
                                                    TextStyle(fontSize: 16.0),
                                              ),
                                              SizedBox(height: 16.0),
                                              OutlinedButton(
                                                onPressed: () {
                                                  launchUrl(
                                                      Uri.parse(NewsData(2)[4]),
                                                      mode: LaunchMode
                                                          .externalApplication);
                                                },
                                                style: OutlinedButton.styleFrom(
                                                  primary: Colors
                                                      .transparent, // Transparent background
                                                  side: BorderSide(
                                                      color: Color(
                                                          0xFF007BFF)), // Add an outline
                                                ),
                                                child: Text(
                                                  'Read More',
                                                  style: TextStyle(
                                                    color: Color(
                                                        0xFF007BFF), // Text color
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
                                child: ShadedContainer(
                                  color: NewsData(2)[3],
                                  child: ContainerContent(
                                    title: '${NewsData(2)[0]}',
                                    description: '${NewsData(2)[1]}',
                                  ),
                                ),
                              ),
                              Container(
                                  height: MediaQuery.of(context).size.height *
                                      0.01),
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
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              Text(
                                                '${NewsData(3)[0]}',
                                                style: TextStyle(
                                                  fontSize: 24.0,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(height: 12.0),
                                              Image.network(
                                                '${NewsData(3)[3]}', // Replace with your news image URL
                                                fit: BoxFit.cover,
                                              ),
                                              SizedBox(height: 12.0),
                                              Text(
                                                '${NewsData(3)[1]}',
                                                style:
                                                    TextStyle(fontSize: 16.0),
                                              ),
                                              SizedBox(height: 16.0),
                                              OutlinedButton(
                                                onPressed: () {
                                                  launchUrl(
                                                      Uri.parse(NewsData(3)[4]),
                                                      mode: LaunchMode
                                                          .externalApplication);
                                                },
                                                style: OutlinedButton.styleFrom(
                                                  primary: Colors
                                                      .transparent, // Transparent background
                                                  side: BorderSide(
                                                      color: Color(
                                                          0xFF007BFF)), // Add an outline
                                                ),
                                                child: Text(
                                                  'Read More',
                                                  style: TextStyle(
                                                    color: Color(
                                                        0xFF007BFF), // Text color
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
                                child: ShadedContainer(
                                  color: NewsData(3)[3],
                                  child: ContainerContent(
                                    title: '${NewsData(3)[0]}',
                                    description: '${NewsData(3)[1]}',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                          height: MediaQuery.of(context).size.height * 0.01),
                      Row(children: [
                        Container(
                            width: MediaQuery.of(context).size.width * 0.05),
                        ElevatedButton(
                            child: Text("View All"),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      NewsPage(totalData: article),
                                ),
                              );
                            }),
                        Container(
                            width: MediaQuery.of(context).size.width * 0.2),
                      ]),
                      Container(
                          height: MediaQuery.of(context).size.height * 0.01),
                      // You can add your exercise list here

                      // Divider
                      Divider(thickness: 2.0),
                      _buildSectionTitle('Quote Of The Day'),
                      Container(
                          height: MediaQuery.of(context).size.height * 0.025),
                      _buildRandomQuote(),

                      // Divider
                      Divider(thickness: 2.0),
                    ],
                  ),
                );
              }
              return Center(
                child: CircularProgressIndicator(),
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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        text,
        style: GoogleFonts.raleway(
          fontSize: 26,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildProfile() {
    return PopupMenuButton<String>(
      icon: Icon(Icons.person_rounded, color: Colors.blue),
      onSelected: (value) async {
        // Handle item selection here
        if (value == 'Logout') {
          SharedPreferences pref = await SharedPreferences.getInstance();
          pref.setString("email", "");
          FirebaseAuth.instance.signOut();
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => LoginPage()));
        } else if (value == 'About') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProfilePage(user: user),
            ),
          );
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: 'About',
          child: Text('About'),
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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MyHomePage(widgets: [
                HomePage(user: "$user"),
                ChatScreen(user: "$user"),
                Planner(user: "$user"),
                PostPage(currentUser: "$user"),
                // ProfilePage(user:"$email"),
              ], selectedIndex: 1),
            ),
          );
        },
        child: Text('Start'),
      ),
    );
  }

  Widget _buildRandomQuote() {
    // You can add your random quote widget here
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Text(
        "Today is your opportunity to build the tomorrow you want.\n\n -KEN POIROT",
        style: TextStyle(
          fontSize: 16,
          fontStyle: FontStyle.italic,
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

class JournalPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(height: MediaQuery.of(context).size.height * 0.07),
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 5.0, 0.0),
              child: Text(
                DateFormat.MMMMd().format(DateTime.now()),
                style: GoogleFonts.raleway(
                  fontSize: 33, // Adjust the font size as needed
                  // Adjust the font weight as needed
                  // You can also set other text styles here
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 0.0, 0.0, 0.0),
              child: Text(
                DateFormat.y().format(DateTime.now()),
                style: GoogleFonts.raleway(
                  fontSize: 33, // Adjust the font size as needed
                  // Adjust the font weight as needed
                  // You can also set other text styles here
                ),
              ),
            ),
          ),
          Container(height: MediaQuery.of(context).size.height * 0.05),
          Container(
            height: MediaQuery.of(context).size.height * 0.15,
            width: MediaQuery.of(context).size.width * 0.9,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.blue, // Border color
                width: 2.0, // Border width
              ),
              borderRadius: BorderRadius.circular(20), // Curved edges
            ),
          ),
          Container(height: MediaQuery.of(context).size.height * 0.05),
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 5.0, 0.0),
                child: Row(children: [
                  Text(
                    "Latest Entries",
                    style: GoogleFonts.raleway(
                      fontSize: 25, // Adjust the font size as needed
                      // Adjust the font weight as needed
                      // You can also set other text styles here
                    ),
                  ),
                  Container(width: MediaQuery.of(context).size.width * 0.25),
                  Text(
                    "View All",
                    style: GoogleFonts.raleway(
                      fontSize: 15, // Adjust the font size as needed
                      // Adjust the font weight as needed
                      // You can also set other text styles here
                    ),
                  )
                ])),
          ),
          Container(
            height: MediaQuery.of(context).size.height * 0.275,
            width: MediaQuery.of(context).size.width * 0.9,
            child: ListView.builder(
              itemCount: 5, // Number of items
              itemBuilder: (context, index) {
                return Container(
                  child: Text('Item $index'),
                );
              },
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.9,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddEntryPage(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.all(16.0), // Adjust padding as needed.
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(20.0), // Adjust radius as needed.
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.add,
                  ), // Replace with your desired icon.
                  SizedBox(height: 8.0),
                  Text(
                    'Create Entry',
                    style: TextStyle(fontSize: 14.0),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AddEntryPage extends StatefulWidget {
  @override
  _AddEntryPageState createState() => _AddEntryPageState();
}

class _AddEntryPageState extends State<AddEntryPage> {
  String title = '';
  String description = '';
  String audioFilePath = '';
  String imageFilePath = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(height: MediaQuery.of(context).size.height * 0.02),
            Row(children: [
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Container(
                  child: Center(
                      child: Text("Go Back",
                          style: TextStyle(color: Colors.white))),
                  height: MediaQuery.of(context).size.height * 0.04,
                  width: MediaQuery.of(context).size.width * 0.18,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(10), // Curved edges
                  ),
                ),
              ),
              Container(width: MediaQuery.of(context).size.width * 0.14),
              Text(
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
                child: Container(
                  child: Center(
                      child: Text("Publish",
                          style: TextStyle(color: Colors.white))),
                  height: MediaQuery.of(context).size.height * 0.04,
                  width: MediaQuery.of(context).size.width * 0.17,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(10), // Curved edges
                  ),
                ),
              ),
            ]),
            Container(height: MediaQuery.of(context).size.height * 0.02),
            Text("Title"),
            TextField(
              onChanged: (value) {
                setState(() {
                  title = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Name Your Entry',
              ),
            ),
            Container(height: MediaQuery.of(context).size.height * 0.02),
            Text("Description"),
            Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height *
                  0.52, // Set the width to expand across the screen
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    description = value;
                  });
                },
                maxLines: null, // Set maxLines to null for multiple lines
                decoration: InputDecoration(
                  hintText: 'Write about your day...',
                  border: InputBorder.none, // Remove the default border
                  focusedBorder: UnderlineInputBorder(
                    // Add an underline decoration
                    borderSide: BorderSide(
                      color: Colors.blue, // Define the underline color
                      width: 2.0, // Define the underline width
                    ),
                  ),
                ),
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height * 0.1,
            ),
            Divider(thickness: 1.0, color: Colors.black),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) => TakePictureScreen(),
                        //   ),
                        // );
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width *
                            0.4, // Adjust width as needed
                        padding: EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius:
                              BorderRadius.circular(20.0), // Curved edges
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.camera,
                              color: Colors.white, // Make the icon white
                            ),
                            SizedBox(height: 8.0), // Adjust spacing as needed
                            Text(
                              'Add Image',
                              style: TextStyle(
                                color: Colors.white, // Text color
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16.0), // Adjust spacing between buttons
                  ],
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.1,
                ),
                Column(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width *
                          0.4, // Adjust width as needed
                      padding: EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius:
                            BorderRadius.circular(20.0), // Curved edges
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.mic,
                            color: Colors.white, // Make the icon white
                          ),
                          SizedBox(height: 8.0), // Adjust spacing as needed
                          Text(
                            'Add Audio',
                            style: TextStyle(
                              color: Colors.white, // Text color
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.0), // Adjust spacing between buttons
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    ));
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

class TakePictureScreen extends StatefulWidget {
  final CameraDescription camera;

  TakePictureScreen({required this.camera});

  @override
  _TakePictureScreenState createState() => _TakePictureScreenState();
}

class _TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  late File _capturedImage;
  bool _showCapturedImage = false;
  @override
  void initState() {
    super.initState();
    _controller = CameraController(widget.camera, ResolutionPreset.medium);
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _captureImage() async {
    try {
      final image = await _controller.takePicture();
      setState(() {
        _capturedImage = File(image.path);
        _showCapturedImage = true;
      });
    } catch (e) {
      print('Error taking picture: $e');
    }
  }

  void _proceedWithImage() {
    // Add your logic for proceeding with the captured image here.
    // This can include saving the image or navigating to a new screen.
  }

  void _cancelImageCapture() {
    setState(() {
      _showCapturedImage = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showCapturedImage) {
      return Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Image.file(_capturedImage), // Display the captured image
          ),
          Positioned(
            bottom: 20,
            left: MediaQuery.of(context).size.width * 0.35,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _proceedWithImage,
                  child: Text('Proceed'),
                ),
                SizedBox(width: 16.0),
                ElevatedButton(
                  onPressed: _cancelImageCapture,
                  child: Text('Cancel'),
                ),
              ],
            ),
          )
        ],
      );
    } else {
      return FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: CameraPreview(_controller),
                  ),
                ),
                Positioned(
                  bottom: 20,
                  left: MediaQuery.of(context).size.width * 0.5,
                  child: FloatingActionButton(
                    // Provide an onPressed callback.
                    onPressed: _captureImage,
                    child: const Icon(Icons.camera_alt),
                  ),
                )
              ],
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      );
    }
  }
}
