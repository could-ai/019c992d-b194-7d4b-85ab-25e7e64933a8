import 'package:flutter/material.dart';
import '../models/playing_card.dart';

class CardWidget extends StatelessWidget {
  final PlayingCard? card;
  final bool isFaceUp;
  final double width;
  final double height;
  final VoidCallback? onTap;

  const CardWidget({
    super.key,
    this.card,
    this.isFaceUp = false,
    this.width = 80,
    this.height = 120,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: isFaceUp ? Colors.white : Colors.blue.shade800,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.black, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: isFaceUp && card != null
            ? _buildFaceUp()
            : _buildFaceDown(),
      ),
    );
  }

  Widget _buildFaceDown() {
    return Center(
      child: Container(
        width: width - 10,
        height: height - 10,
        decoration: BoxDecoration(
          color: Colors.blue.shade600,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
        ),
        child: const Center(
          child: Icon(Icons.videogame_asset, color: Colors.white24, size: 30),
        ),
      ),
    );
  }

  Widget _buildFaceUp() {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Text(
              '${card!.rankLabel}\n${card!.suitLabel}',
              style: TextStyle(
                color: card!.color,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                height: 1.0,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Center(
            child: Text(
              card!.suitLabel,
              style: TextStyle(
                color: card!.color,
                fontSize: 32,
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Transform.rotate(
              angle: 3.14159,
              child: Text(
                '${card!.rankLabel}\n${card!.suitLabel}',
                style: TextStyle(
                  color: card!.color,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  height: 1.0,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
