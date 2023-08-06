import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'main.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:loader_overlay/loader_overlay.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'main.dart';
import 'package:flutter_animated_button/flutter_animated_button.dart';

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

class LoginPage extends StatefulWidget{
  @override 
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
  final _formKey = GlobalKey<FormState>();
  final myController=TextEditingController();
  final myControllerEmail=TextEditingController();
  final myControllerPwd=TextEditingController();
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
          Map data = snapshot.data!.data() as Map;
          
          
          
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
                    final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
                      email: myControllerEmail.text,
                      password: myControllerPwd.text
                    );
                    await FirebaseAuth.instance.currentUser?.reload();
                    final user = FirebaseAuth.instance.currentUser;
                    print(user?.emailVerified);
                    if (user?.emailVerified==true) {
                      print('yay');
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context)=>MyHomePage(user:myControllerEmail)),
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
                              {'User':myController.text},
                              SetOptions(merge:true),
                            );
                            Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context)=>MyHomePage(user:myControllerEmail)),
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