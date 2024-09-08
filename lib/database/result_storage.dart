import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../models/result_model.dart';
import '../helpers/encryption_helper.dart';

class ResultStorage {
  final EncryptionHelper encryptionHelper = EncryptionHelper();

  // Save result to file system with encryption
  Future<void> saveResultToFile(String rawText, String expression,
      String result, String imagePath) async {
    try {
      final encryptedText = encryptionHelper.encryptText(rawText);
      final encryptedExpression = encryptionHelper.encryptText(expression);
      final encryptedResult = encryptionHelper.encryptText(result);
      final encryptedImagePath =
          await encryptionHelper.encryptFile(File(imagePath));

      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/results.json');

      List<Map<String, dynamic>> fileData = [];

      if (await file.exists()) {
        String content = await file.readAsString();
        fileData = List<Map<String, dynamic>>.from(json.decode(content));
      }

      fileData.add({
        'rawText': encryptedText,
        'expression': encryptedExpression,
        'result': encryptedResult,
        'imagePath': encryptedImagePath,
      });

      await file.writeAsString(json.encode(fileData));
    } catch (e) {
      print('Error saving result to file: $e');
    }
  }

  // Save result to SQLite database with encryption
  Future<void> saveResultToDatabase(String rawText, String expression,
      String result, String imagePath) async {
    try {
      final encryptedText = encryptionHelper.encryptText(rawText);
      final encryptedExpression = encryptionHelper.encryptText(expression);
      final encryptedResult = encryptionHelper.encryptText(result);
      final encryptedImagePath =
          await encryptionHelper.encryptFile(File(imagePath));

      final db = await getDatabase();
      await db.insert('Results', {
        'rawText': encryptedText,
        'expression': encryptedExpression,
        'result': encryptedResult,
        'imagePath': encryptedImagePath,
      });
    } catch (e) {
      print('Error saving result to database: $e');
    }
  }

  // Load results from both file system and database with decryption
  Future<List<ResultModel>> loadResults() async {
    List<ResultModel> combinedResults = [];

    try {
      // Load from SQLite
      final db = await getDatabase();
      List<Map<String, dynamic>> databaseResults = await db.query(
        'Results',
        orderBy: 'id DESC',
      );
      combinedResults.addAll(databaseResults.map((e) {
        return ResultModel(
          rawText: encryptionHelper.decryptText(e['rawText']),
          expression: encryptionHelper.decryptText(e['expression']),
          result: encryptionHelper.decryptText(e['result']),
          imagePath:
              e['imagePath'], // Assuming image path does not need decryption
        );
      }));

      // Load from file system
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/results.json');
      if (await file.exists()) {
        String content = await file.readAsString();
        List<Map<String, dynamic>> fileData =
            List<Map<String, dynamic>>.from(json.decode(content));
        combinedResults.addAll(fileData.map((e) {
          return ResultModel(
            rawText: encryptionHelper.decryptText(e['rawText']),
            expression: encryptionHelper.decryptText(e['expression']),
            result: encryptionHelper.decryptText(e['result']),
            imagePath:
                e['imagePath'], // Assuming image path does not need decryption
          );
        }));
      }
    } catch (e) {
      print('Error loading results: $e');
    }

    return combinedResults;
  }

  // SQLite database initialization
  Future<Database> getDatabase() async {
    return openDatabase(
      'results.db',
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute(
          'CREATE TABLE Results (id INTEGER PRIMARY KEY AUTOINCREMENT, rawText TEXT, expression TEXT, result TEXT, imagePath TEXT)',
        );
      },
    );
  }
}
