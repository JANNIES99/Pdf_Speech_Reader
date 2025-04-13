import 'package:flutter/material.dart';

class Homeview extends StatefulWidget {
  const Homeview({super.key});

  @override
  State<Homeview> createState() => _HomeviewState();
}

class _HomeviewState extends State<Homeview> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Audio Reader"),
        backgroundColor: const Color.fromARGB(255, 220, 0, 0),
      ),
      backgroundColor: const Color.fromARGB(255, 255, 248, 220),
      body: Column(children: []),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color.fromARGB(255, 220, 0, 0),
        shape: CircleBorder(
          side: BorderSide(
            width: 15,
            color: const Color.fromARGB(255, 220, 0, 0),
          ),
        ),
        child: Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}
