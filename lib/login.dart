import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'main.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_animated_button/flutter_animated_button.dart';
import 'package:shared_preferences/shared_preferences.dart';


class QuestionPageTemplate extends StatelessWidget {
  final String question;
  final questionIndex;
  var questions;
  var questionnaire;
  var myControllerEmail;
  final AnswerController = TextEditingController();
  QuestionPageTemplate({
    required this.myControllerEmail,
    required this.question,
    required this.questionIndex,
    required this.questions,
    required this.questionnaire,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[100],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Health Question'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 8.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    question,
                    style: TextStyle(fontSize: 20.0),
                  ),
                  SizedBox(height: 24.0),
                  questions[questionIndex]['answerValue'] == true
                      ? Column(children: [
                          TextFormField(
                            // Customize the text field as needed
                            controller:AnswerController,
                            decoration: InputDecoration(labelText: 'Your Answer'),
                          ),
                          Container(height:MediaQuery.of(context).size.height*0.07),
                          ElevatedButton(
                            onPressed: () {
                               questionnaire.responses.add({'question':question, "answer":AnswerController.text});
                               print(questionnaire.responses);
                              _navigateToNextQuestion(context);
                            },
                            style: ElevatedButton.styleFrom(
                              primary: Colors.transparent,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 15.0),
                              side: BorderSide(color: Colors.blue, width: 2.0),
                              textStyle: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                            child: Container(
                              width: 150.0,
                              alignment: Alignment.center,
                              child: Text('Continue', style:TextStyle(color:Colors.black)),
                            ),
                          ),
                        ]
                      )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                questionnaire.responses.add({});
                                _navigateToNextQuestion(context);
                              },
                              style: ElevatedButton.styleFrom(
                                primary: Colors.green,
                              ),
                              child: Text('Yes'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                questionnaire.responses.add(false);
                                _navigateToNextQuestion(context);
                              },
                              style: ElevatedButton.styleFrom(
                                primary: Colors.red,
                              ),
                              child: Text('No'),
                            ),
                          ],
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToNextQuestion(BuildContext context) {
    if (questionIndex < questions.length - 1) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => QuestionPageTemplate(
            question: questions[questionIndex + 1]['question'],
            questionIndex: questionIndex + 1,
            questionnaire: questionnaire,
            questions: questions,
            myControllerEmail: myControllerEmail,
          ),
        ),
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => CongratulationsPage(myControllerEmail:myControllerEmail, questionnaire:questionnaire),
        ),
      );
    }
  }
}


class CongratulationsPage extends StatelessWidget {
  var myControllerEmail;
  var questionnaire;
  CongratulationsPage({required this.myControllerEmail, required this.questionnaire});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[100], // Background color
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Congratulations'),
        backgroundColor: Colors.green, // App bar color
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 8.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Congratulations!',
                    style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    'You have successfully completed the questionnaire.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18.0,),
                  ),
                  SizedBox(height: 24.0),
                  ElevatedButton(
                    onPressed: () async {
                      final List<Widget> _widgetOptions = [
                        ChatScreen(user:"${myControllerEmail.text}"),
                        Planner(user:"${myControllerEmail.text}"),
                        PostPage(currentUser:"${myControllerEmail.text}"),
                        NewsPage(),
                        ProfilePage(user:"${myControllerEmail.text}"),
                      ];
                      print(myControllerEmail);
                      await FirebaseFirestore.instance.collection('audios').doc("${myControllerEmail.text}").update({
                        'Information': questionnaire.responses,
                      });
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context)=>MyHomePage(widgets:_widgetOptions)),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.blue, // Button color
                    ),
                    child: Text('Continue'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CoolLoadingIndicator extends StatefulWidget {
  @override
  _CoolLoadingIndicatorState createState() => _CoolLoadingIndicatorState();
}

class _CoolLoadingIndicatorState extends State<CoolLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    Timer(Duration(seconds: 2), () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage())));
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    )..repeat(reverse: true);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _animation,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
        ),
        child: Center(
          child: Icon(
            Icons.medical_services,
            color: Colors.red,
            size: MediaQuery.of(context).size.width*0.3,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
class HealthQuestionnaire {
  List responses = [];
}
class LoginPage extends StatefulWidget{
  static var user1=_LoginPageState.user1;
  static var pwd= _LoginPageState.pwd;
  _LoginPageState createState() => _LoginPageState();
}
class _LoginPageState extends State<LoginPage> {
  var _timer;
  String title="Sign In";
  String other_title="Sign Up";
  String hint_txt="Dont have a account?";
  String other_hint_txt="Already have a account?";
  String msg="";
  static var user1="";
  static var pwd="";
  final myController=TextEditingController();
  final myControllerEmail=TextEditingController();
  final myControllerPwd=TextEditingController();
  final List<Map<String, dynamic>> questions = [
    {
      'question': 'Do you have any allergies?',
      'answerValue': true,
    },
    {
      'question': 'How Old Are You??',
      'answerValue': true,
    },
    {
      'question': 'What gender are you?',
      'answerValue': true,
    },
    {
      'question': 'Do you smoke?',
      'answerValue': true,
    },
    {
      'question': 'Do you drink alcohol?',
      'answerValue': true,
    },
    {
      'question': 'Have you been diagnosed with any chronic medical conditions (e.g., diabetes, hypertension)?',
      'answerValue': true,
    },
    {
      'question': 'Are you currently taking any medications?',
      'answerValue': true,
    },
    {
      'question': 'Is there anything else you would like us to know about you?',
      'answerValue': true,
    },
    // Add more questions here
  ];

  var acs = ActionCodeSettings(
    // URL you want to redirect back to. The domain (www.example.com) for this
    // URL must be whitelisted in the Firebase Console.
    url: 'https://www.example.com/finishSignUp?cartId=1234',
    // This must be true
    handleCodeInApp: true,
    iOSBundleId: 'com.example.ios',
    androidPackageName: 'com.example.android',
    // installIfNotAvailable
    androidInstallApp: true,
    // minimumVersion
    androidMinimumVersion: '12');
  @override 
  void initState(){
    super.initState();
  }
  Widget build(BuildContext context){
    CollectionReference login = FirebaseFirestore.instance.collection('audios');

    return FutureBuilder<DocumentSnapshot>(
      
      future: login.doc('login').get(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {

        if (snapshot.hasError) {
          return Text("Something went wrong");
        }

        if (snapshot.hasData && !snapshot.data!.exists) {
          return Text("Document does not exist", textDirection: TextDirection.ltr,);
        }

        if (snapshot.connectionState == ConnectionState.done) {          
             
          Widget buildMessage(BuildContext context) {
            return Text("${(msg)}");
          }  
          Widget buildTitle(BuildContext context) {
            return Container(width:MediaQuery.of(context).size.width*1, child:Padding(padding: EdgeInsets.only(left: MediaQuery.of(context).size.width*0.1 ),child:Text("$title", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 30),)));
          }  
          Widget buildEmail(BuildContext context){
            return Container(
              width:MediaQuery.of(context).size.width*0.9,
              child:TextField(
              keyboardType: TextInputType.emailAddress,
                      style: new TextStyle(
                        fontFamily: "Poppins",),
              decoration: new InputDecoration(
                labelText: "Enter Email",
                fillColor: Colors.white,
                border: new OutlineInputBorder(
                  borderRadius: new BorderRadius.circular(10.0),
                  borderSide: new BorderSide(
                ),
              ),
                        //fillColor: Colors.green
              ),
              controller:myControllerEmail,
            )
            );
          }
          Widget buildUsername(BuildContext context,x){
            if(title=='Sign Up'){
              return Container(
                width:MediaQuery.of(context).size.width*0.9,
                child:TextField(
                keyboardType: TextInputType.emailAddress,
                        style: new TextStyle(
                          fontFamily: "Poppins",),
                decoration: new InputDecoration(
                  labelText: "Enter Username",
                  fillColor: Colors.white,
                  border: new OutlineInputBorder(
                    borderRadius: new BorderRadius.circular(10.0),
                    borderSide: new BorderSide(
                  ),
                ),
                          //fillColor: Colors.green
                ),
                controller:myController,
              )
              );
            }
            else{
              return Container(height:MediaQuery.of(context).size.height*x);
            }
          }
          Widget buildPassword(BuildContext context){
            return Container(
              width:MediaQuery.of(context).size.width*0.9,
              child:TextField(
              keyboardType: TextInputType.emailAddress,
                      style: new TextStyle(
                        fontFamily: "Poppins",),
              decoration: new InputDecoration(
                labelText: "Enter Password",
                fillColor: Colors.white,
                border: new OutlineInputBorder(
                  borderRadius: new BorderRadius.circular(10.0),
                  borderSide: new BorderSide(
                ),
              ),
                        //fillColor: Colors.green
              ),
              obscureText: true,
              controller:myControllerPwd,
            )
            );
          }
          Widget padding(BuildContext context, x){
            return Container(height:MediaQuery.of(context).size.height*x);
          }
          Widget buildSwitch(BuildContext context){
            return Row(children: <Widget>[
              Container(width:MediaQuery.of(context).size.width*0.02),
              Container(child:Text("$hint_txt")),
              Container(
              child:TextButton(
                child: Container(child:Text("${(other_title)}",
                textAlign: TextAlign.left,
                style:TextStyle(color:Colors.blue)),
                ),
                onPressed:() {
                  if(title=='Sign Up'){
                    try {_timer.cancel();}catch(e){print(e);}
                  }
                  setState(() {
                    String temp=other_title;
                    other_title=title;
                    title=temp;
                    msg="";
                    myController.text="";
                    myControllerPwd.text="";
                    String hint_temp=hint_txt;
                    hint_txt=other_hint_txt;
                    other_hint_txt=hint_temp;
                  });
                },
              ),
              height: MediaQuery.of(context).size.height*0.07,
            ),
            ],
            );
          }
          Widget buildEnter(BuildContext context){
            return Container(child:AnimatedButton(
              height: 70,
              width: MediaQuery.of(context).size.width*0.6,
              isReverse: true,
              selectedTextColor: Colors.black,
              transitionType: TransitionType.LEFT_TO_RIGHT,
              backgroundColor: Colors.black,
              borderColor: Colors.white,
              borderRadius: 50,
              borderWidth: 2,
              text:"Enter",
              onPress:() async {
                if(title=="Sign In"){
                  try {
                    await FirebaseAuth.instance.signInWithEmailAndPassword(
                      email: myControllerEmail.text,
                      password: myControllerPwd.text
                    );
                    await FirebaseAuth.instance.currentUser?.reload();
                    final user = FirebaseAuth.instance.currentUser;
                    print(user?.emailVerified);
                    if (user?.emailVerified==true) {
                      print('yay');
                      SharedPreferences pref =await SharedPreferences.getInstance();
                      pref.setString("email", "${myControllerEmail.text}");
                      final List<Widget> _widgetOptions = [
                        ChatScreen(user:'${myControllerEmail.text}'),
                        Planner(user:"${myControllerEmail.text}"),
                        PostPage(currentUser:"${myControllerEmail.text}"),
                        NewsPage(),
                        ProfilePage(user:"${myControllerEmail.text}"),
                      ];
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context)=>MyHomePage(widgets:_widgetOptions)),
                        );
                        setState(() {
                          msg="";
                          user1=myController.text;
                          pwd=myControllerPwd.text; 
                        });
                            
                    }else{
                      print("Yea they aint verified");
                      setState((){
                        msg="Your Email Is not verified yet.";
                      });
                    }
                  } on FirebaseAuthException catch (e) {
                      if (e.code == 'weak-password') {
                        setState((){
                          msg='The password provided is too weak.';
                        });
                      } else if (e.code == 'email-already-in-use') {
                        setState((){
                          msg='The account already exists for that email.';
                        });
                      }else{
                        setState(() {
                          msg=e.code;
                        });
                      }
                    } catch (e) {
                      setState((){
                          print(e);
                      });
                  }    
                }
                if(title=="Sign Up"){
                    try {
                      final FirebaseAuth _auth = FirebaseAuth.instance;
                      final credential = await _auth.createUserWithEmailAndPassword(
                        email: myControllerEmail.text,
                        password: myControllerPwd.text,
                      );
                      await credential.user!.sendEmailVerification();
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            scrollable: true,
                            title: const Text("Verification"),
                             content: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child:Text("A verification email was sent to your account. Please verify and you can log in.")
                             )
                          );
                        }
                      );
                      _timer = Timer.periodic(const Duration(seconds: 3), (timer) async {
                        if(DateTime.now().hour ==24){ //Stop if  hour equal to 24
                          timer.cancel();
                        }
                        await FirebaseAuth.instance.currentUser?.reload();
                        final user = FirebaseAuth.instance.currentUser;
                        print(user?.emailVerified);
                          if (user?.emailVerified==true) {
                            print('yay');
                            login.doc("${myControllerEmail.text}").set(
                              {'User':myController.text, 'Credits':5, 'planner':{}},
                              SetOptions(merge:true),
                            );
                            SharedPreferences pref =await SharedPreferences.getInstance();
                            pref.setString("email", "${myControllerEmail.text}");
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context)=>QuestionPageTemplate(
                                myControllerEmail:myControllerEmail,
                                question: questions[0]['question'],
                                questionIndex: 0,
                                questionnaire: HealthQuestionnaire(),
                                questions:questions
                              ),),
                            );
                            setState(() {
                              msg="";
                              user1=myController.text;
                              pwd=myControllerPwd.text; 
                            });
                            timer.cancel();
                          }
                          else{
                            print('not yet');
                          }
                        });
                    } on FirebaseAuthException catch (e) {
                      if (e.code == 'weak-password') {
                        setState((){
                          msg='The password provided is too weak.';
                        });
                      } else if (e.code == 'email-already-in-use') {
                        setState((){
                          msg='The account already exists for that email.';
                        });
                      }else{
                        setState((){
                          msg=e.code;
                        });
                      }
                    } catch (e) {
                      print(e);
                    }
                }
                

              },
            ),
            height:MediaQuery.of(context).size.height*0.07,
            
            );
          }    
            
          return Scaffold(
            body: 
            SingleChildScrollView(child:Column(
              children:[
              padding(context, 0.2),
              buildTitle(context),
              buildMessage(context),
              padding(context, 0.05),
              buildUsername(context, 0.05),
              padding(context, 0.05),
              buildEmail(context),
              padding(context, 0.05),
              buildPassword(context),
              padding(context, 0.05),
              buildEnter(context),  //0.03
              padding(context,0.16), 
              buildSwitch(context),  //0.03  


              ])));
        }
        return CoolLoadingIndicator();

      },
    );
  }
}

