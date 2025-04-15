import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
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
    final List<Uint8List> imageByteList = [];
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
        imageByteList.add(imgBytes);
      }
    }
    await document.close();
    if (imageByteList.isNotEmpty) {
      listOfText = await recognizeTextFromImages(imageByteList);
    }
    return listOfText;
  }

  Future<List<String>> recognizeTextFromImages(
    List<Uint8List> imageFiles,
  ) async {
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final fileListSize = imageFiles.length;
    final List<String> listOfText = [];
    for (int index = 0; index < fileListSize; index++) {
      final decodedImage = imglib.decodeImage(imageFiles[index]);
      final imageBytes = imglib.encodePng(decodedImage!);
      final inputImage = InputImage.fromBytes(
        bytes: Uint8List.fromList(imageBytes),
        metadata: InputImageMetadata(
          size: Size(
            decodedImage.width.toDouble(),
            decodedImage.height.toDouble(),
          ),
          rotation: InputImageRotation.rotation0deg,
          format: InputImageFormat.bgra8888,
          bytesPerRow: decodedImage.width * 4,
        ),
      );
      final recognizedText = await textRecognizer.processImage(inputImage);
      final String text = recognizedText.text;
      listOfText.add(text);
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
