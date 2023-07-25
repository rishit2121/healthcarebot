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

class Entering extends StatefulWidget {
  const Entering({ Key? key }) : super(key: key);

  @override
  _EnteringState createState() => _EnteringState();
}

class _EnteringState extends State<Entering> with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 2), () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage())));
  }
  
  late final AnimationController _controller = AnimationController(
    duration: const Duration(seconds: 2),
    vsync: this,
  )..repeat(reverse: true);
  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeIn,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: FadeTransition(
        opacity: _animation,
        child: Column(children: [
          Padding(padding: EdgeInsets.symmetric(), child: Icon(Icons.music_note, size: 75, color: Colors.blue,textDirection: TextDirection.ltr) ),
          Padding(padding: EdgeInsets.only(bottom: 25.0),
          child: Text(
            "Getting Things Ready", 
            style: TextStyle(fontSize: 15, color: Colors.blue, ),
            textDirection: TextDirection.ltr
          )
          ),
          ], 
        ),
      )
      );
  }
}
class LoginPage extends StatefulWidget{
  @override 
  static var user=_LoginPageState.user;
  static var pwd= _LoginPageState.pwd;
  _LoginPageState createState() => _LoginPageState();
}
class _LoginPageState extends State<LoginPage> {
  
  String title="Login";
  String other_title="Sign Up";
  String hint_txt="Dont have a account?";
  String other_hint_txt="Already have a account?";
  String msg="";
  static var user="";
  static var pwd="";
  final _formKey = GlobalKey<FormState>();
  final myController=TextEditingController();
  final myControllerPwd=TextEditingController();
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
          Widget buildUsername(BuildContext context){
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
              onPress:() {
                if(title=="Login"){
                  try{
                    if(data[myController.text]['pwd']==myControllerPwd.text){
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context)=>ChatScreen()),
                      );
                      user=myController.text;
                      pwd=myControllerPwd.text;
                      setState(() {
                        msg="";
                      });
                    }
                    else{
                      setState(() {
                        msg="Password or Username is Incorrect";
                      });
                      
                    }
                  // ignore: avoid_types_as_parameter_names
                  }catch(Exception){
                    setState(() {
                      msg="Username does not exist";
                    });
                    
                  }
                }
                if(title=="Sign Up"){
                  if(data[myController.text]==null){
                    login.doc("login").set(
                      {myController.text:{'pwd':myControllerPwd.text}},
                      SetOptions(merge:true),
                      );
                    login.doc("${myController.text}").set(
                      {myController.text:{'pwd':myControllerPwd.text}},
                      SetOptions(merge:true),
                    );
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context)=>ChatScreen()),
                    );
                    setState(() {
                      msg="";
                      user=myController.text;
                      pwd=myControllerPwd.text; 
                    });
                  }
                  else{
                    setState(() {
                      msg="This username already exists";
                    });
                    
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
              padding(context, 0.1),
              buildUsername(context),
              padding(context, 0.05),
              buildPassword(context),
              padding(context, 0.05),
              buildEnter(context),  //0.03
              padding(context,0.23), 
              buildSwitch(context),  //0.03       


              ])));
        }
        return CoolLoadingIndicator();

      },
    );
  }
}