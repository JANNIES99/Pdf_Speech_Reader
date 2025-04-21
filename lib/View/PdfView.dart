import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class Pdfview extends StatefulWidget {
  const Pdfview({required this.listOfText, super.key});
  final List<String> listOfText;

  @override
  State<Pdfview> createState() => _PdfviewState();
}

class _PdfviewState extends State<Pdfview> {
  late String ttsInput;
  FlutterTts flutterTts = FlutterTts();
  bool play = false;
  bool pause = true;
  int? currentWordStart;
  int? currentWordEnd;
  List<Map> voices = [];
  Map? currentVoice;
  final playIcon = Icon(Icons.play_arrow_rounded, color: Colors.black);
  final pauseIcon = Icon(Icons.pause_outlined, color: Colors.black);
  Icon currentIcon = Icon(Icons.play_arrow_rounded, color: Colors.black);
  @override
  void initState() {
    super.initState();
    initTTS();
  }

  void initTTS() {
    ttsInput = widget.listOfText[0];
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
    return Scaffold(
      appBar: AppBar(title: Text("PDF TTS View")),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: TextStyle(fontSize: 20, color: Colors.white),
                        children: <TextSpan>[
                          TextSpan(
                            text: ttsInput.substring(0, currentWordStart),
                          ),
                          if (currentWordStart != null)
                            TextSpan(
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.black,
                                backgroundColor: Colors.purpleAccent,
                              ),
                              text: ttsInput.substring(
                                currentWordStart!,
                                currentWordEnd,
                              ),
                            ),
                          if (currentWordEnd != null)
                            TextSpan(text: ttsInput.substring(currentWordEnd!)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            color: Colors.red,
            child: Column(
              children: [
                speakerSelector(),
                Row(
                  children: [
                    Container(
                      decoration: ShapeDecoration(
                        shape: CircleBorder(),
                        color: Colors.white,
                      ),
                      child: IconButton(
                        onPressed: () {
                          if (play && !pause) {
                            pause = !pause;
                            play = !play;
                            setState(() {
                              currentIcon = pauseIcon;
                            });
                          } else if (!play && pause) {
                            pause = !pause;
                            play = !play;
                          }
                        },
                        icon: currentIcon,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget speakerSelector() {
    return DropdownButton(
      dropdownColor: Colors.black,
      value: currentVoice,
      items:
          voices
              .map(
                (voice) => DropdownMenuItem(
                  value: voice,
                  child: Text(
                    voice["name"],
                    style: TextStyle(color: Colors.white),
                  ),
                ),
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
