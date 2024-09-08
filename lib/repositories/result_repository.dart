import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ocrapp/helpers/permission_helper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../helpers/encryption_helper.dart';
import '../helpers/database_helper.dart';
import '../screens/detail_screen.dart'; // Import DetailScreen
import 'package:permission_handler/permission_handler.dart'; // Import permission_handler

class ResultRepository {
  final EncryptionHelper encryptionHelper = EncryptionHelper();
  final ImagePicker _picker = ImagePicker();
  String _storageOption = 'file'; // Default storage option

  Future<List<Map<String, dynamic>>> loadResults() async {
    List<Map<String, dynamic>> combinedResults = [];

    final db = await DatabaseHelper.getDatabase();
    List<Map<String, dynamic>> databaseResults = await db.query(
      'Results',
      orderBy: 'id DESC',
    );
    combinedResults.addAll(databaseResults);

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/results.json');
    if (await file.exists()) {
      String content = await file.readAsString();
      List<Map<String, dynamic>> fileData =
          List<Map<String, dynamic>>.from(json.decode(content));
      combinedResults.addAll(fileData);
    }

    return combinedResults;
  }

  Future<XFile?> pickImage(ImageSource source, BuildContext context) async {
    bool hasPermission = false;

    // Meminta izin sesuai dengan sumber gambar
    if (source == ImageSource.camera) {
      hasPermission = await _requestCameraPermission(context);
    } else if (source == ImageSource.gallery) {
      hasPermission = await _requestCameraPermission(context);
    }

    // Jika izin diberikan, lanjutkan pengambilan gambar
    if (hasPermission) {
      return await _picker.pickImage(source: source);
    } else {
      return null;
    }
  }

  // Request camera permission
  Future<bool> _requestCameraPermission(BuildContext context) async {
    bool hasPermission = await PermissionHelper.requestCameraPermission();
    if (!hasPermission) {
      // Tampilkan dialog untuk membuka pengaturan jika izin ditolak
      await _showAppSettingsDialog(
          context, 'Camera permission is required to proceed.');
    }
    return hasPermission;
  }

  Future<void> processImage(BuildContext context, XFile image) async {
    try {
      final inputImage = InputImage.fromFilePath(image.path);
      final textRecognizer = TextRecognizer();
      final recognizedText = await textRecognizer.processImage(inputImage);
      String rawText = recognizedText.text;
      String expression = _extractExpression(rawText);

      if (expression.isNotEmpty) {
        double result = _evaluateExpression(expression);

        String plainText = rawText;
        String plainExpression = expression;
        String plainResult = result.toString();
        String plainImagePath = image.path;

        await saveResult(
            plainText, plainExpression, plainResult, plainImagePath);

        // Navigasi ke DetailScreen setelah proses selesai
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailScreen(result: {
              'rawText': plainText,
              'expression': plainExpression,
              'result': plainResult,
              'imagePath': plainImagePath,
            }),
          ),
        );
      } else {
        _showErrorDialog(context, 'No valid expression found.');
      }
    } catch (e) {
      _showErrorDialog(context, 'Error processing image.');
    }
  }

  Future<void> saveResult(
    String plainText,
    String plainExpression,
    String plainResult,
    String plainImagePath,
  ) async {
    if (_storageOption == 'file') {
      await _saveResultToFile(
          plainText, plainExpression, plainResult, plainImagePath);
    } else {
      await _saveResultToDatabase(
          plainText, plainExpression, plainResult, plainImagePath);
    }
  }

  String _extractExpression(String text) {
    text = text.replaceAll('x', '*');
    final RegExp exp = RegExp(r'(\d+)\s*([+\-*/])\s*(\d+)');
    final match = exp.firstMatch(text);
    if (match != null) {
      String num1 = match.group(1)!;
      String operator = match.group(2)!;
      String num2 = match.group(3)!;
      return '$num1$operator$num2';
    }
    return '';
  }

  double _evaluateExpression(String expression) {
    final RegExp exp = RegExp(r'(\d+)([+\-*/])(\d+)');
    final match = exp.firstMatch(expression);

    if (match != null) {
      double num1 = double.parse(match.group(1)!);
      String operator = match.group(2)!;
      double num2 = double.parse(match.group(3)!);

      switch (operator) {
        case '+':
          return num1 + num2;
        case '-':
          return num1 - num2;
        case '*':
          return num1 * num2;
        case '/':
          return num2 != 0 ? num1 / num2 : 0;
        default:
          return 0;
      }
    }
    return 0;
  }

  Future<void> _saveResultToFile(
    String plainText,
    String plainExpression,
    String plainResult,
    String plainImagePath,
  ) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/results.json');
    List<Map<String, dynamic>> fileData = [];

    if (await file.exists()) {
      String content = await file.readAsString();
      fileData = List<Map<String, dynamic>>.from(json.decode(content));
    }

    fileData.add({
      'rawText': plainText,
      'expression': plainExpression,
      'result': plainResult,
      'imagePath': plainImagePath,
    });

    await file.writeAsString(json.encode(fileData));
  }

  Future<void> _saveResultToDatabase(
    String plainText,
    String plainExpression,
    String plainResult,
    String plainImagePath,
  ) async {
    final db = await DatabaseHelper.getDatabase();
    await db.insert('Results', {
      'rawText': plainText,
      'expression': plainExpression,
      'result': plainResult,
      'imagePath': plainImagePath,
    });
  }

  void _showErrorDialog(BuildContext context, String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Error"),
          content: Text(errorMessage),
          actions: [
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Fungsi untuk menampilkan dialog yang menawarkan membuka pengaturan aplikasi
  Future<void> _showAppSettingsDialog(
      BuildContext context, String message) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Permission Required"),
          content: Text(message),
          actions: [
            TextButton(
              child: Text("Open Settings"),
              onPressed: () {
                openAppSettings(); // Membuka pengaturan aplikasi
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
