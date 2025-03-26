import 'package:flutter/material.dart';
import 'package:hackathon/services/gemini_ai_service.dart';
import 'package:hackathon/services/pdf_repository.dart';

class AiPdfChatScreen extends StatefulWidget {
  const AiPdfChatScreen({Key? key}) : super(key: key);

  @override
  _AiPdfChatScreenState createState() => _AiPdfChatScreenState();
}

class _AiPdfChatScreenState extends State<AiPdfChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _chatLog = [];
  late GeminiAiService _geminiAi;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _geminiAi = GeminiAiService(PdfRepository());
  }

  Future<void> _sendMessage() async {
    final userText = _controller.text.trim();
    if (userText.isEmpty) return;

    setState(() {
      _chatLog.add("You: $userText");
      _controller.clear();
      _isLoading = true;
    });

    final response = await _geminiAi.askGemini(userText);

    setState(() {
      _chatLog.add("Gemini: $response");
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gemini AI PDF Chat"),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _chatLog.length,
              itemBuilder: (context, index) {
                final msg = _chatLog[index];
                final isUser = msg.startsWith("You:");
                final alignment =
                    isUser ? Alignment.centerRight : Alignment.centerLeft;
                return Container(
                  alignment: alignment,
                  margin:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.green[100] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(msg),
                  ),
                );
              },
            ),
          ),
          if (_isLoading) const LinearProgressIndicator(),
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.grey[100],
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onSubmitted: (_) => _sendMessage(),
                    decoration: const InputDecoration(
                        hintText: "Ask about anything in PDF"),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
