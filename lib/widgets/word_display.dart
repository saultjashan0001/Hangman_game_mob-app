import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WordDisplay extends StatelessWidget {
  final String maskedWord;
  const WordDisplay({super.key, required this.maskedWord});

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      child: Text(
        maskedWord,
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(
          letterSpacing: 10,
          fontSize: 44,
          fontWeight: FontWeight.w800,
          color: Colors.black.withOpacity(.85),
          shadows: [
            Shadow(color: Colors.white.withOpacity(.8), blurRadius: 10),
          ],
        ),
      ),
    );
  }
}
