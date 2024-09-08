import 'dart:io';
import 'package:flutter/material.dart';

class DetailScreen extends StatelessWidget {
  final Map<String, dynamic> result;

  const DetailScreen({super.key, required this.result});

  Widget _buildContainer(BuildContext context, String title, String? content) {
    final theme = Theme.of(context); // Ambil tema langsung dari ThemeData

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: theme.cardColor, // Gunakan warna dari tema
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            blurRadius: 4,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      width: double.infinity, // Mengatur lebar penuh
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ), // Gunakan gaya teks dari tema
          ),
          const SizedBox(height: 8),
          Text(
            content ?? 'No data available',
            style: theme.textTheme.bodyMedium, // Gunakan gaya teks dari tema
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Ambil tema langsung dari ThemeData

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Detail Hasil',
          style: theme.textTheme.titleLarge?.copyWith(color: Colors.white),
        ),
      ),
      backgroundColor: theme.scaffoldBackgroundColor, // Ambil warna dari tema
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildContainer(context, 'Raw Text', result['rawText']),
              _buildContainer(context, 'Expression', result['expression']),
              _buildContainer(context, 'Result', result['result']),
              const SizedBox(height: 16),
              result['imagePath'] != null &&
                      File(result['imagePath']).existsSync()
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(result['imagePath'].replaceAll('.enc', '')),
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Center(
                      child: Text(
                        'No image available',
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: Colors.grey),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
