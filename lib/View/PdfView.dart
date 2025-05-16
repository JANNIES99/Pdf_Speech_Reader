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
  double pitch = 1.0;
  double speechRate = 1.0;
  int previousWordStart = 0;
  int previousWordEnd = 0;
  int? currentWordStart;
  int? currentWordEnd;
  List<Map> voices = [];
  Map? currentVoice;
  final Icon playIcon = Icon(
    Icons.play_arrow_rounded,
    size: 40,
    color: Colors.black,
  );
  final Icon pauseIcon = Icon(
    Icons.pause_outlined,
    size: 40,
    color: Colors.black,
  );
  Icon currentIcon = Icon(
    Icons.play_arrow_rounded,
    size: 40,
    color: Colors.black,
  );
  @override
  void initState() {
    super.initState();
    initTTS();
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  void initTTS() {
    print("Hello");
    ttsInput = widget.listOfText[0];
    flutterTts.setProgressHandler((text, start, end, word) {
      setState(() {
        currentWordStart = previousWordStart + start;
        currentWordEnd = previousWordStart + end;
      });
    });
    flutterTts.getVoices.then((data) {
      try {
        voices = List<Map>.from(data);
        voices = voices.where((voice) => voice["name"].contains("en")).toList();
        setState(() {
          currentVoice = voices.first;
          setVoice(currentVoice!);
        });
      } catch (e) {
        String exceptionMessage = "";
        if (e.toString().length > 30) {
          exceptionMessage = "${e.toString().substring(0, 30)}...";
        }
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: Duration(seconds: 3),
            backgroundColor: Colors.red,
            margin: EdgeInsets.all(10),
            content: Text(
              exceptionMessage,
              style: TextStyle(color: Colors.black),
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
  }
//f
  Future<void> startManager(String text) async {
    if (!play && pause) {
      pause = !pause;
      play = !play;
      await flutterTts.speak(ttsInput.substring(previousWordStart));
      setState(() {
        currentIcon = pauseIcon;
      });
    }
  }

  Future<void> pauseManager() async {
    if (play && !pause) {
      pause = !pause;
      play = !play;
      await flutterTts.pause();
      setState(() {
        currentIcon = playIcon;
        previousWordStart = currentWordStart ?? 0;
        previousWordEnd = currentWordEnd ?? 0;
      });
    }
  }

  void setVoice(Map voice) async {
    await flutterTts.setVoice({
      "name": voice["name"],
      "locale": voice["locale"],
    });
  }

  void voiceManager(Map voice) async {
    final bool tempPause = pause;
    final bool tempPlay = play;
    await pauseManager();
    await flutterTts.setVoice({
      "name": voice["name"],
      "locale": voice["locale"],
    });
    if (tempPlay && !tempPause) {
      await startManager(ttsInput.substring(previousWordStart));
    }
  }

  void pitchManager(double pitch) async {
    final bool tempPause = pause;
    final bool tempPlay = play;
    await pauseManager();
    await flutterTts.setPitch(pitch);
    if (tempPlay && !tempPause) {
      await startManager(ttsInput.substring(previousWordStart));
    }
  }

  void speechRateManager(double speechRate) async {
    final bool tempPause = pause;
    final bool tempPlay = play;
    await pauseManager();
    await flutterTts.setSpeechRate(speechRate);
    if (tempPlay && !tempPause) {
      await startManager(ttsInput.substring(previousWordStart));
    }
  }

  void replayManager() async {
    final bool tempPause = pause;
    final bool tempPlay = play;
    await pauseManager();
    setState(() {
      previousWordStart = 0;
      previousWordEnd = 0;
    });
    if (tempPlay && !tempPause) {
      await startManager(ttsInput.substring(previousWordStart));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SelectableText.rich(
                        contextMenuBuilder: (context, editableTextState) {
                          return AdaptiveTextSelectionToolbar.buttonItems(
                            buttonItems:
                                editableTextState.contextMenuButtonItems,
                            anchors: editableTextState.contextMenuAnchors,
                          );
                        },
                        TextSpan(
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
                              TextSpan(
                                text: ttsInput.substring(currentWordEnd!),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(5),
              width: double.infinity,
              color: Colors.red,
              child: Column(
                children: [
                  speakerSelector(),
                  const SizedBox(height: 5),
                  GestureDetector(
                    onTap: () {
                      if (play && !pause) {
                        pauseManager();
                      } else if (!play && pause) {
                        startManager(ttsInput.substring(previousWordStart));
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: ShapeDecoration(
                        shape: CircleBorder(),
                        color: Colors.white,
                      ),
                      child: currentIcon,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Expanded(
                        child: Slider(
                          value: pitch,
                          onChanged: (newRating) {
                            setState(() {
                              pitch = newRating;
                              flutterTts.setPitch(pitch);
                            });
                          },
                          min: 0.5,
                          max: 2.0,
                          divisions: 6,
                          label: "Pitch:$pitch",
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.replay_rounded, color: Colors.black),
                      ),
                      Expanded(
                        child: Slider(
                          value: speechRate,
                          onChanged: (newRating) {
                            setState(() {
                              speechRate = newRating;
                              flutterTts.setSpeechRate(speechRate);
                            });
                          },
                          min: 0.0,
                          max: 2.0,
                          divisions: 8,
                          label: "Speech Rate:$speechRate",
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
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
          voiceManager(currentVoice!);
        });
      },
    );
  }
}
