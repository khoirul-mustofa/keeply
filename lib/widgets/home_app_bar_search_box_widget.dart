import 'package:flutter/material.dart';

class HomeAppBarSearchBoxWidget extends StatelessWidget {
  final VoidCallback onTap;

  const HomeAppBarSearchBoxWidget({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          children: [
            Icon(Icons.search, size: 20, color: Colors.black54),
            SizedBox(width: 8),
            Text(
              'Cari catatan...',
              style: TextStyle(color: Colors.black54, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
