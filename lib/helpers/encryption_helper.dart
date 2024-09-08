import 'dart:io';

import 'package:encrypt/encrypt.dart' as encrypt;

class EncryptionHelper {
  final _key = encrypt.Key.fromLength(32); // Panjang kunci AES (32 bytes)
  final _iv = encrypt.IV.fromLength(16); // Panjang IV untuk AES

  // Enkripsi teks
  String encryptText(String plainText) {
    final encrypter = encrypt.Encrypter(encrypt.AES(_key));
    final encrypted = encrypter.encrypt(plainText, iv: _iv);
    return encrypted.base64;
  }

  // Dekripsi teks
  String decryptText(String encryptedText) {
    final encrypter = encrypt.Encrypter(encrypt.AES(_key));
    final decrypted = encrypter.decrypt64(encryptedText, iv: _iv);
    return decrypted;
  }

  // Enkripsi file
  Future<String> encryptFile(File file) async {
    final bytes = await file.readAsBytes();
    final encrypter = encrypt.Encrypter(encrypt.AES(_key));
    final encryptedBytes = encrypter.encryptBytes(bytes, iv: _iv);
    final encryptedFilePath = '${file.path}.enc';
    final encryptedFile = File(encryptedFilePath);
    await encryptedFile.writeAsBytes(encryptedBytes.bytes);
    return encryptedFilePath;
  }

  // Dekripsi file
  Future<File> decryptFile(String encryptedFilePath) async {
    final encryptedFile = File(encryptedFilePath);
    final encryptedBytes = await encryptedFile.readAsBytes();
    final encrypter = encrypt.Encrypter(encrypt.AES(_key));
    final decryptedBytes =
        encrypter.decryptBytes(encrypt.Encrypted(encryptedBytes), iv: _iv);
    final decryptedFilePath = encryptedFilePath.replaceAll('.enc', '');
    final decryptedFile = File(decryptedFilePath);
    await decryptedFile.writeAsBytes(decryptedBytes);
    return decryptedFile;
  }
}
