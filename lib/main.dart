import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Math Expression OCR',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MathOcrScreen(),
    );
  }
}

class MathOcrScreen extends StatefulWidget {
  @override
  _MathOcrScreenState createState() => _MathOcrScreenState();
}

class _MathOcrScreenState extends State<MathOcrScreen> {
  final ImagePicker _picker = ImagePicker();
  String _ocrRawText = "Hasil OCR mentah akan muncul di sini";
  String _ocrResult = "Hasil Ekspresi akan muncul di sini";
  String _calculatedResult = "";

  Future<void> _pickImage(ImageSource source) async {
    XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      await _performOcr(image.path);
    }
  }

  Future<void> _performOcr(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final textRecognizer = GoogleMlKit.vision.textRecognizer();
    final RecognizedText recognizedText =
        await textRecognizer.processImage(inputImage);

    // Tampilkan hasil OCR mentah
    String ocrRawText = recognizedText.text;

    // Ekstrak hanya teks yang berisi angka dan operator matematika
    String ocrResult = _extractFirstMathExpression(ocrRawText);

    // Bersihkan spasi dari ekspresi
    ocrResult = ocrResult.replaceAll(' ', '');

    // Evaluasi ekspresi matematika
    String result = _evaluateExpression(ocrResult);

    setState(() {
      _ocrRawText =
          ocrRawText.isNotEmpty ? ocrRawText : "Tidak ada teks yang terbaca.";
      _ocrResult = ocrResult.isNotEmpty
          ? ocrResult
          : "Tidak ada ekspresi matematika yang terbaca.";
      _calculatedResult =
          result.isNotEmpty ? "Hasil: $result" : "Ekspresi tidak valid.";
    });

    textRecognizer.close();
  }

  // Ekstrak hanya ekspresi matematika pertama
  String _extractFirstMathExpression(String text) {
    final regex = RegExp(r'\d+[+\-*/]\d+');
    final match = regex.firstMatch(text);
    return match?.group(0) ?? '';
  }

  // Evaluasi ekspresi matematika
  String _evaluateExpression(String expression) {
    try {
      final regex = RegExp(r'(\d+)([+\-*/])(\d+)');
      final match = regex.firstMatch(expression);
      if (match != null) {
        final num1 = double.parse(match.group(1)!);
        final operator = match.group(2)!;
        final num2 = double.parse(match.group(3)!);

        switch (operator) {
          case '+':
            return (num1 + num2).toString();
          case '-':
            return (num1 - num2).toString();
          case '*':
            return (num1 * num2).toString();
          case '/':
            return (num1 / num2).toString();
          default:
            return 'Operator tidak valid';
        }
      }
      return 'Ekspresi tidak valid';
    } on FormatException {
      return 'Ekspresi tidak valid';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Math Expression OCR'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () => _pickImage(ImageSource.camera),
              child: Text('Ambil Gambar dari Kamera'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _pickImage(ImageSource.gallery),
              child: Text('Pilih Gambar dari Galeri'),
            ),
            SizedBox(height: 16),
            Text(
              'Hasil OCR Mentah:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  _ocrRawText,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Hasil Ekspresi:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  _ocrResult,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            SizedBox(height: 10),
            Text(
              _calculatedResult,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green),
            ),
          ],
        ),
      ),
    );
  }
}
