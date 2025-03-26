import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hackathon/services/pdf_repository.dart';

class GeminiAiService {
  final PdfRepository _pdfRepo;

  // Use your real API key
  static const String _apiKey = "AIzaSyBPOHkP2UbaDKyykFL3PrJgQ6_GleRIWc0";

  // Endpoint from your snippet:
  static const String _geminiUrl =
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$_apiKey";

  GeminiAiService(this._pdfRepo);

  /// Called from your chat screen: pass the user's question
  Future<String> askGemini(String userQuestion) async {
    // 1) Grab PDF text from PDF repository
    final pdfText = _pdfRepo.allPdfText;

    // 2) Build big prompt with entire PDF + question
    final prompt = """
Please answer the user's question based on the following PDF text only. This is our datasets. Please answer questions only concern with this dataset. but should reply general answer suitable with general questions like “hello, Hi, Thank you” like this general words. Don’t tell like, “from your PDF” “based on PDF”. if you can’t answer based on this dataset. just answer sorry. For everytime, every questions, don't never give raw json. please asuume you are human and helping executive team. Please connect with previous questions. for example "user ask how many birthday person on 27 March", for exmaple you answer 3. and user ask "who", you should answer connected with previous question.

PDF text:
$pdfText

User question: $userQuestion
""";

    // 3) JSON body for Gemini
    final requestBody = {
      "contents": [
        {
          "parts": [
            {"text": prompt}
          ]
        }
      ]
    };

    // 4) POST request
    try {
      final httpResponse = await http.post(
        Uri.parse(_geminiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      if (httpResponse.statusCode == 200) {
        // 5) Parse the JSON
        final responseMap =
            json.decode(httpResponse.body) as Map<String, dynamic>;

        // Per your new result, Gemini's returning something like:
        // {
        //   "candidates": [
        //     {
        //       "content": {
        //         "parts": [
        //           { "text": "Hello, I'm Gemini..." }
        //         ]
        //       },
        //       "finishReason": "STOP",
        //       ...
        //     }
        //   ],
        //   "usageMetadata": {...},
        //   "modelVersion": "gemini-2.0-flash"
        // }

        if (responseMap.containsKey("candidates") &&
            responseMap["candidates"] is List) {
          final candidates = responseMap["candidates"] as List<dynamic>;

          if (candidates.isNotEmpty && candidates[0] is Map) {
            final firstCandidate = candidates[0] as Map<String, dynamic>;

            // The "content" object with "parts"
            if (firstCandidate.containsKey("content") &&
                firstCandidate["content"] is Map) {
              final contentMap =
                  firstCandidate["content"] as Map<String, dynamic>;

              if (contentMap.containsKey("parts") &&
                  contentMap["parts"] is List) {
                final parts = contentMap["parts"] as List<dynamic>;

                if (parts.isNotEmpty && parts[0] is Map) {
                  final text = parts[0]["text"] ?? "No 'text' in first part";
                  return text;
                }
              }
            }
          }
        }
        // If we get here, structure not found
        return "Gemini returned an unexpected JSON structure: $responseMap";
      } else {
        // Non-200 response
        return "Gemini error: ${httpResponse.statusCode} ${httpResponse.reasonPhrase}\n${httpResponse.body}";
      }
    } catch (e) {
      return "Error calling Gemini API: $e";
    }
  }
}
