/// Dart import
import 'dart:async';
import 'dart:io';
import 'dart:ui' as dart_ui;

/// Package imports
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

/// Barcode import
import 'package:syncfusion_flutter_barcodes/barcodes.dart';

/// Pdf import
import 'package:syncfusion_flutter_pdf/pdf.dart';

/// open file library import
import 'package:open_file/open_file.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: ExportBarcode(),
    );
  }
}

final GlobalKey<_BarcodeState> barcodeKey = GlobalKey();

///Export barcode class
class ExportBarcode extends StatefulWidget {
  const ExportBarcode({Key? key}) : super(key: key);

  @override
  _ExportBarcodeState createState() => _ExportBarcodeState();
}

class _ExportBarcodeState extends State<ExportBarcode> {
  _ExportBarcodeState();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Flutter barcode Export'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: <
                    Widget>[
              SizedBox(
                height: 300,
                width: 300,
                child: Barcode(
                  key: barcodeKey,
                ),
              ),
              const SizedBox(
                height: 100,
              ),
              Container(
                  width: 110,
                  color: Colors.green,
                  child: IconButton(
                    onPressed: () {
                      /// Snackbar messanger to indicate that the rendered barcode is being exported as PDF
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        behavior: SnackBarBehavior.floating,
                        duration: Duration(milliseconds: 2000),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(5))),
                        content:
                            Text('barcode is being exported as PDF document'),
                      ));
                      _renderPdf();
                    },
                    icon: Row(
                      children: const <Widget>[
                        Icon(Icons.picture_as_pdf, color: Colors.black),
                        Text('Export to pdf'),
                      ],
                    ),
                  )),
            ]),
          ),
        ));
  }

  Future<void> _renderPdf() async {
    // Create a new PDF document.
    final PdfDocument document = PdfDocument();
    // Create a pdf bitmap for the rendered barcode image.
    final PdfBitmap bitmap = PdfBitmap(await _readImageData());
    // set the necessary page settings for the pdf document such as margin, size etc..
    document.pageSettings.margins.all = 0;
    document.pageSettings.size =
        Size(bitmap.width.toDouble(), bitmap.height.toDouble());
    // Create a PdfPage page object and assign the pdf document's pages to it.
    final PdfPage page = document.pages.add();
    // Retrieve the pdf page client size
    final Size pageSize = page.getClientSize();
    // Draw an image into graphics using the bitmap.
    page.graphics.drawImage(
        bitmap, Rect.fromLTWH(0, 0, pageSize.width, pageSize.height));

    // Snackbar indication for barcode export operation
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(5))),
      duration: Duration(milliseconds: 200),
      content: Text('barcode has been exported as PDF document.'),
    ));
    //Save and dispose the document.
    final List<int> bytes = document.saveSync();
    document.dispose();

    //Get the external storage directory.
    Directory directory = (await getApplicationDocumentsDirectory());
    //Get the directory path.
    String path = directory.path;
    //Create an empty file to write the PDF data.
    File file = File('$path/output.pdf');
    //Write the PDF data.
    await file.writeAsBytes(bytes, flush: true);
    //Open the PDF document on mobile.
    OpenFile.open('$path/output.pdf');
  }

  /// Method to read the rendered barcode image and return the image data for processing.
  Future<List<int>> _readImageData() async {
    final dart_ui.Image data =
        await barcodeKey.currentState!.convertToImage(pixelRatio: 3.0);
    final ByteData? bytes =
        await data.toByteData(format: dart_ui.ImageByteFormat.png);
    return bytes!.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);
  }
}

class Barcode extends StatefulWidget {
  const Barcode({Key? key}) : super(key: key);

  @override
  _BarcodeState createState() => _BarcodeState();
}

class _BarcodeState extends State<Barcode> {
  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
        child: SfBarcodeGenerator(
            value: 'CODE128', showValue: true, symbology: Code128(module: 2)));
  }

  Future<dart_ui.Image> convertToImage({double pixelRatio = 1.0}) async {
    // Get the render object from context and store in the RenderRepaintBoundary onject.
    final RenderRepaintBoundary boundary =
        context.findRenderObject() as RenderRepaintBoundary;

    // Convert the repaint boundary as image
    final dart_ui.Image image = await boundary.toImage(pixelRatio: pixelRatio);

    return image;
  }
}
