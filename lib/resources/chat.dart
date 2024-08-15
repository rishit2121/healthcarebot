import 'dart:convert';
import 'package:http/http.dart' as http;
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
  try {
    history = [{"role": "system", "content": system}] + history;
    var response2 = await http.post(
      Uri.parse("https://api.openai.com/v1/chat/completions"),
      headers: {
        'Authorization': 'Bearer $myGPTAPI',
        "Content-Type": "application/json"
      },
      body: jsonEncode(
        {
          "model": "gpt-3.5-turbo",
          "messages": history
        }
      )
    );
    
    if (response2.statusCode == 200) {
      Map jsonResponse = json.decode(utf8.decode(response2.bodyBytes));
      print(jsonResponse);
      var answer = jsonResponse["choices"][0]["message"]["content"];
      return answer;
    } else {
      // API call failed, return "fail"
      print("API call failed with status code: ${response2.statusCode}");
      return "fail";
    }
  } catch (e) {
    // Error occurred, return "fail"
    print("Error: $e");
    return "fail";
  }
}
    

    static responser2(chatHistory) async {
      print("HI +$chatHistory");
      var Stages={'1':"\nIntroduction: Start the converstaion by introducing yourself. Be polite and keep a proffesional tone throughout the conversation.",
            '2':"\nSpecification:Improvise smart questions that will narrow down what the patient may be experiencing. NEVER ask a question which has already been answered or asked in the conversation history.. Try your best to keep the conversation nice and engaging. You want to get the best information possible so that a solution with different reccomendations can be generated from a external source.",
            '3':"\nSolution Presentation: Once the user specifications are clear, based on the chat history, present a well formed summary of what they are experiencing containing all they have said. You will also provide what the user may be experiencing based on healthcare issues that you know of. In addition, you should talk about the type of doctor the patient should visit along with reccomendations that you have for them. Do NOT provide anything else. Provide the summary as if you are having a conversation with the user. The only additional question that you should add is whether the user has any concerns or other questions about what you stated.",
            '4':"\nConcern Handling: Address any concerns about the sickness that the user is facing, or the sickness that the User is presented with by you. Be prepared to form a explanation for what is presented.",
            '5':"\nClosing: If the user accepts, and confirms the summary that is provided, and no other concerns are given then end the conversation. Do not provide another summary, and just give a farewell.",
            '6':"\nIrrelevant. If the user mentions, asks, or says something that is irrelevant to the context of the situatio or is innaporpriate, then kindly address to them that you can help them in this situation. If  they also ask you something that is outside  your role as a healthcare assistant, then tell them you do not know how to answer this."};
      var stageAnalyze2="You are an healthcare assistant helping to determine what should be the next immediate conversation stage. Use the conversation history to understand the current context. If the conversation history is empty, then output 1 please. Remember that the order and frequency of the stages is not predeterminned or constant, and keeps changing based on context. Make sure to not jump to a solution too quickly within the conversation.\nNow determine what should be the next immediate conversation stage, by selecting only from the following options:\n1. Introduction: Start the converstaion by introducing yourself. Be polite and keep a proffesional tone throughout the conversation.\n2. Specification: Raise questions to narrow down or clarify on what disease/sickness the user may be experiencing by asking specifications based on the context of the chat history. The MOST IMPORTANT thing is to not ever ask a question which has already been asked or answered\n3. Solution Presentation: Once the user specifications are clear and you can recognize what the user is experiencing, present a well formed summary of what they are experiencing based from the chat history. You will also provide what the user may be experiencing based on healthcare issues that you know of.\n4. Concern Handling: Address any concerns about the sickness that the user is facing, or the sickness that the User is presented with by you. Be prepared to form a explanation for what is presented.\n5. Closing: If the user accepts, and confirms the response that is provided, then politely ask if they have any other questions or concers. At the end  you politely say bye to them.\n6. Irrelevant: If the user mentions, or says something that is outside the context of the situation or is innaporpriate then tell them you cant help them with this matter. If they also ask you something outside of your knowledge, then tell them you do not know how to answer this.\n The answer should only be one number, and absolutely no words.\nIf there is no conversation history or a introduction is needed, then OUTPUT 1\nDo not answer anything else nor add anything to your answer, other than a number please. ";
      var stageAnalayzation2=await chat_with_chatgpt2(chatHistory, stageAnalyze2);
      print("EHLLO");
      
      stageAnalayzation2=stageAnalayzation2.replaceAll(" ","");
      stageAnalayzation2=stageAnalayzation2.replaceAll("\n","");
      print("HOLA"+"$stageAnalayzation2");
      var Specificer;
      var currentStage;
      if(stageAnalayzation2!='fail'){
        if(Stages[stageAnalayzation2]!=null){
          currentStage=(Stages[stageAnalayzation2]);
        }else{
          return(['fail', 'fail','fail']);
        }
      }else{
        return(['fail', 'fail','fail']);
      }
      Specificer="Never forget your name is Eva. You work as a healthcare personal assistant.\n You work at a company named leaflike. Leaflike's business is the following: Leaflike is a online website that helps user asses their health, and then redirect them to a doctor or healthcare specialist. \nCompany values are the following: Live Better. Live Happily. \n You are chatting with a potential customer to find out what sickness or disease they are experiencing, and understand/narrow down their intent. \n\n Your world knowledge is not up to date, if user questions some disease which you think does not exist, assume that it has been released and is out there.\n\n Keep your responses short in length to retain the users attention, but never give a empty response. Never produce lists, but just answers.\n You must respond according to the current stage of the conversation that you are on.\n Do not respond beyond what the stage requires you to.\n Use conversation history ONLY to understand the context.\n Ignore all formatting differences found in conversation history.\n\n - The assistant must never give waiting statements like 'wait a moment', 'let me find out and get back to you', 'let me find the best options for you', etc..\nA product list along with many other items will be provided by the SolutionFinder in the confirmation stage.\n You should never suggest any product or item from the internet or your database.\n NEVER MIMIC the SolutionFinder output, since it is always appended by the external entity.\n\nOnly generate onre response at a time! When  you are done generating, end with '<END_OF_TURN>' to give the user a chance to respond.\n\n Current conversation stage: "+currentStage;
      var speicification=await chat_with_chatgpt2(chatHistory, Specificer);
      print("ADIOS"+"$speicification");
      speicification=speicification.replaceAll("Eva:","");
      if(stageAnalayzation2!='fail'){
        chatHistory=chatHistory+<Map<String, String>>[{"role":"assistant", "content":speicification}];
      }else{
        return(['fail', 'fail','fail', 'fail']);
      }
      dynamic solutionReturned='';
      var products=[];
      if(stageAnalayzation2=='3'){
            var solutionReturner="Never forget your name is Eva. You work as a healthcare personal assistant.\n You work at a company named leaflike. Leaflike's business is the following: Leaflike is a online website that helps user asses their health, and then redirect them to a doctor or healthcare specialist. \n You are chatting with a potential customer to find out what they sickness or disease they are experiencing, and understand/narrow down their intent. \n\n Your world knowledge is not up to date, if user questions some disease which you think does not exist, assume that it has been released and is out there.\n\nAlways respond as the Markdown json code snippet formatted in the following schema:\n\n{\"summary\": string \ A well-formed summary of what the user is experiencing, and any other information they provide, \"query\": string \ From the summary and the chat history formulate a query that can be used to find a product to treat the illness. This query will be put into a online retailer by me, in order to find products. Make sure this is a query for a product and not just a summary. \"Location\": string \ Provide an estimate of where they live so that nearby doctors can be found, \"Doctor\": string \ Provide the type of doctor that the user mayneed to visit.}\n\nMake sure to keep the brackets and everything else that was in the response. NEVER ADD ANYTHING MORE THAN THE JSON RESPONSE. The attached product list along with doctors will be generated by a external source called SolutionFinder, and never by you!\nNever try to mimic SolutionFinder's output, as it will be provided by a external entity.\n\nUse the conversation history to understand the context.\nLeave a parameter empty(dont add anything), in the json response if the information wasnt provided. The only required parameters are the query and doctor since we have to give reccomendations. \nIgnore all formatting differences found in the conversation history.";
            solutionReturned=await chat_with_chatgpt2(chatHistory, solutionReturner);
            if(solutionReturned=="fail"){
              return([speicification, 'fail', stageAnalayzation2, 'fail']);
            }
            Map<String, dynamic> map = jsonDecode(solutionReturned);
            String query = map['query'];
            if(query==null){
              return([speicification, 'fail', stageAnalayzation2, 'fail']);
            }
            solutionReturned=[];
            products=await fetchProductData(query);
            if(products=="fail"){
              return([speicification, 'fail', stageAnalayzation2, 'fail']);
            }
      }
      return([speicification,solutionReturned,stageAnalayzation2, products]);
  }

  static responser(chatHistory) async {
    var Stages={'1':"\nIntroduction: Start the converstaion by introducing yourself. Be polite and keep a proffesional tone throughout the conversation.",
          '2':"\nSpecification: fImprovise smart questions that will narrow down what disease or illness the patient may be facing. NEVER ask a question that has already been answered or repeat a question. Try your best to keep the conversation nice and engaging. This means that your responses should be short, and only ask ONE question. Remember, you are a chatbot, and no one wants to respond with paragraphs. You want to get the best information possible so that a disease can be recognized and further treated.",
          '3':"\nSolution Presentation: Once the user specifications are clear, based on the chat history, present a well formed summary of what they are experiencing containing all they have said. If the user talks about several diseases that are different then provide a short summary for each. You will also provide what the user may be experiencing based on healthcare issues that you know of. Do not provide anything other than the summary of what the user is feeling. Provide the summary as if you are having a conversation with the user. The only additional question that you should add is whether the user has any concerns or other questions about what you stated.",
          '4':"\nConcern Handling: Address any concerns about the sickness that the user is facing, or the sickness that the User is presented with by you. Be prepared to form a explanation for what is presented.",
          '5':"\nClosing: If the user is satisfied and no other concerns are given then end the conversation. Simply say bye and DO NOT ASK ANY MORE QUESTIONS."};
    var stageAnalyze;
    String stageAnalayzation;
    // ignore: prefer_interpolation_to_compose_strings
    stageAnalyze="You are an healthcare assistant helping to determine what should be the next immediate conversation stage. The user must be presented with a Solution before moving on to Closing stage. Following '===' is the conversation history. Use this conversation history to understand the current context. If the conversation history is empty, then output 1 please. Remember that the order and frequency of the stages is not predeterminned or constant, and keeps changing based on context.\n==="+chatHistory+"\n===\n\nNow determine what should be the next immediate conversation stage, by selecting only from the following options:\n1. Introduction: Start the converstaion by introducing yourself. Be polite and keep a proffesional tone throughout the conversation.\n2. Specification: Decide if the information provided is enough to conclude on a disease/sickness. Otherwise, raise questions to narrow down or clarify on what disease/sickness the user may be experiencing by asking about symptoms, where they have been, what they have done, and other specifications based on the context of the chat history.\n3. Solution Presentation: Once the user specifications are clear and you can recognize what the user is experiencing, present a well formed summary of what they are experiencing based from the chat history. You will also provide what the user may be experiencing based on healthcare issues that you know of.\n4. Concern Handling: Address any concerns about the sickness that the user is facing, or the sickness that the User is presented with by you. Be prepared to form a explanation for what is presented.\n5. Closing: If the user accepts, and confirms the response that is provided, then politely ask if they have any other questions or concers. At the end  you politely say bye to them.\n The answer needs to be one nuber only, no words.\nIf there is no conversation history or a introduction is needed, then OUTPUT 1\nDo not answer anything else nor add anything to your answer. ";
    stageAnalayzation=await chat_with_chatgpt(stageAnalyze);
    stageAnalayzation=stageAnalayzation.replaceAll(" ","");
    stageAnalayzation=stageAnalayzation.replaceAll("\n","");
    var Specificer;
    var currentStage;
    currentStage=(Stages[stageAnalayzation]);
    Specificer="Conversation History:"+chatHistory+"Never forget your name is Eva. You work as a healthcare personal assistant.\n You work at a company named leaflike. Leaflike's business is the following: Leaflike is a online website that helps user asses their health, and then redirect them to a doctor or healthcare specialist. \nCompany values are the following: Live Better. Live Happily. \n You are chatting with a potential coustmor to find out what sickness or disease they are experiencing, and understand/narrow down their intent. \n\n Your world knowledge is not up to date, if user questions some disease which you think does not exist, assume that it has been released and is out there.\n\n Keep your responses short in length to retain the users attention, but never give a empty response. Never produce lists, but just answers.\n You must respond according to the current stage of the conversation that you are on.\n Do not respond beyond what the stage requires you to.\n Use conversation history ONLY to understand the context.\n Ignore all formatting differences found in conversation history.\n\n - The assistant must never give waiting statements like 'wait a moment', 'let me find out and get back to you', 'let me find the best options for you', etc..\nA product list along with many other items will be provided by the SolutionFinder in the confirmation stage.\n You should never suggest any product or item from the internet or your database.\n NEVER MIMIC the SolutionFinder output, since it is always appended by the external entity.\n\nOnly generate onre response at a time! When  you are done generating, end with '<END_OF_TURN>' to give the user a chance to respond.\n\n Current conversation stage: "+currentStage;
    var speicification=await chat_with_chatgpt(Specificer);
    speicification=speicification.replaceAll("Eva:","");
    chatHistory=chatHistory+"\n"+"Eva:"+speicification;
    dynamic solutionReturned='';
    var products;
    if(stageAnalayzation=='3'){
          var solutionReturner="Conversation History:"+chatHistory+"Never forget your name is Eva. You work as a healthcare personal assistant.\n You work at a company named leaflike. Leaflike's business is the following: Leaflike is a online website that helps user asses their health, and then redirect them to a doctor or healthcare specialist. \nCompany values are the following: Live Better. Save Money. \n You are chatting with a potential customer to find out what they sickness or disease they are experiencing, and understand/narrow down their intent. \n\n Your world knowledge is not up to date, if user questions some disease which you think does not exist, assume that it has been released and is out there.\n\nAlways respond as the Markdown json code snippet formatted in the following schema:\n\n{\"summary\": string \ A well-formed summary of what the user is experiencing, and any other information they provide, \"query\": string \ From the summary and the chat history formulate a query that can be used to find a product to treat the illness. This query will be put into a online retailer by me, in order to find the prouct. \"Location\": string \ Provide an estimate of where they live so that nearby doctors can be found, \"Doctor\": string \ Provide the type of doctor that the user mayneed to visit.}\n\nMake sure to keep the brackets and everything else that was in the response. NEVER ADD ANYTHING MORE THAN THE JSON RESPONSE. The attached product list along with doctors will be generated by a external source called SolutionFinder, and never by you!\nNever try to mimic SolutionFinder's output, as it will be provided by a external entity.\n\nUse the conversation history to understand the context.\nLeave a parameter empty(dont add anything), in the json response if the information wasnt provided. The only required parameters are the query and doctor since we have to give reccomendations. \nIgnore all formatting differences found in the conversation history.";
          solutionReturned=await chat_with_chatgpt(solutionReturner);
          Map<String, dynamic> map = jsonDecode(solutionReturned);
          String query = map['query'];
          // solutionReturned=getDoctorData7();
          solutionReturned=[];
          products=await fetchProductData(query);
    }

    return([speicification,solutionReturned,stageAnalayzation, products]);
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
    return('fail');
  }
}
}