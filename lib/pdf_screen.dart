import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfScreen extends StatefulWidget {
  @override
  _PdfScreenState createState() => _PdfScreenState();
}

class _PdfScreenState extends State<PdfScreen> {
  String pdfFile = '';
  var pdf = pw.Document();

  static const List<String> assetImages = [
    'assets/images/kitten1.png',
    'assets/images/kitten2.jpg',
    'assets/images/kitten3.jpg'
  ];
  List<Uint8List> imagesUint8list = [];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Visibility(
                    visible: pdfFile.isNotEmpty,
                    child: SfPdfViewer.file(File(pdfFile),
                        canShowScrollHead: false, canShowScrollStatus: false),
                  ),
                ),
              ),
              TextButton(
                  onPressed: () async {
                    await createPdfFile();
                    savePdfFile();
                  },
                  child: Text('Create a Pdf')),
            ],
          ),
        ),
      ),
    );
  }

  getImageBytes(String assetImage) async {
    final ByteData bytes = await rootBundle.load(assetImage);
    final Uint8List byteList = bytes.buffer.asUint8List();
    imagesUint8list.add(byteList);
    print(imagesUint8list.length);
  }

  createPdfFile() async {
    //convert each image to Uint8List
    for (String image in assetImages) await getImageBytes(image);
    //create a list of images
    final List<pw.Widget> pdfImages = imagesUint8list.map((image) {
      return pw.Padding(
          padding: pw.EdgeInsets.symmetric(vertical: 20, horizontal: 10),
          child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              mainAxisSize: pw.MainAxisSize.max,
              children: [
                pw.Text(
                    'Image'
                            ' ' +
                        (imagesUint8list
                                    .indexWhere((element) => element == image) +
                                1)
                            .toString(),
                    style: pw.TextStyle(fontSize: 22)),
                pw.SizedBox(height: 10),
                pw.Image(
                    pw.MemoryImage(
                      image,
                    ),
                    height: 400,
                    fit: pw.BoxFit.fitHeight)
              ]));
    }).toList();

    //create PDF
    pdf.addPage(pw.MultiPage(
        margin: pw.EdgeInsets.all(10),
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return <pw.Widget>[
            pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                mainAxisSize: pw.MainAxisSize.min,
                children: [
                  pw.Text('Create a Simple PDF',
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(fontSize: 26)),
                  pw.Divider(),
                ]),
            pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                mainAxisSize: pw.MainAxisSize.max,
                children: pdfImages),
          ];
        }));
  }

  savePdfFile() async {
    Directory documentDirectory = await getApplicationDocumentsDirectory();

    String documentPath = documentDirectory.path;

    String id = DateTime.now().toString();

    File file = File("$documentPath/$id.pdf");

    file.writeAsBytesSync(await pdf.save());
    setState(() {
      pdfFile = file.path;
      pdf = pw.Document();
    });
  }
}
