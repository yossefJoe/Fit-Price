import 'package:flutter/material.dart';
import 'package:one_shot/colors_manager.dart';
import 'package:one_shot/result_model.dart';

class ResultCard extends StatelessWidget {
  const ResultCard({Key? key, required this.result}) : super(key: key);
  final ResultModel result;
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.black26,
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (result.imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  result.imageUrl!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.contain,
                ),
              ),
            const SizedBox(height: 8),
            Text(
              result.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            if (result.snippet.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(result.snippet),
            ],
            const SizedBox(height: 8),
            Text(result.link, style: const TextStyle(color: Colors.blue)),
          ],
        ),
      ),
    );
  }
}
