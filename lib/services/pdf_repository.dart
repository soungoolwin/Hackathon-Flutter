import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:syncfusion_flutter_pdf/pdf.dart';

class PdfRepository {
  static final PdfRepository _instance = PdfRepository._internal();
  factory PdfRepository() => _instance;
  PdfRepository._internal();

  String _pdfText = "";
  final String pdfAssetPath = 'assets/fakedata.pdf';

  /// Loads fakedata.pdf from assets, extracts all text using Syncfusion
  Future<void> loadPdfAndExtract() async {
    // 1) Load PDF bytes from assets
    final pdfData = await rootBundle.load(pdfAssetPath);
    final Uint8List bytes = pdfData.buffer
        .asUint8List(pdfData.offsetInBytes, pdfData.lengthInBytes);

    // 2) Create a PdfDocument from these bytes
    final PdfDocument document = PdfDocument(inputBytes: bytes);

    // 3) Extract text
    _pdfText = PdfTextExtractor(document).extractText();

    // 4) Dispose the document from memory
    document.dispose();
  }

  /// The entire extracted PDF text as a single string
  String get allPdfText => _pdfText;
}
