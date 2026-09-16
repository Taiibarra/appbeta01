import 'package:flutter/material.dart';

enum Mood { great, good, neutral, bad, awful }

extension MoodX on Mood {
  String get emoji {
    switch (this) {
      case Mood.great:
        return '😄';
      case Mood.good:
        return '🙂';
      case Mood.neutral:
        return '😐';
      case Mood.bad:
        return '😕';
      case Mood.awful:
        return '😢';
    }
  }

  String get label {
    switch (this) {
      case Mood.great:
        return 'Excelente';
      case Mood.good:
        return 'Bien';
      case Mood.neutral:
        return 'Neutral';
      case Mood.bad:
        return 'Mal';
      case Mood.awful:
        return 'Muy mal';
    }
  }

  Color get color {
    switch (this) {
      case Mood.great:
        return const Color(0xFF4CAF93);
      case Mood.good:
        return const Color(0xFF8BC98A);
      case Mood.neutral:
        return const Color(0xFFE0C25B);
      case Mood.bad:
        return const Color(0xFFE0925B);
      case Mood.awful:
        return const Color(0xFFD9704F);
    }
  }
}
