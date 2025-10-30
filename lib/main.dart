import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confetti/confetti.dart';

import 'game_state.dart';
import 'widgets/word_display.dart';
import 'widgets/letter_key.dart';
import 'widgets/guessed_letters_strip.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => GameState(),
      child: const HangmanApp(),
    ),
  );
}

class HangmanApp extends StatelessWidget {
  const HangmanApp({super.key});

  @override
  Widget build(BuildContext context) {
    final base = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6C5CE7)),
      useMaterial3: true,
      textTheme: GoogleFonts.poppinsTextTheme(),
    );

    return MaterialApp(
      title: 'Guess the Word (Hangman)',
      debugShowCheckedModeBanner: false,
      theme: base.copyWith(
        appBarTheme: AppBarTheme(
          centerTitle: true,
          elevation: 0,
          titleTextStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: base.colorScheme.onSurface,
          ),
          backgroundColor: Colors.transparent,
        ),
      ),
      home: const GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final ConfettiController _confetti;
  GameStatus? _lastStatus;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameState>();

    // status text
    String statusText;
    if (game.status == GameStatus.won) {
      statusText = '🎉 YOU WON!';
    } else if (game.status == GameStatus.lost) {
      statusText = '😢 YOU LOST!';
    } else {
      statusText = 'Keep guessing!';
    }

    // fire confetti when just won
    if (_lastStatus != game.status && game.status == GameStatus.won) {
      _confetti.play();
    }
    _lastStatus = game.status;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Guess the Word'),
        backgroundColor: Colors.transparent,
      ),
      body: Stack(
        children: [
          // gradient bg
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF6C5CE7), Color(0xFF98A8F8), Color(0xFFE5E1FA)],
              ),
            ),
          ),
          // light overlay
          IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.white.withOpacity(0.10), Colors.white.withOpacity(0.0)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 780;
              final keyboard = const _Keyboard();

              // banner color
              Color bannerColor;
              if (game.status == GameStatus.won) {
                bannerColor = Colors.greenAccent.withOpacity(.35);
              } else if (game.status == GameStatus.lost) {
                bannerColor = Colors.redAccent.withOpacity(.35);
              } else {
                bannerColor = Colors.white.withOpacity(.3);
              }

              final content = <Widget>[
                const SizedBox(height: kToolbarHeight + 12),

                // banner
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOut,
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: bannerColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withOpacity(.35)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(.08),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      transitionBuilder: (child, anim) => FadeTransition(
                        opacity: anim,
                        child: SlideTransition(
                          position: anim.drive(Tween(begin: const Offset(0, .2), end: Offset.zero)),
                          child: child,
                        ),
                      ),
                      child: Text(
                        statusText,
                        key: ValueKey<String>(statusText),
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // masked word + shake
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: _GlassCard(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      transitionBuilder: (child, anim) =>
                          FadeTransition(opacity: anim, child: child),
                      child: _ShakeOnChange(
                        key: ValueKey<String>('wrong-${game.wrong}'),
                        child: WordDisplay(maskedWord: game.maskedWord),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  'Wrong guesses: ${game.wrong}   •   Left: ${game.wrongLeft} / ${game.maxWrong}',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 14),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Guessed letters', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 6),
                      _GlassCard(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        child: GuessedLettersStrip(letters: game.guessed),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FilledButton.tonalIcon(
                      onPressed: game.status == GameStatus.playing
                          ? () => context.read<GameState>().useHint()
                          : null,
                      icon: const Icon(Icons.lightbulb),
                      label: const Text('Hint (-1 life)'),
                    ),
                    const SizedBox(width: 12),
                    FilledButton.icon(
                      onPressed: () => context.read<GameState>().newRound(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('New Word'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                        textStyle: const TextStyle(fontWeight: FontWeight.w700),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 2,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),
              ];

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: isWide
                    ? Row(
                        children: [
                          Expanded(child: ListView(children: content)),
                          const SizedBox(width: 18),
                          Expanded(child: _GlassCard(child: keyboard)),
                        ],
                      )
                    : ListView(
                        children: [
                          ...content,
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: _GlassCard(child: keyboard),
                          ),
                        ],
                      ),
              );
            },
          ),

          // confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confetti,
              blastDirectionality: BlastDirectionality.explosive,
              maxBlastForce: 30,
              minBlastForce: 8,
              emissionFrequency: 0.08,
              numberOfParticles: 30,
              gravity: 0.7,
            ),
          ),
        ],
      ),
    );
  }
}

// glass card
class _GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  const _GlassCard({required this.child, this.padding = const EdgeInsets.all(18), super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.35),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(.45)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.08),
            blurRadius: 20,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: child,
    );
  }
}

// shake when wrong count changes
class _ShakeOnChange extends StatefulWidget {
  final Widget child;
  const _ShakeOnChange({required Key key, required this.child}) : super(key: key);

  @override
  State<_ShakeOnChange> createState() => _ShakeOnChangeState();
}

class _ShakeOnChangeState extends State<_ShakeOnChange> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 260),
  );

  late final Animation<double> _anim = TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 0, end: -10), weight: 1),
    TweenSequenceItem(tween: Tween(begin: -10, end: 10), weight: 2),
    TweenSequenceItem(tween: Tween(begin: 10, end: 0), weight: 1),
  ]).animate(CurvedAnimation(parent: _c, curve: Curves.easeOut));

  @override
  void didUpdateWidget(covariant _ShakeOnChange oldWidget) {
    super.didUpdateWidget(oldWidget);
    _c.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, child) => Transform.translate(
        offset: Offset(_anim.value, 0),
        child: child,
      ),
      child: widget.child,
    );
  }
}

class _Keyboard extends StatelessWidget {
  const _Keyboard({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameState>();
    final isLocked = game.status != GameStatus.playing;
    final alphabet = List.generate(26, (i) => String.fromCharCode(65 + i));

    return GridView.builder(
      itemCount: alphabet.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.1,
      ),
      itemBuilder: (_, i) {
        final letter = alphabet[i];
        final disabled = isLocked || game.guessed.contains(letter);

        return LetterKey(
          letter: letter,
          disabled: disabled,
          onTap: () => context.read<GameState>().guessLetter(letter),
        );
      },
    );
  }
}
