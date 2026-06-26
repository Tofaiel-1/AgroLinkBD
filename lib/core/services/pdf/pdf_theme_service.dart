import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfThemeService {
  static const PdfColor primaryColor = PdfColor.fromInt(0xFF2E7D32); // AgroLinkBD Green
  static const PdfColor secondaryColor = PdfColor.fromInt(0xFF81C784);
  static const PdfColor backgroundColor = PdfColor.fromInt(0xFFF1F8E9);
  static const PdfColor textColor = PdfColor.fromInt(0xFF212121);
  static const PdfColor subtextColor = PdfColor.fromInt(0xFF757575);
  static const PdfColor tableHeaderColor = PdfColor.fromInt(0xFFE8F5E9);
  static const PdfColor borderColor = PdfColor.fromInt(0xFFE0E0E0);
  static const PdfColor white = PdfColor.fromInt(0xFFFFFFFF);

  static pw.ThemeData getTheme() {
    return pw.ThemeData.withFont(
      base: pw.Font.helvetica(),
      bold: pw.Font.helveticaBold(),
      italic: pw.Font.helveticaOblique(),
    );
  }
}
