import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:lottie/lottie.dart';
import 'package:temp/chat_input_box.dart';

class SectionTextStreamInput extends StatefulWidget {
  const SectionTextStreamInput({super.key});

  @override
  State<SectionTextStreamInput> createState() => _SectionTextInputStreamState();
}

class _SectionTextInputStreamState extends State<SectionTextStreamInput> {
  final controller = TextEditingController();
  final gemini = Gemini.instance;
  String? searchedText,
      _finishReason;

  String? get finishReason => _finishReason;

  set finishReason(String? set) {
    if (set != _finishReason) {
      setState(() => _finishReason = set);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (searchedText != null)
          MaterialButton(
              color: Colors.blue.shade700,
              onPressed: () {
                setState(() {
                  searchedText = null;
                  finishReason = null;
                  // result = null;
                });
              },
              child: Text('search: $searchedText')),
        Expanded(child: GeminiResponseTypeView(
          builder: (context, child, response, loading) {
            if (loading) {
              return Lottie.asset('assets/lottie/ai.json');
            }

            if (response != null) {
              return Markdown(
                data: response,
                selectable: true,
              );
            } else {
              return const Center(child: Text('Search something!'));
            }
          },
        )),

        /// if the returned finishReason isn't STOP
        if (finishReason != null) Text(finishReason!),

       
        ChatInputBox(
          controller: controller,
          onSend: () {
            if (controller.text.isNotEmpty) {
              print('request');

              searchedText = controller.text;
              controller.clear();
              gemini
                  .streamGenerateContent(searchedText!)
                  .handleError((e) {
                if (e is GeminiException) {
                  print(e);
                }
              }).listen((value) {
                if (value.finishReason != 'STOP') {
                  finishReason = 'Finish reason is `${value.finishReason}`';
                }
              });
            }
          },
        )
      ],
    );
  }
}
