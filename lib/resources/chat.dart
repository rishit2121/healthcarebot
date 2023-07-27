import 'dart:developer';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:html/dom.dart' as dom;
import 'package:webdriver/support/async.dart';
import 'package:xml/xml.dart';
import 'package:http/http.dart' as http;
import 'package:chaleno/chaleno.dart';
import 'package:webdriver/io.dart';
import 'package:html/parser.dart' show parse;
import 'package:xml/xml.dart' as xml;
import 'package:puppeteer/puppeteer.dart';
import '/secrets.dart';


mixin Functions{
  static chat_with_chatgpt(message) async {
      var response2 = await http.post(
          Uri.parse("https://api.openai.com/v1/completions"),
          headers: {
            'Authorization': 'Bearer $myGPTAPI',
            "Content-Type": "application/json"
          },
          body: jsonEncode(
            {
              "model": "text-davinci-003",
              "prompt":message,
              'max_tokens':100,
              'n':1,
              'stop':'None',
              'temperature':0.5,
            },
          ),
      );
      Map jsonResponse = json.decode(utf8.decode(response2.bodyBytes));
      print(jsonResponse);
      var answer=jsonResponse["choices"][0]['text'];
      return(answer);

    }

    static chat_with_chatgpt2(history, system) async {
      history=[{"role":"system", "content":system}]+history;
      var response2 = await http.post(
          Uri.parse("https://api.openai.com/v1/chat/completions"),
          headers: {
            'Authorization': 'Bearer $myGPTAPI',
            "Content-Type": "application/json"
          },
          body:jsonEncode(
            {
              "model": "gpt-4",
              "messages": history
            }
          )
      );
      Map jsonResponse = json.decode(utf8.decode(response2.bodyBytes));
      print(jsonResponse);
      var answer=jsonResponse["choices"][0]["message"]["content"];
      return(answer);

    }

    static responser2(chatHistory) async {
    var Stages={'1':"\nIntroduction: Start the converstaion by introducing yourself. Be polite and keep a proffesional tone throughout the conversation.",
          '2':"\nSpecification: Raise questions to narrow down or clarify on what disease/sickness the user may be experiencing along with what doctor they can visit by asking about things such as where they have been, how they feel, what they have done, where they live and other specifications based on the context of the conversation history. You do not have to ask these specific questions or in this order. Improvise smart questions that will narrow down what disease or illness the patient may be facing. NEVER ask a question that has already been answered or repeat a question. Try your best to keep the conversation nice and engaging. You want to get the best information possible so that a solution with different reccomendations can be generated from a external source.",
          '3':"\nSolution Presentation: Once the user specifications are clear, based on the chat history, present a well formed summary of what they are experiencing containing all they have said. You will also provide what the user may be experiencing based on healthcare issues that you know of. Do not provide anything other than the summary of what the user is feeling. Provide the summary as if you are having a conversation with the user. The only additional question that you should add is whether the user has any concerns or other questions about what you stated.",
          '4':"\nConcern Handling: Address any concerns about the sickness that the user is facing, or the sickness that the User is presented with by you. Be prepared to form a explanation for what is presented.",
          '5':"\nClosing: If the user accepts, and confirms the summary that is provided, and no other concerns are given then end the conversation. Do not provide another summary, and just give a farewell."};
    var stageAnalyze2="You are an healthcare assistant helping to determine what should be the next immediate conversation stage. The user must be presented with a Solution before moving on to Closing stage. Use the conversation history to understand the current context. If the conversation history is empty, then output 1 please. Remember that the order and frequency of the stages is not predeterminned or constant, and keeps changing based on context.\nNow determine what should be the next immediate conversation stage, by selecting only from the following options:\n1. Introduction: Start the converstaion by introducing yourself. Be polite and keep a proffesional tone throughout the conversation.\n2. Specification: Raise questions to narrow down or clarify on what disease/sickness the user may be experiencing by asking about symptoms, where they have been, what they have done, and other specifications based on the context of the chat history.\n3. Solution Presentation: Once the user specifications are clear and you can recognize what the user is experiencing, present a well formed summary of what they are experiencing based from the chat history. You will also provide what the user may be experiencing based on healthcare issues that you know of.\n4. Concern Handling: Address any concerns about the sickness that the user is facing, or the sickness that the User is presented with by you. Be prepared to form a explanation for what is presented.\n5. Closing: If the user accepts, and confirms the response that is provided, then politely ask if they have any other questions or concers. At the end  you politely say bye to them.\n The answer needs to be one nuber only, no words.\nIf there is no conversation history or a introduction is needed, then OUTPUT 1\nDo not answer anything else nor add anything to your answer. ";
    var stageAnalayzation2=await chat_with_chatgpt2(chatHistory, stageAnalyze2);
    stageAnalayzation2=stageAnalayzation2.replaceAll(" ","");
    stageAnalayzation2=stageAnalayzation2.replaceAll("\n","");
    var Specificer;
    var currentStage;
    currentStage=(Stages[stageAnalayzation2]);
    Specificer="Never forget your name is Sam. You work as a healthcare personal assistant.\n You work at a company named leaflike. Leaflike's business is the following: Leaflike is a online website that helps user asses their health, and then redirect them to a doctor or healthcare specialist. \nCompany values are the following: Live Better. Live Happily. \n You are chatting with a potential customer to find out what sickness or disease they are experiencing, and understand/narrow down their intent. \n\n Your world knowledge is not up to date, if user questions some disease which you think does not exist, assume that it has been released and is out there.\n\n Keep your responses short in length to retain the users attention, but never give a empty response. Never produce lists, but just answers.\n You must respond according to the current stage of the conversation that you are on.\n Do not respond beyond what the stage requires you to.\n Use conversation history ONLY to understand the context.\n Ignore all formatting differences found in conversation history.\n\n - The assistant must never give waiting statements like 'wait a moment', 'let me find out and get back to you', 'let me find the best options for you', etc..\nA product list along with many other items will be provided by the SolutionFinder in the confirmation stage.\n You should never suggest any product or item from the internet or your database.\n NEVER MIMIC the SolutionFinder output, since it is always appended by the external entity.\n\nOnly generate onre response at a time! When  you are done generating, end with '<END_OF_TURN>' to give the user a chance to respond.\n\n Current conversation stage: "+currentStage;
    var speicification=await chat_with_chatgpt2(chatHistory, Specificer);
    speicification=speicification.replaceAll("Sam:","");
    chatHistory=chatHistory+<Map<String, String>>[{"role":"assistant", "content":speicification}];
    dynamic solutionReturned='';
    var products;
    if(stageAnalayzation2=='3'){
          var solutionReturner="Never forget your name is Sam. You work as a healthcare personal assistant.\n You work at a company named leaflike. Leaflike's business is the following: Leaflike is a online website that helps user asses their health, and then redirect them to a doctor or healthcare specialist. \n You are chatting with a potential customer to find out what they sickness or disease they are experiencing, and understand/narrow down their intent. \n\n Your world knowledge is not up to date, if user questions some disease which you think does not exist, assume that it has been released and is out there.\n\nAlways respond as the Markdown json code snippet formatted in the following schema:\n\n{\"summary\": string \ A well-formed summary of what the user is experiencing, and any other information they provide, \"query\": string \ From the summary and the chat history formulate a query that can be used to find a product to treat the illness. This query will be put into a online retailer by me, in order to find products. Make sure this is a query for a product and not just a summary. \"Location\": string \ Provide an estimate of where they live so that nearby doctors can be found, \"Doctor\": string \ Provide the type of doctor that the user mayneed to visit.}\n\nMake sure to keep the brackets and everything else that was in the response. NEVER ADD ANYTHING MORE THAN THE JSON RESPONSE. The attached product list along with doctors will be generated by a external source called SolutionFinder, and never by you!\nNever try to mimic SolutionFinder's output, as it will be provided by a external entity.\n\nUse the conversation history to understand the context.\nLeave a parameter empty(dont add anything), in the json response if the information wasnt provided. The only required parameters are the query and doctor since we have to give reccomendations. \nIgnore all formatting differences found in the conversation history.";
          solutionReturned=await chat_with_chatgpt2(chatHistory, solutionReturner);
          Map<String, dynamic> map = jsonDecode(solutionReturned);
          String doctor = map['Doctor'];
          String query = map['query'];
          String location = map['Location'];
          solutionReturned=[];
          products=await fetchProductData(query);
    }
    return([speicification,solutionReturned,stageAnalayzation2, products]);
  }

  static responser(chatHistory) async {
    var Stages={'1':"\nIntroduction: Start the converstaion by introducing yourself. Be polite and keep a proffesional tone throughout the conversation.",
          '2':"\nSpecification: Raise questions to narrow down or clarify on what disease/sickness the user may be experiencing along with what doctor they can visit by asking about things such as where they have been, how they feel, what they have done, where they live and other specifications based on the context of the conversation history. You do not have to ask these specific questions or in this order. Improvise smart questions that will narrow down what disease or illness the patient may be facing. NEVER ask a question that has already been answered or repeat a question. Try your best to keep the conversation nice and engaging. This means that your responses should be short, and only ask ONE question. Remember, you are a chatbot, and no one wants to respond with paragraphs. You want to get the best information possible so that a disease can be recognized and further treated.",
          '3':"\nSolution Presentation: Once the user specifications are clear, based on the chat history, present a well formed summary of what they are experiencing containing all they have said. You will also provide what the user may be experiencing based on healthcare issues that you know of. Do not provide anything other than the summary of what the user is feeling. Provide the summary as if you are having a conversation with the user. The only additional question that you should add is whether the user has any concerns or other questions about what you stated.",
          '4':"\nConcern Handling: Address any concerns about the sickness that the user is facing, or the sickness that the User is presented with by you. Be prepared to form a explanation for what is presented.",
          '5':"\nClosing: If the user is satisfied and no other concerns are given then end the conversation. Simply say bye and DO NOT ASK ANY MORE QUESTIONS."};
    var stageAnalyze;
    String stageAnalayzation;
    // ignore: prefer_interpolation_to_compose_strings
    stageAnalyze="You are an healthcare assistant helping to determine what should be the next immediate conversation stage. The user must be presented with a Solution before moving on to Closing stage. Following '===' is the conversation history. Use this conversation history to understand the current context. If the conversation history is empty, then output 1 please. Remember that the order and frequency of the stages is not predeterminned or constant, and keeps changing based on context.\n==="+chatHistory+"\n===\n\nNow determine what should be the next immediate conversation stage, by selecting only from the following options:\n1. Introduction: Start the converstaion by introducing yourself. Be polite and keep a proffesional tone throughout the conversation.\n2. Specification: Raise questions to narrow down or clarify on what disease/sickness the user may be experiencing by asking about symptoms, where they have been, what they have done, and other specifications based on the context of the chat history.\n3. Solution Presentation: Once the user specifications are clear and you can recognize what the user is experiencing, present a well formed summary of what they are experiencing based from the chat history. You will also provide what the user may be experiencing based on healthcare issues that you know of.\n4. Concern Handling: Address any concerns about the sickness that the user is facing, or the sickness that the User is presented with by you. Be prepared to form a explanation for what is presented.\n5. Closing: If the user accepts, and confirms the response that is provided, then politely ask if they have any other questions or concers. At the end  you politely say bye to them.\n The answer needs to be one nuber only, no words.\nIf there is no conversation history or a introduction is needed, then OUTPUT 1\nDo not answer anything else nor add anything to your answer. ";
    stageAnalayzation=await chat_with_chatgpt(stageAnalyze);
    stageAnalayzation=stageAnalayzation.replaceAll(" ","");
    stageAnalayzation=stageAnalayzation.replaceAll("\n","");
    var Specificer;
    var currentStage;
    currentStage=(Stages[stageAnalayzation]);
    Specificer="Conversation History:"+chatHistory+"Never forget your name is Sam. You work as a healthcare personal assistant.\n You work at a company named leaflike. Leaflike's business is the following: Leaflike is a online website that helps user asses their health, and then redirect them to a doctor or healthcare specialist. \nCompany values are the following: Live Better. Live Happily. \n You are chatting with a potential coustmor to find out what sickness or disease they are experiencing, and understand/narrow down their intent. \n\n Your world knowledge is not up to date, if user questions some disease which you think does not exist, assume that it has been released and is out there.\n\n Keep your responses short in length to retain the users attention, but never give a empty response. Never produce lists, but just answers.\n You must respond according to the current stage of the conversation that you are on.\n Do not respond beyond what the stage requires you to.\n Use conversation history ONLY to understand the context.\n Ignore all formatting differences found in conversation history.\n\n - The assistant must never give waiting statements like 'wait a moment', 'let me find out and get back to you', 'let me find the best options for you', etc..\nA product list along with many other items will be provided by the SolutionFinder in the confirmation stage.\n You should never suggest any product or item from the internet or your database.\n NEVER MIMIC the SolutionFinder output, since it is always appended by the external entity.\n\nOnly generate onre response at a time! When  you are done generating, end with '<END_OF_TURN>' to give the user a chance to respond.\n\n Current conversation stage: "+currentStage;
    var speicification=await chat_with_chatgpt(Specificer);
    speicification=speicification.replaceAll("Sam:","");
    chatHistory=chatHistory+"\n"+"Sam:"+speicification;
    dynamic solutionReturned='';
    var products;
    if(stageAnalayzation=='3'){
          var solutionReturner="Conversation History:"+chatHistory+"Never forget your name is Sam. You work as a healthcare personal assistant.\n You work at a company named leaflike. Leaflike's business is the following: Leaflike is a online website that helps user asses their health, and then redirect them to a doctor or healthcare specialist. \nCompany values are the following: Live Better. Save Money. \n You are chatting with a potential customer to find out what they sickness or disease they are experiencing, and understand/narrow down their intent. \n\n Your world knowledge is not up to date, if user questions some disease which you think does not exist, assume that it has been released and is out there.\n\nAlways respond as the Markdown json code snippet formatted in the following schema:\n\n{\"summary\": string \ A well-formed summary of what the user is experiencing, and any other information they provide, \"query\": string \ From the summary and the chat history formulate a query that can be used to find a product to treat the illness. This query will be put into a online retailer by me, in order to find the prouct. \"Location\": string \ Provide an estimate of where they live so that nearby doctors can be found, \"Doctor\": string \ Provide the type of doctor that the user mayneed to visit.}\n\nMake sure to keep the brackets and everything else that was in the response. NEVER ADD ANYTHING MORE THAN THE JSON RESPONSE. The attached product list along with doctors will be generated by a external source called SolutionFinder, and never by you!\nNever try to mimic SolutionFinder's output, as it will be provided by a external entity.\n\nUse the conversation history to understand the context.\nLeave a parameter empty(dont add anything), in the json response if the information wasnt provided. The only required parameters are the query and doctor since we have to give reccomendations. \nIgnore all formatting differences found in the conversation history.";
          solutionReturned=await chat_with_chatgpt(solutionReturner);
          Map<String, dynamic> map = jsonDecode(solutionReturned);
          String doctor = map['doctor'];
          String query = map['query'];
          String location = map['Location'];
          // solutionReturned=getDoctorData7();
          solutionReturned=[];
          products=await fetchProductData(query);
    }

    return([speicification,solutionReturned,stageAnalayzation, products]);
  }

static getDoctorData7() async {
  final doctorList = [];

  // Make an HTTP request to the desired URL
  final response = await http.Request('GET', Uri.parse('https://healthy.kaiserpermanente.org/northern-california/doctors-locations#/providers?keyword=ophthalmologist'))
    ..headers['cookie'] = 'security=true';

  // Delay execution to allow the loading screen to disappear
  await Future.delayed(Duration(seconds: 10));

  // Parse the HTML response
  final document = parse(response.body);

  // Extract the desired data from the parsed HTML
  final xmlDocument = xml.XmlDocument.parse(response.body);
  print(xmlDocument.text);
  final nameElements = xmlDocument.findAllElements('span')
      .where((element) => element.getAttribute('class') == 'result-title-heading styling-7 -medium test-provider-name');
  final locationElements = xmlDocument.findAllElements('span')
      .where((element) => element.getAttribute('class') == 'provider-search-location');
  final numberElements = xmlDocument.findAllElements('a')
      .where((element) => element.getAttribute('class') == 'link-primary');

  for (var i = 0; i < 4; i++) {
    final name = nameElements.elementAt(i).text;
    print(name);
    final location = locationElements.elementAt(i).text;
    final number = numberElements.elementAt(i).text;

    doctorList.add([name, location, number]);
  }

  print(doctorList);
  return doctorList;
}

static fetchProductData(String query) async {
  final encodedQuery = Uri.encodeComponent(query);
  final url = Uri.parse('https://real-time-product-search.p.rapidapi.com/search?q=$encodedQuery&country=us&language=en&sort_by=TOP_RATED&on_sale=true'); //BEST_MATCH also

  final headers = {
    'X-RapidAPI-Key': '24d7fdb755mshe9ad7b273211de1p160e9bjsn32244367e3e3',
    'X-RapidAPI-Host': 'real-time-product-search.p.rapidapi.com',
  };

  final response = await http.get(url, headers: headers);

  if (response.statusCode == 200) {
    // Request succeeded, parse the response
    var data = json.decode(response.body);
    // Handle the data
    return(data['data']);
  } else {
    // Request failed
    print('Request failed with status: ${response.statusCode}');
  }
}
}