import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:imrpo/core/models/parsed_financial_entry.dart';
import 'package:imrpo/core/services/currency_preferences.dart';
import 'package:imrpo/core/services/service_locator.dart';
import 'package:imrpo/core/services/transaction_text_parser.dart';

class InvoiceOcrService {
  final TextRecognizer _latinRecognizer =
      TextRecognizer(script: TextRecognitionScript.latin);

  Future<ParsedFinancialEntry> scanImage(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final latinResult = await _latinRecognizer.processImage(inputImage);
    var text = latinResult.text.trim();

    if (text.length < 8) {
      final defaultRecognizer = TextRecognizer();
      try {
        final fallback = await defaultRecognizer.processImage(inputImage);
        if (fallback.text.trim().length > text.length) {
          text = fallback.text.trim();
        }
      } finally {
        defaultRecognizer.close();
      }
    }

    if (text.isEmpty) {
      return ParsedFinancialEntry(
        type: FinancialEntryType.expense,
        rawText: '',
      );
    }

    return TransactionTextParser.parse(
      text,
      defaultCurrencyCode: getIt<CurrencyPreferences>().displayCode,
    );
  }

  void dispose() {
    _latinRecognizer.close();
  }
}
