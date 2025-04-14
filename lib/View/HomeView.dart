import 'dart:io';
import 'dart:ui';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf_render/pdf_render.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image/image.dart' as imglib;

class Homeview extends StatefulWidget {
  const Homeview({super.key});

  @override
  State<Homeview> createState() => _HomeviewState();
}

class _HomeviewState extends State<Homeview> {
  void pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'pdf', 'png'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      print(file.path);
    } else {
      // User canceled the picker
    }
  }

  Future<List<File>> pdfToImages(File pdfFile) async {
    final PdfDocument document = await PdfDocument.openFile(pdfFile.path);
    final int pageCount = document.pageCount;
    final List<File> imageFiles = <File>[];
    for (int pageIndex = 1; pageIndex <= pageCount; pageIndex++) {
      final PdfPage page = await document.getPage(pageIndex);
      final PdfPageImage imgPdf = await page.render();
      var img = await imgPdf.createImageDetached();
      final imgBytes = await img.toByteData(format: ImageByteFormat.png);
      if (imgBytes != null) {
        final libImage = imglib.decodeImage(
          imgBytes.buffer.asUint8List(
            imgBytes.offsetInBytes,
            imgBytes.lengthInBytes,
          ),
        );
        if (libImage != null) {
          final imgData = libImage.getBytes();
          final tempDir = await getTemporaryDirectory();
          final imageFile = File('${tempDir.path}/page_$pageIndex.png');
          await imageFile.writeAsBytes(imgData);
          imageFiles.add(imageFile);
        }
      }
    }
    return imageFiles;
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
      body: Column(children: []),
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
