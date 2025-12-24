// pages/not_detay_sayfasi.dart
import 'package:flutter/material.dart';
import '../models/note_model.dart';

/// Detailed note page with scrollable content
class NotDetaySayfasi extends StatelessWidget {
  final Not not;

  const NotDetaySayfasi({super.key, required this.not});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          not.baslik.isEmpty ? 'Note Detail' : not.baslik,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: Container(
        color: not.renk.withOpacity(0.15),
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // Align left
            children: [
              if (not.baslik.isNotEmpty)
                Text(
                  not.baslik,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              const SizedBox(height: 16),
              Text(
                not.icerik,
                style: const TextStyle(fontSize: 16, height: 1.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
