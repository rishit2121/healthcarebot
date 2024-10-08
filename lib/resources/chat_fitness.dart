import 'dart:convert';
import 'package:http/http.dart' as http;
import '/secrets.dart';
import 'package:flutter/services.dart' show rootBundle;


mixin Fitness_Functions{
 static Fitness_chat_with_chatgpt(history, system) async {
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
// static Fitness_chat_with_chatgpt(message) async {
//   try {
//     var response2 = await http.post(
//       Uri.parse("https://api.openai.com/v1/completions"),
//       headers: {
//         'Authorization': 'Bearer $myGPTAPI',
//         "Content-Type": "application/json"
//       },
//       body: jsonEncode(
//         {
//           "model": "text-davinci-003",
//           "prompt": message,
//           'max_tokens': 100,
//           'n': 1,
//           'stop': 'None',
//           'temperature': 0.5,
//         },
//       ),
//     );

//     Map jsonResponse = json.decode(utf8.decode(response2.bodyBytes));
//     var answer = jsonResponse["choices"][0]['text'];
//     return answer;
//   } catch (e) {
//     print("API call failed: $e");
//     return "fail";
//   }
// }


static Fitness_chat_with_chatgpt2(history, system) async {
  try {
    history = [{"role": "system", "content": system}] + history;
    var response2 = await http.post(
      Uri.parse("https://api.openai.com/v1/chat/completions"),
      headers: {
        'Authorization': 'Bearer $myGPTAPI',
        "Content-Type": "application/json"
      },
      body: jsonEncode({
        "model": "gpt-4",
        "messages": history
      }),
    );

    Map jsonResponse = json.decode(utf8.decode(response2.bodyBytes));
    print(jsonResponse);
    var answer = jsonResponse["choices"][0]["message"]["content"];
    return answer;
  } catch (e) {
    print("API call failed: $e");
    return "fail";
  }
}


  static Fitness_responser(chatHistory) async {
    print(chatHistory);
    final String ExerciseResponse = await rootBundle.loadString('assets/data.json');
    final Allexercises = await json.decode(ExerciseResponse);
    var Stages={'1':"\nIntroduction: Start the converstaion by introducing yourself. Be polite and keep a proffesional tone throughout the conversation.",
          '2':"\nSpecification: Raise questions to narrow down or clarify on what exercises are best fit for the user. Only ask specifications based on the context of the conversation history. Improvise smart questions that will narrow down what exercise the user prefers or best suits them. NEVER ask a question that has already been answered or repeat a question. Try your best to keep the conversation nice and engaging. This means that your responses should be short, and only ask ONE question. Remember, you are a chatbot, and no one wants to respond with paragraphs. You want to get the best information possible so that a exercise can be detected and practice.",
          '3':"\nSolution Presentation: Once the user specifications are clear, based on the chat history, present a well formed summary of what type of exercises the user is looking for or requires. You will also provide any risks associated with these types of exercises. Do not provide anything other than the summary of the types of exercises. Provide the summary as if you are having a conversation with the user. The only additional question that you should add is whether the user has any concerns or other questions about what you stated.",
          '4':"\nConcern Handling: Address any concerns about the summary you give or the exercices provided. Be prepared to form a explanation for what is presented.",
          '5':"\nClosing: If the user is satisfied and no other concerns are given then end the conversation. Simply say bye and DO NOT ASK ANY MORE QUESTIONS.",
          '6':"\nInformational: If the user is seeking information on a certain exercise or area of fitnss, then politely describe it for them, and do not ask any more questions in this phase."};
    var stageAnalyze;
    String stageAnalayzation;
    // ignore: prefer_interpolation_to_compose_strings
    stageAnalyze="You are an fitness assistant helping to determine what should be the next immediate conversation stage. The user must be presented with a Solution before moving on to Closing stage. Following '===' is the conversation history. Use this conversation history to understand the current context. If the conversation history is empty, then output 1 please. Remember that the order and frequency of the stages is not predeterminned or constant, and keeps changing based on context. Determine what should be the next immediate conversation stage, by selecting only from the following options:\n1. Introduction: Start the converstaion by introducing yourself. Be polite and keep a proffesional tone throughout the conversation.\n2. Specification: Raise questions to narrow down or clarify on what exercise the user should practice by asking about what muscles they want to work on and different things.\n3. Solution Presentation: Once the user specifications are clear and you can recognize what exercise is best suited for the user, present a well formed summary of what they are experiencing based from the chat history. \n4. Concern Handling: Address any concerns about the summary that is provided by you or any exercises chosen. Be prepared to form a explanation for what is presented.\n5. Closing: If the user accepts, and confirms the response that is provided, then politely ask if they have any other questions or concers. At the end  you politely say bye to them. \n6. Information: If the user wants to learn more about some exercise or topic within the field of fitness then simply describe it for them. In this phase, a single question should not be asked.\n The answer needs to be one nuber only, no words.\nIf there is no conversation history or a introduction is needed, then OUTPUT 1\nDo not answer anything else nor add anything to your answer. ";
    stageAnalayzation=await Fitness_chat_with_chatgpt(chatHistory,stageAnalyze,);
    print(stageAnalayzation);
    stageAnalayzation=stageAnalayzation.replaceAll(" ","");
    stageAnalayzation=stageAnalayzation.replaceAll("\n","");
    var Specificer;
    var speicification;
    var currentStage;
    var exercicesList=[];

    if(stageAnalayzation!='fail'){
      if(Stages[stageAnalayzation]!=null){
        currentStage=(Stages[stageAnalayzation]);
      }else{
        return null;
      }
      }else{
        return(['fail', 'fail','fail']);
      }
      Specificer="Never forget your name is Jack. You work as a Fitness assistant.\n You work at a company named leaflike. Leaflike's business is the following: Leaflike is a online website that helps user asses their health, and then provide them reccomendations. \nCompany values are the following: Live Better. Live Happily. \n You are chatting with a potential coustmor to find out what exercise best suits them, and understand/narrow down their intent. \n\n Your world knowledge is not up to date, if user questions some exercise which you think does not exist, assume that it has been released and is out there.\n\n Keep your responses short in length to retain the users attention, but never give a empty response. Never produce lists, but just answers.\n You must respond according to the current stage of the conversation that you are on.\n Do not respond beyond what the stage requires you to.\n Use conversation history ONLY to understand the context.\n Ignore all formatting differences found in conversation history.\n\n - The assistant must never give waiting statements like 'wait a moment', 'let me find out and get back to you', 'let me find the best options for you', etc..\nA exercise list along with many other items will be provided by the SolutionFinder in the confirmation stage.\n You should never suggest any product or item from the internet or your database.\n NEVER MIMIC the SolutionFinder output, since it is always appended by the external entity.\n\nOnly generate onre response at a time! When  you are done generating, end with '<END_OF_TURN>' to give the user a chance to respond.\n\n Current conversation stage: "+currentStage;
      speicification=await Fitness_chat_with_chatgpt( chatHistory,Specificer);
      print("ADIOS"+"$speicification");
      speicification=speicification.replaceAll("Jack:","");
      if(stageAnalayzation!='fail'){
        chatHistory=chatHistory+<Map<String, String>>[{"role":"assistant", "content":speicification}];
      }else{
        return(['fail', 'fail','fail']);
      }
    dynamic solutionReturned='';
    dynamic solutionExercises=[];
    var exercises=[];
    if(stageAnalayzation=='3'){
          var solutionReturner= "You are a fitness assistant named Jack, and you are a personal fitness assistant.Always respond as the Markdown json code snippet formatted in the following schema:\n\n{\"target\": list\ A list of body targets that you have chosen for the exercises(no more than 4 body targets). You can choose from \"abductors\", \"abs\",\"adductors\", \"biceps\",\"calves\", \"cardiovascular system\", \"delts\", \"forearms\", \"glutes\", \"hamstrings\", \"lats\", \"levator scapulae\", \"pectorals\", \"quads\", \"serratus anterior\", \"spine\", \"traps', \"triceps\", and \"upper back\"  Ex. [\"back\", \"upper back\",\"triceps\",\"traps\"]}\n\nMake sure to keep the brackets and everything else that was in the response. NEVER ADD ANYTHING MORE THAN THE JSON RESPONSE.";
          solutionReturned=await Fitness_chat_with_chatgpt(chatHistory, solutionReturner);
           print(solutionReturned);
          Map<String, dynamic> map1 = jsonDecode(solutionReturned);
          if(map1==null){
            return([speicification, stageAnalayzation, 'fail']);
          }
          List targets = map1["target"];
          if(targets==null){
            return([speicification, stageAnalayzation, 'fail']);
          }
          List namesList =Allexercises
            .where((map) => targets.contains(map['target']))
            .map((map) => map['name'] as String)
            .toList();
          var final_exercises= "You are a fitness assistant named Jack, and your job is to pick a exercise out of the following provided based on the conversation history.Always respond as the Markdown json code snippet formatted in the following schema:\n\n{\"exercises\": list\ A list of 5 exercises you have chosen from the ones provided. Your choice should be made accordingly to the context of the conversation history. Ex. [\"push-up\", \"curl-up\", \"air bike\", \"sit-up\", \"assisted sit-up\"]\n}\n\nMake sure to keep the brackets for the json and list along with everything else that was in the response. NEVER ADD ANYTHING MORE THAN THE JSON RESPONSE. Heres the list of exercises:\n\n"+"$namesList";
          solutionExercises=await Fitness_chat_with_chatgpt(chatHistory, final_exercises, );
          print(solutionExercises);
          print("SOLUTION$solutionExercises");
          if(solutionExercises=='fail'){
            return([speicification, stageAnalayzation, 'fail']);
          }
          Map<String, dynamic> exercisesMap = jsonDecode(solutionExercises, );
          if(exercisesMap==null){
            return([speicification, stageAnalayzation, 'fail']);
          }
          exercises=exercisesMap['exercises'];
          if(exercises==null){
            return([speicification, stageAnalayzation, 'fail']);
          }
          exercises=exercises.map((str) => str.toLowerCase()).toList();
          print(exercises);
          exercicesList=Allexercises
            .where((map) => exercises.contains(map['name']))
            .map((map) => map)
            .toList();
          print(exercicesList);
          // solutionReturned=getDoctorData7();
    }

    return([speicification, stageAnalayzation, exercicesList]);
  }

static Fitness_fetchProductData(String query) async {
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