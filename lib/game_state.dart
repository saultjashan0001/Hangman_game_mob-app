import 'dart:math';
import 'package:flutter/foundation.dart';

enum GameStatus { playing, won, lost }

class GameState extends ChangeNotifier {
  /// Maximum wrong guesses allowed
  final int maxWrong = 6;

  /// Word bank
  final List<String> _allWords = [
    'HAPPY',
    'REFLECT',
    'FLUTTER',
    'DART',
    'WIDGET',
    'STATE',
    'MOBILE',
    'CANADA',
    'COLLEGE',
    'PROJECT',
    'BUTTON',
    'SCREEN',
    'LAYOUT',
    'RANDOM',
    'VECTOR',
  ];

  final Set<String> _usedWords = {};
  final Random _rng = Random();

  late String _word;            // current word
  final Set<String> _guessed = {}; // all guessed letters (A–Z)
  int _wrong = 0;               // wrong guess counter
  GameStatus _status = GameStatus.playing;

  GameState() {
    _newGame();
  }

  // --------- Getters ----------
  String get word => _word;
  Set<String> get guessed => _guessed;
  int get wrong => _wrong;
  int get wrongLeft => maxWrong - _wrong;
  GameStatus get status => _status;

  /// Returns the word with underscores for hidden letters, e.g. "_ _ P P _"
  String get maskedWord {
    final letters = _word.split('');
    return letters.map((ch) => _guessed.contains(ch) ? ch : '_').join(' ');
  }

  /// Have we revealed all letters?
  bool get _allRevealed {
    for (final ch in _word.split('')) {
      if (!_guessed.contains(ch)) return false;
    }
    return true;
  }

  // --------- Actions ----------
  /// Guess a single letter (case-insensitive). Repeats do nothing.
  void guessLetter(String raw) {
    if (_status != GameStatus.playing) return;

    final letter = raw.toUpperCase();
    // ignore non A–Z
    if (letter.length != 1 || letter.codeUnitAt(0) < 65 || letter.codeUnitAt(0) > 90) {
      return;
    }

    if (_guessed.contains(letter)) return; // already guessed -> ignore

    _guessed.add(letter);

    if (_word.contains(letter)) {
      // Correct guess
      if (_allRevealed) {
        _status = GameStatus.won;
      }
    } else {
      // Wrong guess
      _wrong += 1;
      if (_wrong >= maxWrong) {
        _status = GameStatus.lost;
        // reveal the whole word so the player can see it
        for (final ch in _word.split('')) {
          _guessed.add(ch);
        }
      }
    }
    notifyListeners();
  }

  /// Reveal 1 random hidden letter. Costs 1 wrong guess (a "life").
  void useHint() {
    if (_status != GameStatus.playing) return;

    final remaining = _word.split('').where((ch) => !_guessed.contains(ch)).toList();
    if (remaining.isEmpty) return; // nothing to reveal

    final letter = remaining[_rng.nextInt(remaining.length)];
    _guessed.add(letter);

    if (_allRevealed) {
      _status = GameStatus.won;
    } else {
      _wrong += 1; // hint penalty
      if (_wrong >= maxWrong) {
        _status = GameStatus.lost;
        for (final ch in _word.split('')) {
          _guessed.add(ch);
        }
      }
    }
    notifyListeners();
  }

  /// Start a new round (new word; avoids repeats until all used)
  void newRound() {
    _newGame();
    notifyListeners();
  }

  // --------- Internals ----------
  void _newGame() {
    if (_usedWords.length == _allWords.length) {
      _usedWords.clear(); // reset cycle if we've used all words
    }

    String pick;
    do {
      pick = _allWords[_rng.nextInt(_allWords.length)];
    } while (_usedWords.contains(pick));
    _usedWords.add(pick);

    _word = pick;
    _guessed.clear();
    _wrong = 0;
    _status = GameStatus.playing;
  }
}
