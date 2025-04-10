import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:pdfaudioreader/consts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  FlutterTts flutterTts = FlutterTts();
  int? currentWordStart;
  int? currentWordEnd;
  List<Map> voices = [];
  Map? currentVoice;
  @override
  void initState() {
    super.initState();
    initTTS();
  }

  void initTTS() {
    flutterTts.setProgressHandler((text, start, end, word) {
      setState(() {
        currentWordStart = start;
        currentWordEnd = end;
      });
    });
    flutterTts.getVoices.then((data) {
      try {
        voices = List<Map>.from(data);
        voices = voices.where((voice) => voice["name"].contains("en")).toList();
        print(voices);
        setState(() {
          currentVoice = voices.first;
          setVoice(currentVoice!);
        });
      } catch (e) {
        print(e);
      }
    });
  }

  void setVoice(Map voice) {
    flutterTts.setVoice({"name": voice["name"], "locale": voice["locale"]});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              speakerSelector(),
              RichText(
                text: TextSpan(
                  style: TextStyle(fontSize: 20, color: Colors.black),
                  children: <TextSpan>[
                    TextSpan(text: TTS_Input.substring(0, currentWordStart)),
                    if (currentWordStart != null)
                      TextSpan(
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          backgroundColor: Colors.deepPurple,
                        ),
                        text: TTS_Input.substring(
                          currentWordStart!,
                          currentWordEnd,
                        ),
                      ),
                    if (currentWordEnd != null)
                      TextSpan(text: TTS_Input.substring(currentWordEnd!)),
                  ],
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            flutterTts.speak(TTS_Input);
          },
          child: Icon(Icons.speaker),
        ),
      ),
    );
  }

  Widget speakerSelector() {
    return DropdownButton(
      value: currentVoice,
      items:
          voices
              .map(
                (voice) =>
                    DropdownMenuItem(value: voice, child: Text(voice["name"])),
              )
              .toList(),
      onChanged: (voice) {
        setState(() {
          currentVoice = voice;
          setVoice(currentVoice!);
        });
      },
    );
  }
}
