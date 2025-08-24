import 'package:flutter/material.dart';

class RSectionTitle extends StatelessWidget {
  const RSectionTitle(this.title, {super.key});
  final String title;
  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
