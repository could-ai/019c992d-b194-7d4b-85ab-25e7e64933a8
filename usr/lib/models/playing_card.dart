import 'package:flutter/material.dart';

enum Suit { hearts, diamonds, clubs, spades }
enum Rank { two, three, four, five, six, seven, eight, nine, ten, jack, queen, king, ace }

class PlayingCard {
  final Suit suit;
  final Rank rank;

  PlayingCard({required this.suit, required this.rank});

  String get rankLabel {
    switch (rank) {
      case Rank.two: return '2';
      case Rank.three: return '3';
      case Rank.four: return '4';
      case Rank.five: return '5';
      case Rank.six: return '6';
      case Rank.seven: return '7';
      case Rank.eight: return '8';
      case Rank.nine: return '9';
      case Rank.ten: return '10';
      case Rank.jack: return 'J';
      case Rank.queen: return 'Q';
      case Rank.king: return 'K';
      case Rank.ace: return 'A';
    }
  }

  String get suitLabel {
    switch (suit) {
      case Suit.hearts: return '♥';
      case Suit.diamonds: return '♦';
      case Suit.clubs: return '♣';
      case Suit.spades: return '♠';
    }
  }

  Color get color {
    return (suit == Suit.hearts || suit == Suit.diamonds) ? Colors.red : Colors.black;
  }
}
