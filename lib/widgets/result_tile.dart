import 'dart:io';
import 'package:flutter/material.dart';
import '../screens/detail_screen.dart';

class ResultTile extends StatelessWidget {
  final Map<String, dynamic> result;

  const ResultTile({required this.result});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: ListTile(
        contentPadding: const EdgeInsets.all(8), // Mengurangi padding
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Perhitungan: ${result['expression']}',
              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                  color: Colors.black87), // Warna lebih gelap untuk keterbacaan
            ),
            const SizedBox(height: 4), // Jarak kecil antara teks
            Text(
              'Result: ${result['result']}',
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  fontWeight:
                      FontWeight.normal), // Menambah ketebalan untuk "Result"
            ),
          ],
        ),
        leading: result['imagePath'] != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(result['imagePath'].replaceAll('.enc', '')),
                  width: 60,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              )
            : const Icon(Icons.image_not_supported,
                size: 50), // Placeholder jika gambar tidak ada
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailScreen(result: result),
            ),
          );
        },
      ),
    );
  }
}
