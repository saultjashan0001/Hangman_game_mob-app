import 'package:flutter/material.dart';

class GuessedLettersStrip extends StatelessWidget {
  final Iterable<String> letters;
  const GuessedLettersStrip({super.key, required this.letters});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final chips = letters.map((l) {
      return Chip(
        label: Text(l, style: const TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: scheme.primaryContainer.withOpacity(.7),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 6),
        visualDensity: VisualDensity.compact,
      );
    }).toList();

    if (chips.isEmpty) {
      return const Text('No letters guessed yet.');
    }

    return Wrap(
      spacing: 6,
      runSpacing: -6,
      children: chips,
    );
  }
}
