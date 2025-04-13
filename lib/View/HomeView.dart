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
      appBar: AppBar(title: Text("Audio Reader"), backgroundColor: Colors.red),
      body: Column(children: []),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.red,
        shape: CircleBorder(side: BorderSide(width: 15, color: Colors.red)),
        child: Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}
