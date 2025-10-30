import 'package:flutter/material.dart';

class LetterKey extends StatefulWidget {
  final String letter;
  final bool disabled;
  final VoidCallback onTap;

  const LetterKey({
    super.key,
    required this.letter,
    required this.disabled,
    required this.onTap,
  });

  @override
  State<LetterKey> createState() => _LetterKeyState();
}

class _LetterKeyState extends State<LetterKey> with SingleTickerProviderStateMixin {
  double _scale = 1.0;

  void _pressDown(_) => setState(() => _scale = 0.95);
  void _pressUp(_) => setState(() => _scale = 1.0);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTapDown: widget.disabled ? null : _pressDown,
      onTapUp: widget.disabled ? null : _pressUp,
      onTapCancel: () => setState(() => _scale = 1.0),
      onTap: widget.disabled ? null : widget.onTap,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 90),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: widget.disabled
                ? null
                : const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF7F6BF2), Color(0xFF9EA9FF)],
                  ),
            color: widget.disabled ? scheme.surfaceVariant : null,
            boxShadow: [
              if (!widget.disabled)
                BoxShadow(
                  color: Colors.black.withOpacity(.12),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
            ],
            border: Border.all(
              color: widget.disabled ? scheme.outlineVariant : Colors.white.withOpacity(.6),
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(
            widget.letter,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: .5,
              color: widget.disabled
                  ? scheme.onSurfaceVariant
                  : Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
