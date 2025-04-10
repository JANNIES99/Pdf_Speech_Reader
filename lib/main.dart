import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

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
  Map? currentVoice;
  @override
  void initState() {
    super.initState();
    initTTS();
  }

  void initTTS() {
    flutterTts.getVoices.then((data) {
      try {
        List<Map> voices = List<Map>.from(data);
        print(voices);
        setState(() {});
      } catch (e) {
        print(e);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
