import 'package:flutter/material.dart';
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



Future<List> fetchExercises() async {
  final url = Uri.parse('https://exercisedb.p.rapidapi.com/exercises'); //BEST_MATCH also

  final headers = {
    'X-RapidAPI-Key': '24d7fdb755mshe9ad7b273211de1p160e9bjsn32244367e3e3',
    'X-RapidAPI-Host': 'exercisedb.p.rapidapi.com',
  };

  final response = await http.get(url, headers: headers);

  if (response.statusCode == 200) {
    // Request succeeded, parse the response
    var data = json.decode(response.body);
    // Handle the data
    return(data);
  } else {
    // Request failed
    print('Request failed with status: ${response.statusCode}');
    return([]);
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

  final double gapOnRight = 0; // Replace this with the desired gap on the right side

  final screenWidth=MediaQuery. of(context). size. width;

  final double rightOffset = screenWidth-gapOnRight;
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
        child: Text("Log Out", style:TextStyle(color:Colors.red)),
      ),
    ],
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  ).then((value) {
    if (value == "logout") {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
      print("Logging out...");
    } else if (value == "learn_more") {
      // Handle learn more action
      print("Learn more pressed...");
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
      elevation:0,
      backgroundColor: Color.fromARGB(255, 237, 237, 237),
      leading: IconButton(
        icon: Icon(Icons.menu, color: Color.fromARGB(255, 11, 178, 255)),
        onPressed: () {
          // Handle menu icon press here
        },
      ),
      title: Text(
        title,
        style: TextStyle(color: Colors.black, fontWeight:FontWeight.bold),
      ),
      actions: [
        Stack(
            alignment: Alignment.topRight,
            children: [
              IconButton(
                icon: Icon(Icons.person, color: Color.fromARGB(255, 11, 178, 255)),
                onPressed: () => onProfilePressed(),
              ), // Indicator dot to show the presence of the bubble
            ],
        )
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}


class ChatScreen extends StatefulWidget with Functions {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List messages = [
    Message(sender: 'Bot', text: 'Hello, my name is Sam, and I am your healthcare assistant. How may I help you today?', list:[]),
  ];
  var chat_history='\nSam: Hello, my name is Sam, and I am your healthcare assistant. How may I help you today? <END_OF_TURN>';
  var chat_history2=[{"role": "assistant", "content": "Hello, my name is Sam, and I am your healthcare assistant. How may I help you today?"},];
  TextEditingController _textEditingController = TextEditingController();
  int currentProductIndex = 0;
  var currentPhotoIndex=0;
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
    List<dynamic> response = await Functions.responser(chat_history);
    var sentence=response[0];
    sentence=sentence.replaceAll('<END_OF_TURN>', '');
    sentence=sentence.replaceAll('\n', '');
    Message botMessage = Message(sender: 'Bot', text: sentence, list:[]);
    chat_history=chat_history+"\n"+"Sam: "+botMessage.text+" <END_OF_TURN>";
    chat_history2=chat_history2+[{"role": "assistant", "content": botMessage.text}];
    setState((){
      messages.add(botMessage);
      if(response[2]=='3'){
        Message productMessage = Message(sender: 'Shopper', text: "Heres a few items  you can buy:", list:response[3]);
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
    return Scaffold(
      appBar:CustomAppBar(
          title: "Healthcare Assistant",
          onProfilePressed: () {
            showProfileMenu(context);
          },
        ),
      body: Container(
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
                } else {
                  return _buildProductListMessage(message);
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


  Widget _buildProductListMessage(Message message) {
    double width = MediaQuery. of(context). size. width;
    double length = MediaQuery. of(context). size. height;
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
                          if (currentProductIndex > 0) {
                            currentProductIndex--;
                          }
                        });
                      },
                    ),
                    Container(
                      width:width*0.5,
                      height:length*0.05,
                      child:Text(
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
                    primary: Color.fromARGB(255, 245, 245, 245), // Match the container background color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0), // Adjust the button border radius
                    ),
                  ),
                  onPressed: () {
                    if(message.list[currentProductIndex]['product_photos']==null){
                      message.list[currentProductIndex]['product_photos'].add('data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAH8AAAB/CAMAAADxY+0hAAAAY1BMVEX///8AAAAuLi4mJibn5+fY2NjOzs4jIyPJycnS0tLV1dW9vb0ODg7t7e3CwsIJCQkdHR0VFRUzMzOioqJoaGg8PDxFRUWAgID39/eWlpZXV1fe3t6Ghoaqqqp5eXmcnJxfX1+3S2YiAAADlElEQVRoge2bW3erIBCFnSRoTCQac2ku9vL/f+WJGpRBNAojnAf3Q9vVmvXRYTbiVoNg0aJFixYtCngcc494lgNcmTc8f+Ff2vnixxUeotgvH8DTFPDrm38M/QyAiQIcPVVgF4kReOqBpgUiTy5gRzECTwMIxQAi303oy4axaMLKhmG+stbvtAHskA0PYK+pA0A23KbW/NU0fhCKD1Y23DvnSzYsp2DrnK/YcL82VWTIV2zIN4YKI0N+a8PEZiHarE35rQ0zi4XIlF/+z4zgbGjKzw+BbEPjAZjyV7B9fWWJ3IRu+en+9S3MRA8YNqE5H+oKgF0FbPhQVqCxYWpUASt+VF6MNVuyYRt+F1/F6UbLX2/KH5nogQEbnt5HfKkjIOCPsGHRdMlZuX6l4Aes2QHop+AOrc4z8D/Y8JlJfDjMwG9tmGoqcJLx8DMHv7UhdCvwQPwcdQAVX7oy6lRghfjJPPwBG14QP5uJH4TCBaoNfxD/gZYAQn7vuQBfIeC9PiU/CEUTKjaUGxCXn5bfViBh2l9Dfc6ajd9nw51oweNB+QAxv8+GvF6Cv57q8dR8yYZKQMGZLjol5weh2BOO2pTS86dtyYj5j2pTigIKl/y7sin9nBOS8k/C4ONzQkp+vQ9LywqMzgkJ+U8RCZRrzNickI5/a1b5pGrCJqAYnAI6/hlajb8yIuPLe1zlyki14Y23KyEVX83AygrgnFAoLh6Xy/nOSfkMVPXYkDfTdL/R8fmlw09LF3RseJMOPNPxryq9FLZhNQU3tBUvqPgF6JRiG1aJET5iS8P/1uJBZ0OclGYk/IH4F9mwygkPifz3goDPj9AvZMOsG9fH3JavaX21Aqw/rl89V5b8v0E8JN2cEM3X2ZKvb31Z3ZywG9eb8vmIWw+anLDzKUN+Pu7OxycbGvOTDEapmxNiG5ryRwttyTQ2nJtfnwuwDZ3yP9hwdv67CVFOKFXAAX/Qhg74ig1TVAEnfGxDkG3oht9vQ0f82oYoJ9w65dc2RDnh3iW/71zgjg8aG6Yu+bgCSV0Bl3ydDXOXfGzDKiecfuvOhq/Y0OhBJit+bcNJOSEpn+DWrSUfpuaE1PypOSE5XwkoplbAnj8tJ1T1a82flhN2dLJ/7i2vnp8blxPOJ+/PE9rYkET6nNDlAJbHeo++m1AM4OrpBQfmuQWaLZkv/tuGub8XTNj1hff3eon312sWLVq0aNF/o39WNiw0rpsKKgAAAABJRU5ErkJggg==');
                    }
                    if(message.list[currentProductIndex]['product_rating']==null){
                      message.list[currentProductIndex]['product_rating']=0;
                    }
                    if(message.list[currentProductIndex]['typical_price_range']==null){
                      message.list[currentProductIndex]['typical_price_range']=["Unknown", "Unknown"];
                    }
                    message.list[currentProductIndex]['product_rating']=message.list[currentProductIndex]['product_rating'].toDouble();
                    showModalBottomSheet(
                      context: context,
                      builder: (context) {
                        return Container(
                          height: MediaQuery.of(context).size.height * 0.8,
                          child:StatefulBuilder(
                          builder: (context, setState) {
                              return SingleChildScrollView(child: Wrap(
                                children: [
                                  Container(height:length*0.02,),
                                  Padding(
                                    padding: EdgeInsets.all(width*0.02), 
                                    // ignore: unnecessary_new
                                    child: new InkWell(
                                        child:RichText(
                                          text: TextSpan(
                                            children: [
                                              TextSpan(text: '${message.list[currentProductIndex]['product_title']}   ', style:TextStyle(color: Colors.black)),
                                              const WidgetSpan(
                                                child: Icon(Icons.link),                                              
                                              ),
                                            ],
                                          ),
                                        ),
                                        onTap: () => launchUrl(Uri.parse(message.list[currentProductIndex]['product_page_url']), mode:LaunchMode.externalApplication)
                                    ),         
                                  ),
                                  Container(height:length*0.02,),
                                  Container(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                          height: length*0.3,
                                          width: width * 0.7,
                                          decoration: BoxDecoration(
                                            image: DecorationImage(
                                                image: NetworkImage("${message.list[currentProductIndex]['product_photos'][currentPhotoIndex]}"),
                                                fit: BoxFit.fill),
                                          ),
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.arrow_forward),                  
                                          onPressed: () {
                                            setState(() {
                                              if (currentPhotoIndex < message.list[currentProductIndex]['product_photos'].length - 1) {
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
                                    child:Text("${currentPhotoIndex+1} of ${message.list[currentProductIndex]['product_photos'].length}", textAlign: TextAlign.center,)
                                  ),
                                  Container(height:length*0.02),
                                  Divider(
                                    color: Color.fromARGB(255, 190, 190, 190),
                                    height: 1,
                                    thickness: 1,
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(width*0.05),
                                    child:Row(
                                      children: [
                                        Container(
                                          width:width*0.17,
                                          child:Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "${message.list[currentProductIndex]['product_rating']}",
                                                style: TextStyle(
                                                  fontSize: 30,
                                                  fontWeight: FontWeight.w900
                                                ),
                                               ),
                                              Container(height:length*0.005),
                                              StarRating(
                                                rating: message.list[currentProductIndex]['product_rating'],
                                              ),
                                              Container(height:length*0.01),
                                              Container(
                                                width:width*0.15,
                                                child:FittedBox(
                                                fit: BoxFit.fitWidth,
                                                  child:Text("${message.list[currentProductIndex]['product_num_reviews']} ratings")
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          width:width*0.41
                                        ),
                                        Container(
                                          width:width*0.28,
                                          child:FittedBox(
                                            fit: BoxFit.fitWidth,
                                            child:Text(
                                              "${message.list[currentProductIndex]['typical_price_range'][0]} - ${message.list[currentProductIndex]['typical_price_range'][1]}",
                                              style: TextStyle(
                                                fontWeight: FontWeight.w900,
                                                fontSize: 20.0,
                                              ),
                                            )
                                          )
                                        )
                                      ],
                                    )
                                  ),
                                  Divider(
                                    color: Color.fromARGB(255, 190, 190, 190),
                                    height: 1,
                                    thickness: 1,
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(width*0.05),
                                    child:Container(
                                      child:SingleChildScrollView(
                                        child:Text('${message.list[currentProductIndex]['product_description']}')
                                      ),
                                    )
                                  ),
                                ],
                              )
                            );
                          },
                        )
                        );
                      },
                    ).then((value) {
                      // Function to run when the modal is exited
                      currentPhotoIndex=0;
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
  await Firebase.initializeApp();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((value) => runApp(MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Readerly',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(user:"rishit.agrawal121@gmail.com")
    );
  }
}

class RoutineCard extends StatelessWidget {
  final Map routineName;
  final List ExerciseList;
  String getGifUrlForExercise(String exerciseName) {
    try {
      print(ExerciseList);
      print(exerciseName);
      var exerciseData = ExerciseList.firstWhere((data) => data['name'] == exerciseName);
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
              SizedBox(height:20),
              Center(
                child: Image.network(
                  '${getGifUrlForExercise(routineName['name'])}', // Replace with your actual image URL
                  height: MediaQuery. of(context). size. height*0.3,
                  width: MediaQuery. of(context). size. height*0.3,
                ),
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
  var bob="NO";
  var temp;
  List _searchResult = []; 
  void initState() {
    super.initState();
    _dataFuture = fetchExercises();
    _dataFuture.then((items) {
      setState(() {
        _searchResult = List.from(items); // Create a new list with the same contents as items
      });
    });
  }

  List<Map> selectedExercises = [];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Exercises'),
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
              temp=_searchResult[index];
              items!.remove(_searchResult[index]);
              items.insert(0,temp);
              _searchResult.removeAt(index);
              _searchResult.insert(0,temp);
            }

            void _filterSearchResults(String query) {
              if (query.isNotEmpty) {
                var tempList = [];
                items!.forEach((item) {
                  if (item['name'].toLowerCase().contains(query.toLowerCase()) || item['target'].toLowerCase().contains(query.toLowerCase()) || item['bodyPart'].toLowerCase().contains(query.toLowerCase()) || item['equipment'].toLowerCase().contains(query.toLowerCase())) {
                    tempList.add(item);
                  }
                });
                setState(() {
                  _searchResult = tempList.toList(); // Create a new list instance with filtered items
                  bob="YEA";
                });
              } else {
                setState(() {
                  _searchResult = items!.toList();
                });
              }
            }
            return SingleChildScrollView(
              child:Column(
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
                    Stack(
                      children:[
                            Container(
                              height:MediaQuery. of(context). size. height*0.75,
                              child: ListView.builder(
                                itemCount: _searchResult.length,
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        // Toggle exercise selection
                                        if (selectedExercises.contains(_searchResult[index])) {
                                          selectedExercises.remove(_searchResult[index]);
                                        } else {
                                          selectedExercises.add(_searchResult[index]);
                                        }
                                        _sortExercises(index);
                                      });
                                    },
                                    child:Card(
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
                                            ListTile(
                                              title:Text(
                                                _searchResult[index]['name'],
                                                style: TextStyle(
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              trailing: selectedExercises.contains(_searchResult[index])
                                                ? Icon(Icons.check, color: Colors.green)
                                                : Icon(Icons.add, color:Colors.blue,),
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
                                            SizedBox(height:20),
                                            Center(
                                              child: Image.network(
                                                '${_searchResult[index]['gifUrl']}', // Replace with your actual image URL
                                                height: MediaQuery. of(context). size. height*0.3,
                                                width: MediaQuery. of(context). size. height*0.3,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  );
                                },
                              ),
                            ),
                            Positioned(
                              bottom: 16.0,
                              right: 16.0,
                              child:FloatingActionButton(
                                onPressed: () {
                                  // Save selected exercises and navigate back to the previous page
                                  Navigator.pop(context, selectedExercises);
                                },
                                child: Icon(Icons.check),
                              ),
                            ),
                          ]
                  )
                ],
              )
            );
          }
        }
      )
    );
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
var bob="NO";
List _searchResult = []; 
void initState() {
  super.initState();
  _dataFuture = fetchExercises();
  _dataFuture.then((items) {
    setState(() {
      _searchResult = List.from(items); // Create a new list with the same contents as items
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
                  if (item['name'].toLowerCase().contains(query.toLowerCase()) || item['target'].toLowerCase().contains(query.toLowerCase()) || item['bodyPart'].toLowerCase().contains(query.toLowerCase()) || item['equipment'].toLowerCase().contains(query.toLowerCase())) {
                    tempList.add(item);
                  }
                });
                setState(() {
                  _searchResult = tempList.toList(); // Create a new list instance with filtered items
                  bob="YEA";
                });

              } else {
                setState(() {
                  _searchResult = items!.toList();
                });
              }
            }
            return Column(
              children: [
                Container(height:MediaQuery. of(context). size. height*0.1),
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
                              SizedBox(height:20),
                               Center(
                                child: Image.network(
                                  '${_searchResult[index]['gifUrl']}', // Replace with your actual image URL
                                  height: MediaQuery. of(context). size. height*0.3,
                                  width: MediaQuery. of(context). size. height*0.3,
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
        }
      )
    );
  }
}



class Planner extends StatefulWidget{
  const Planner({
    super.key,
    required this.user
  });
  final user;
  @override
  _PlannerState createState()=> _PlannerState(user:user);
}
class _PlannerState extends State<Planner>{
  _PlannerState({required this.user}) : super();
  var _calendarController=DateRangePickerController();
  final String user;
  var data;
  var now = DateTime.now();
  var value = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day).toString().replaceAll(' 00:00:00.000', '');
  late List workoutRoutines;
  CollectionReference login = FirebaseFirestore.instance.collection('audios');
  void initState(){
    super.initState();
  }
  Future<List> futureData() async {
    // Simulate fetching data from a source (e.g., Firestore)
    return [await login.doc(user).get(), await fetchExercises()];
  }


  Widget build(BuildContext context){
    return FutureBuilder(
      
      future: futureData(),
      builder:
      (context,snapshot) {
        if (snapshot.hasError) {
          return Text("Something went wrong");
        }
        if (snapshot.connectionState == ConnectionState.done) {
          final List? items= snapshot.data;
          var exerciseItems=items![1];
          print("ITEMS"+"$items");
          data = (items![0] as DocumentSnapshot).data() as Map;
          if (data['planner'] != null && data['planner'].containsKey(value)) {
            workoutRoutines=data['planner'][value];
          }else{
            workoutRoutines=[];
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
                setState((){
                  workoutRoutines.addAll(selectedExercises);
                  data['planner'][value]=workoutRoutines;
                });
                await login.doc(user).update({
                  'planner': data['planner']
                });
            }
          }     
          return Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child:Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(height:MediaQuery.of(context).size.height*0.05),
                    Text(
                      'Your Fitness Planner',
                      style: TextStyle(
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
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.38,
                      padding: EdgeInsets.all(16),
                      child: SfDateRangePicker(
                        initialSelectedDate:DateTime(now.year, now.month, now.day),
                        controller: _calendarController,
                        selectionMode: DateRangePickerSelectionMode.single, // Add this line
                        onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
                          setState(() {
                            if (args.value is DateTime) {
                              print(value);
                              value = (args.value).toString();
                              value = value.replaceAll(' 00:00:00.000', '');
                            }
                          });
                        },
                      ),
                    ),
                    Row(
                      children:[
                        Text(
                          'My Routines',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(width:MediaQuery.of(context).size.width*0.42),
                        FloatingActionButton(
                          elevation:0.0,
                          backgroundColor:Colors.white,
                          onPressed: () {
                            _navigateToAddExercisePage();
                          },
                          child: Icon(Icons.add,color:Colors.blue),
                        ),
                      ]
                    ),
                    Stack(
                    children:[
                      SizedBox(
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: workoutRoutines.length,
                          itemBuilder: (context, index) {
                            var routine = workoutRoutines[index];
                            return Stack(
                              children:[
                                RoutineCard(routineName: routine, ExerciseList:exerciseItems),
                                Positioned(
                                  top:25,
                                  right:25,
                                  child: GestureDetector(
                                    onTap: () {
                                      // Handle the click event here
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text('Confirm Deletion'),
                                            content: Text('Are you sure you want to delete this item?'),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: Text('Cancel'),
                                              ),
                                              TextButton(
                                                onPressed: () async{
                                                  // Close the dialog without performing any action
                                                  Navigator.of(context).pop();
                                                  setState((){
                                                    workoutRoutines.removeAt(index);
                                                    data['planner'][value]=workoutRoutines;
                                                  });
                                                  await login.doc(user).update({
                                                    'planner': data['planner']
                                                  });
                                                },
                                                child: Text('Yes'),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                    child:Icon(Icons.delete, color:Colors.red)
                                  )
                                ),
                              ]
                            );
                            },
                          ),
                        ),
                      ]
                    )
                  ],
                ),
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed:(){
                showDialog(
                  context: context,
                  builder: (BuildContext context) =>ChatDialog()
                );
              },
              child: Icon(Icons.chat),
            )
          );
        }
        return Center(
          child: CircularProgressIndicator(),
        );
      }
    );
  }
}










class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
    required this.user,
  });
  final user;
  _MyHomePageState createState() => _MyHomePageState(user:user);
}

class _MyHomePageState extends State<MyHomePage> {
  _MyHomePageState({required this.user}) : super();
  final user;
  int _selectedIndex = 0;
  final List<Widget> _widgetOptions = [
    ChatScreen(),
    Planner(user:"rishit.agrawal121@gmail.com"),
    SearchBarPage(),
    ChatScreen()
  ];

  void _onItemTapped(int index) async{
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        selectedLabelStyle: TextStyle(color:Colors.black),
        unselectedLabelStyle: TextStyle(color:Colors.blue),
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.blue,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center,),
            label: 'Fitness Planner',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_gymnastics,),
            label: 'Exercises',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person,),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}