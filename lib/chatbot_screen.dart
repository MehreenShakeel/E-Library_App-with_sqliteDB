import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class chatbotScreen extends StatefulWidget {
  const chatbotScreen({super.key});

  @override
  State<chatbotScreen> createState() => _chatbotScreenState();
}

class _chatbotScreenState extends State<chatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  late GenerativeModel _model;
  late ChatSession _chat;   // ← Correct type

  @override
  void initState() {
    super.initState();
    _initializeModel();
  }

  void _initializeModel() {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';

    if (apiKey.isEmpty) {
      print('No API key found! Add it to .env file');
      return;
    }

    _model = GenerativeModel(
      model: 'gemini-1.5-flash', // or gemini-pro
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        maxOutputTokens: 500,
        temperature: 0.7,
      ),
    );

    _chat = _model.startChat();
  }

  void _sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    setState(() {
      _messages.add({"sender": "user", "message": message});
    });

    try {
      final content = [Content.text(message)];           // ← Must be in a list
      final response = await _chat.sendMessage(content.first);

      setState(() {
        _messages.add({
          "sender": "bot",
          "message": response.text ?? "No response"
        });
      });
    } catch (e) {
      setState(() {
        _messages.add({"sender": "error", "message": e.toString()});
      });
    }
  }

  Widget _buildMessage(Map<String, dynamic> msg) {
    bool isUser = msg['sender'] == 'user';
    bool isError = msg['sender'] == 'error';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser)
            CircleAvatar(
              backgroundColor: isError ? Colors.red : Colors.teal,
              child: Icon(
                isError ? Icons.error : Icons.android,
                color: Colors.white,
              ),
            ),
          if (!isUser) const SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isUser
                    ? Colors.orangeAccent
                    : (isError ? Colors.red.shade600 : Colors.teal),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                msg['message'],
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 10),
          if (isUser)
            const CircleAvatar(
              backgroundColor: Colors.orangeAccent,
              child: Icon(Icons.person, color: Colors.white),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ChatBot'),
        backgroundColor: Colors.orangeAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _messages.length,
                itemBuilder: (context, index) => _buildMessage(_messages[index]),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      labelText: 'Enter your message',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onSubmitted: (text) {
                      _sendMessage(text);
                      _controller.clear();
                    },
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    _sendMessage(_controller.text);
                    _controller.clear();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orangeAccent,
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Icon(Icons.send, color: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}