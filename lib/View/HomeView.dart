import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf_image_renderer/pdf_image_renderer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image/image.dart' as imglib;

class Homeview extends StatefulWidget {
  const Homeview({super.key});

  @override
  State<Homeview> createState() => _HomeviewState();
}

class _HomeviewState extends State<Homeview> {
  List<String> listOfText = [];
  void pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'pdf', 'png'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      final sampleList = await pdfToText(file);
      setState(() {
        listOfText = sampleList;
      });
      print(file.path);
    } else {
      // User canceled the picker
    }
  }

  Future<List<String>> pdfToText(File pdfFile) async {
    final document = PdfImageRenderer(path: pdfFile.path);
    final List<File> imageFiles = <File>[];
    List<String> listOfText = [];
    await document.open();
    final int pageCount = await document.getPageCount();
    print("Page Count =$pageCount");
    for (int pageIndex = 0; pageIndex < pageCount; pageIndex++) {
      await document.openPage(pageIndex: pageIndex);
      final size = await document.getPageSize(pageIndex: pageIndex);
      print("Height =${size.height} , Width= ${size.width}");
      final imgBytes = await document.renderPage(
        pageIndex: pageIndex,
        x: 0,
        y: 0,
        width: size.width,
        height: size.height,
        scale: 1,
        background: Colors.white,
      );
      await document.closePage(pageIndex: pageIndex);
      if (imgBytes != null) {
        final decodedImage = imglib.decodeImage(imgBytes);
        final imageData = imglib.encodePng(decodedImage!);
        final tempDir = await getTemporaryDirectory();
        final imageFile = File('${tempDir.path}/page_$pageIndex.png');
        await imageFile.writeAsBytes(imageData);
        imageFiles.add(imageFile);
      }
    }
    await document.close();
    if (imageFiles.isNotEmpty) {
      listOfText = await recognizeTextFromImages(imageFiles);
    }
    return listOfText;
  }

  Future<List<String>> recognizeTextFromImages(List<File> imageFiles) async {
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final fileListSize = imageFiles.length;
    final List<String> listOfText = [];
    for (int index = 0; index < fileListSize; index++) {
      final inputImage = InputImage.fromFile(imageFiles[index]);
      try {
        final recognizedText = await textRecognizer.processImage(inputImage);
        final String text = recognizedText.text;
        listOfText.add(text);
      } on Exception catch (e) {
        print(e);
      }
    }
    print(listOfText);
    return listOfText;
  }

  Future _fileAccess() async {
    var status = await Permission.photos.status;
    if (status.isGranted) {
      pickFiles();
    } else {
      requestStorageAccess();
    }
  }

  void requestStorageAccess() async {
    var status = await Permission.photos.request();
    if (status.isGranted) {
      pickFiles();
    }
    if (status.isDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          margin: EdgeInsets.all(10),
          content: Text(
            "Storage Access Denied",
            style: TextStyle(color: Colors.black),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
    if (status.isPermanentlyDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          margin: EdgeInsets.all(10),
          content: Text(
            "Storage Access Permanently Denied",
            style: TextStyle(color: Colors.black),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Audio Reader"),
        backgroundColor: const Color.fromARGB(255, 220, 0, 0),
      ),
      backgroundColor: const Color.fromARGB(255, 255, 248, 220),
      body: Column(
        children: [
          if (listOfText.isEmpty)
            Text("Enter a File")
          else
            ...listOfText.map((text) {
              return Text(text);
            }),
        ],
      ),
      floatingActionButton: SizedBox(
        height: 70,
        width: 70,
        child: FloatingActionButton(
          onPressed: () {
            _fileAccess();
          },
          backgroundColor: const Color.fromARGB(255, 220, 0, 0),
          shape: CircleBorder(
            side: BorderSide(
              width: 15,
              color: const Color.fromARGB(255, 220, 0, 0),
            ),
          ),
          child: Icon(Icons.add, color: Colors.black, size: 30),
        ),
      ),
    );
  }
}
