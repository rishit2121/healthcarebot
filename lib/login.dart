import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'main.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_animated_button/flutter_animated_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:firebase_core/firebase_core.dart';


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
      body: SingleChildScrollView(
        child: Column(
          children:[ 
            Container(height:MediaQuery.of(context).size.height*0.05),
            Padding(
              padding: EdgeInsets.all(15),
              child: new LinearPercentIndicator(
                backgroundColor:Colors.white,
                barRadius:Radius.circular(20),
                width: MediaQuery.of(context).size.width -90,
                animation: true,
                lineHeight: MediaQuery.of(context).size.height*0.04,
                animationDuration: 2000,
                percent: questionIndex/questions.length,
                leading:Text("${(questionIndex/questions.length)*100}%", style:TextStyle(fontWeight:FontWeight.bold)),
                // center: Text("${questionIndex/questions.length}%"),
                linearStrokeCap: LinearStrokeCap.roundAll,
                progressColor: Color.fromARGB(255, 24, 34, 145),
              ),
            ),
            Container(height:MediaQuery.of(context).size.height*0.15),
            Card(
            elevation: 8.0,
            shadowColor:Color.fromARGB(255, 1, 37, 87),
            shape: RoundedRectangleBorder(
              side: new BorderSide(color: Color.fromARGB(255, 1, 37, 87), width: 2.0),
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
                              backgroundColor: Colors.transparent,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 15.0),
                              side: BorderSide(color: Color.fromARGB(255, 24, 34, 145), width: 2.0),
                              textStyle: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 24, 34, 145),
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
                                backgroundColor: Colors.green,
                              ),
                              child: Text('Yes'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                questionnaire.responses.add(false);
                                _navigateToNextQuestion(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              child: Text('No'),
                            ),
                          ],
                        ),
                ],
              ),
            ),
          ),
          Container(height:MediaQuery.of(context).size.height*0.05),
          Container(width:MediaQuery.of(context).size.width*0.8, child:Text("Feel free to skip any of the following questions if you prefer not to answer. Your responses help better your experience, and maintain accuracy. Your input is valuable to us.", style:TextStyle(), textAlign: TextAlign.center,))
          ],
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
          fullscreenDialog: true
        ),
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => CongratulationsPage(myControllerEmail:myControllerEmail, questionnaire:questionnaire, ),fullscreenDialog: true
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
      backgroundColor: Color.fromARGB(255, 1, 8, 84), // Background color
      body: Column(
        children:[
          Container(height:MediaQuery.of(context).size.height*0.05,),
          Image.asset(
              'assets/images/award-gif-unscreen.gif'),
          Container(height:MediaQuery.of(context).size.height*0.05,),
          Text("Congratulations!", style:TextStyle(color:Colors.white, fontWeight:FontWeight.bold, fontSize:40)),
          Container(height:MediaQuery.of(context).size.height*0.03,),
          Container(
            width:MediaQuery.of(context).size.width*0.8,
            child:Text("You are officially done setting up your\n account. You may now navigate to the\n home screen. We hope you enjoy!", textAlign: TextAlign.center, style:TextStyle(color:Colors.grey, fontSize:17))
          ),
          Container(
            height:MediaQuery.of(context).size.height*0.07,
          ),
          Container(
          width:MediaQuery.of(context).size.width*0.6,
          height:MediaQuery.of(context).size.height*0.06,
           child:ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.0),
              ),
              backgroundColor: Color.fromARGB(255, 111, 228, 243), // Button color
            ),
            onPressed: () async {
              final List<Widget> _widgetOptions = [
                HomePage(user:"${myControllerEmail.text}"),
                ChallengeScreen(user:"${myControllerEmail.text}"),
                Planner(user:"${myControllerEmail.text}"),
                JournalPage(user:"${myControllerEmail.text}"),
                // PostPage(currentUser:"${myControllerEmail.text}"),
                // ProfilePage(user:"${myControllerEmail.text}"),
              ];
              print(myControllerEmail);
              await FirebaseFirestore.instance.collection('audios').doc("${myControllerEmail.text}").update({
                'Information': questionnaire.responses,
              });
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context)=>MyHomePage(widgets:_widgetOptions, selectedIndex:0), fullscreenDialog: true),
              );
            },
            child: Text('Continue', style:TextStyle(fontWeight:FontWeight.bold, fontSize:17)),
          ),
          ),
        ]
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
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    )..repeat(reverse: true);

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    // Check if the widget is still mounted before performing navigation
    if (mounted) {
      Timer(Duration(seconds: 2), () {
        if (mounted) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()),);
        }
      });
    }
  }

  void dispose() {
    _controller.dispose(); // Dispose the animation controller
    super.dispose();
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
            return Container(width:MediaQuery.of(context).size.width*1, child:Padding(padding: EdgeInsets.only(left: MediaQuery.of(context).size.width*0.1 ),child:Text("HELLO", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 50, fontFamily: 'Helvetica',letterSpacing: 2.0,color:Color.fromARGB(255, 0, 46, 111)),)));
          }  
          Widget buildsubTitle(BuildContext context) {
            return Container(width:MediaQuery.of(context).size.width*1, child:Padding(padding: EdgeInsets.only(left: MediaQuery.of(context).size.width*0.1 ),child:Text("Welcome to Careva", style: TextStyle(fontWeight: FontWeight.w300, fontSize: 25,color:Color.fromARGB(255, 1, 37, 87)),)));
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
                height:MediaQuery.of(context).size.height*x,
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
              child:Stack(
                children:[
                  TextField(
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
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: TextButton(
                      onPressed: () {
                        // Handle button tap
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ForgotPasswordPage(),
                          ),
                        );
                      },
                      child: Text(
                        'Forgot?',
                        style: TextStyle(
                          fontSize: 15.0,
                          color: Color.fromARGB(255, 23, 87, 177), // Change text color as needed
                        ),
                      ),
                    ),           
                  ),
                ]
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
              height: MediaQuery.of(context).size.height*0.15,
              width: MediaQuery.of(context).size.width*0.9,
              isReverse: true,
              selectedTextColor: Colors.black,
              transitionType: TransitionType.LEFT_TO_RIGHT,
              backgroundColor: Color.fromARGB(255, 23, 87, 177),
              borderColor: Colors.white,
              borderRadius: 10,
              borderWidth: 2,
              text:"${title}",
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
                        HomePage(user:"${myControllerEmail.text}"),
                        ChallengeScreen(user:'${myControllerEmail.text}'),
                        Planner(user:"${myControllerEmail.text}"),
                        JournalPage(user:"${myControllerEmail.text}")
                        // PostPage(currentUser:"${myControllerEmail.text}"),
                        // ProfilePage(user:"${myControllerEmail.text}"),
                      ];
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context)=>MyHomePage(widgets:_widgetOptions, selectedIndex:0), fullscreenDialog: true),
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
                              {'User':myController.text, 'Credits':12, 'planner':{}, 'journal':[], 'activity':[]},
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
                              ),fullscreenDialog: true),
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
              padding(context, 0.15),
              buildTitle(context),
              padding(context, 0.01),
              buildsubTitle(context),
              padding(context, 0.015),
              buildMessage(context),
              padding(context, 0.05),
              buildUsername(context, 0.1),
              padding(context, 0.03),
              buildEmail(context),
              padding(context, 0.05),
              buildPassword(context),
              padding(context, 0.07),
              buildEnter(context),  //0.03
              padding(context,0.097), 
              buildSwitch(context),  //0.03  


              ])));
        }
        return CoolLoadingIndicator();

      },
    );
  }
}

class ForgotPasswordPage extends StatelessWidget {
  final myControllerEmail=TextEditingController();
  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: MediaQuery.of(context).size.height*0.06,
        elevation:0.0,
        leading:IconButton(icon:Icon(Icons.arrow_back_ios_new_sharp, color:Colors.black, ), onPressed:(){Navigator.pop(context);}),
        shadowColor: Colors.white,
        automaticallyImplyLeading: true,
        title: Text(''),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(child:Column(
          children: [
            Image.asset(
              'assets/images/Screenshot 2024-02-16 at 9.58.04 PM.png'),
            Container(height:MediaQuery.of(context).size.height*0.1),
            Text(
              'Forgot Password?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 25.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(height:MediaQuery.of(context).size.height*0.02),
            Text(
              'Please enter your email address to recieve a link\n to reset your password.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15.0,
                
              ),
            ),
            Container(height:MediaQuery.of(context).size.height*0.08),
            Container(
              width:MediaQuery.of(context).size.width*0.85,
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
            ),
            ),
            Container(
              height:MediaQuery.of(context).size.height*0.08,
            ),
            Container(
              width:MediaQuery.of(context).size.width*0.85,
              height:MediaQuery.of(context).size.height*0.06,
              child: 
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:Color.fromARGB(255, 23, 87, 177)
                ),
                onPressed: () async {
                  print("${myControllerEmail}");
                  // Implement forgot password functionality
                   await FirebaseAuth.instance
                    .sendPasswordResetEmail(email: myControllerEmail.text);
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Verification'),
                          content: Text('An email to reset your password has been sent. Please login again after changing your password.'),
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
                },
                child: Text('Send Email', style:TextStyle(fontSize:20)),
              ),
            )
          ],
        ),
        )
      ),
    );
  }
}

