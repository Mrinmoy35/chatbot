import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:chat_bubbles/chat_bubbles.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Message> _messages = [];
  bool _isTyping = false;
  final String _apiKey = "API_KEY"; // Replace with your actual API key

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat with GPT-3"),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _messages.length,
              shrinkWrap: true,
              reverse: true,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: _isTyping && index == 0
                      ? Column(
                    children: [
                      BubbleNormal(
                        text: _messages[0].msg,
                        isSender: true,
                        color: Colors.blue.shade100,
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: 16, top: 4),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text("Typing..."),
                        ),
                      ),
                    ],
                  )
                      : BubbleNormal(
                    text: _messages[index].msg,
                    isSender: _messages[index].isSender,
                    color: _messages[index].isSender
                        ? Colors.blue.shade100
                        : Colors.grey.shade200,
                  ),
                );
              },
            ),
          ),
          _buildInputRow(),
        ],
      ),
    );
  }

  Widget _buildInputRow() {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: double.infinity,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: TextField(
                  controller: _controller,
                  textCapitalization: TextCapitalization.sentences,
                  onSubmitted: (value) {
                    _sendMessage();
                  },
                  textInputAction: TextInputAction.send,
                  showCursor: true,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "Enter text",
                  ),
                ),
              ),
            ),
          ),
        ),
        InkWell(
          onTap: _sendMessage,
          child: Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Icon(
              Icons.send,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  void _sendMessage() async {
    String text = _controller.text;
    _controller.clear();

    if (text.isNotEmpty) {
      setState(() {
        _messages.insert(0, Message(true, text));
        _isTyping = true;
      });

      _scrollController.animateTo(0.0,
          duration: const Duration(seconds: 1), curve: Curves.easeOut);

      try {
        var response = await http.post(
          Uri.parse("https://api.openai.com/v1/chat/completions"),
          headers: {
            "Authorization": "Bearer $_apiKey",
            "Content-Type": "application/json",
          },
          body: jsonEncode({
            "model": "gpt-3.5-turbo",
            "messages": [
              {"role": "user", "content": text}
            ]
          }),
        );

        if (response.statusCode == 200) {
          var json = jsonDecode(response.body);
          if (json.containsKey("choices") && json["choices"].isNotEmpty) {
            setState(() {
              _isTyping = false;
              _messages.insert(
                0,
                Message(
                  false,
                  json["choices"][0]["message"]["content"].toString().trimLeft(),
                ),
              );
            });

            _scrollController.animateTo(0.0,
                duration: const Duration(seconds: 1), curve: Curves.easeOut);
          } else {
            throw Exception("Invalid response format");
          }
        } else {
          throw Exception("API error: ${response.statusCode}");
        }
      } catch (e) {
        setState(() {
          _isTyping = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("An error occurred, please try again."),
          ),
        );
      }
    }
  }
}

class Message {
  final bool isSender;
  final String msg;

  Message(this.isSender, this.msg);
}