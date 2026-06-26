import 'package:flutter/material.dart';

/// بطاقة عرض نتيجة واحدة من نتائج الحساب.
class ResultTile extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const ResultTile({
    super.key,
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: highlight ? const Color(0xFFECFDF5) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: highlight
              ? const Color(0xFF0F766E).withOpacity(0.25)
              : const Color(0xFFE5E7EB),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Color(0xFF667085), fontSize: 13),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF152238),
            ),
          ),
        ],
      ),
    );
  }
}
