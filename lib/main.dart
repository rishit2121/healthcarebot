import 'package:flutter/material.dart';
import 'resources/chat.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:rating_bar/rating_bar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'login.dart';

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
  final Offset appBarOffset = appBarRenderBox.localToGlobal(Offset.zero);

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

class CustomAppBar extends StatelessWidget with PreferredSizeWidget {
  final String title;
  final Function() onProfilePressed;

  CustomAppBar({required this.title, required this.onProfilePressed});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.blue,
      leading: IconButton(
        icon: Icon(Icons.menu, color: Colors.white),
        onPressed: () {
          // Handle menu icon press here
        },
      ),
      title: Text(
        title,
        style: TextStyle(color: Colors.white),
      ),
      actions: [
        Stack(
            alignment: Alignment.topRight,
            children: [
              IconButton(
                icon: Icon(Icons.person, color: Colors.white),
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
  List<Message> messages = [
    Message(sender: 'Bot', text: 'Hello, my name is Sam, and I am your healthcare assistant. How may I help you today?', list:[]),
  ];
  var chat_history='\nSam: Hello, my name is Sam, and I am your healthcare assistant. How may I help you today? <END_OF_TURN>';
  var chat_history2=[{"role": "assistant", "content": "Hello, my name is Sam, and I am your healthcare assistant. How may I help you today?"},];
  TextEditingController _textEditingController = TextEditingController();
  List<Doctor> doctors = [
    Doctor(name: 'Dr. John Doe', specialty: 'Cardiology'),
    Doctor(name: 'Dr. Jane Smith', specialty: 'Dermatology'),
    Doctor(name: 'Dr. Mark Johnson', specialty: 'Pediatrics'),
    Doctor(name: 'Dr. Sarah Brown', specialty: 'Orthopedics'),
  ];
  var _scrollController = ScrollController();
  int currentDoctorIndex = 0;
  int currentProductIndex = 0;
  var currentPhotoIndex=0;

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
        _simulateBotResponse();
      });
    }
  }
  Future<void> _simulateBotResponse() async{
    // Simulating a delayed bot response
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
        Message doctorMessage = Message(sender: 'Doctor', text: "Heres a few doctors  you can visit:", list:response[1]);
        Message productMessage = Message(sender: 'Shopper', text: "Heres a few items  you can buy:", list:response[3]);
        messages.add(doctorMessage);
        messages.add(productMessage);
      }
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
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              controller:_scrollController,
              reverse: false, // Show the latest message at the bottom
              itemCount: messages.length,
              itemBuilder: (BuildContext context, int index) {
                final message = messages[index];
                if (message.sender == 'You') {
                  return _buildMessageBubble(message);
                } else if (message.sender == 'Bot') {
                  return _buildBotMessageBubble(message);
                } else if (message.sender == 'Doctor') {
                  return _buildDoctorListMessage(message);
                } else {
                  return _buildProductListMessage(message);
                }
              },
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _textEditingController,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      contentPadding: EdgeInsets.all(12.0),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
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
              color: Colors.lightBlueAccent,
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
              color: Colors.grey[300],
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

  Widget _buildDoctorListMessage(Message message) {
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
              color: Colors.grey[300],
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
                      doctors[currentDoctorIndex].name,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: Icon(Icons.arrow_forward),
                      onPressed: () {
                        setState(() {
                          if (currentDoctorIndex < doctors.length - 1) {
                            currentDoctorIndex++;
                          }
                        });
                      },
                    ),
                  ],
                ),
                SizedBox(height: 8.0),
                Text(
                  'Specialty: ${doctors[currentDoctorIndex].specialty}',
                  style: TextStyle(fontSize: 16.0),
                ),
              ],
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
              color: Colors.grey[300],
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
                    primary: Colors.grey[400], // Match the container background color
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
class Doctor {
  final String name;
  final String specialty;

  Doctor({required this.name, required this.specialty});
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
      home: LoginPage()
    );
  }
}


class ChatApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        accentColor: Colors.amber,
        textTheme: TextTheme(
          bodyText1: TextStyle(
            fontSize: 16.0,
            color: Colors.black,
          ),
         
          headline6: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        appBarTheme: AppBarTheme(
          color: Colors.blue,
          textTheme: TextTheme(
            headline6: TextStyle(
              fontSize: 22.0,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
      home: ChatScreen(),
    );
  }
}

