import 'package:chatbot2/chatbot.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// Import the file where HealthChatbot is defined

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Health Chatbot',
      theme: ThemeData(
        primarySwatch: Colors.blue, // You can change the theme as desired
      ),
      home: ChatScreen(),
      debugShowCheckedModeBanner: false,// Set the HealthChatbot as the initial screen
    );
  }
}
