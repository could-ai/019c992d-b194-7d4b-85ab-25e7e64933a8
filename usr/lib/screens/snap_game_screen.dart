import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/playing_card.dart';
import '../widgets/card_widget.dart';

class SnapGameScreen extends StatefulWidget {
  const SnapGameScreen({super.key});

  @override
  State<SnapGameScreen> createState() => _SnapGameScreenState();
}

class _SnapGameScreenState extends State<SnapGameScreen> {
  List<PlayingCard> playerDeck = [];
  List<PlayingCard> cpuDeck = [];
  List<PlayingCard> centerPile = [];
  
  bool isPlayerTurn = true;
  bool isGameActive = false;
  bool isGameOver = false;
  String statusMessage = "Press Deal to Start";
  String? winnerMessage;
  
  Timer? _cpuTimer;
  Timer? _reactionTimer;
  
  // Game Settings
  final int reactionTimeMin = 1000; // ms
  final int reactionTimeMax = 2500; // ms

  @override
  void initState() {
    super.initState();
    _startNewGame();
  }

  @override
  void dispose() {
    _cpuTimer?.cancel();
    _reactionTimer?.cancel();
    super.dispose();
  }

  void _startNewGame() {
    setState(() {
      // Create and shuffle deck
      List<PlayingCard> fullDeck = [];
      for (var suit in Suit.values) {
        for (var rank in Rank.values) {
          fullDeck.add(PlayingCard(suit: suit, rank: rank));
        }
      }
      fullDeck.shuffle();

      // Split deck
      playerDeck = fullDeck.sublist(0, 26);
      cpuDeck = fullDeck.sublist(26);
      centerPile = [];
      
      isPlayerTurn = true;
      isGameActive = true;
      isGameOver = false;
      statusMessage = "Your Turn! Tap your deck.";
      winnerMessage = null;
    });
  }

  void _playTurn() {
    if (!isGameActive || isGameOver) return;

    setState(() {
      if (isPlayerTurn) {
        if (playerDeck.isEmpty) {
          _endGame(false); // Player out of cards
          return;
        }
        PlayingCard card = playerDeck.removeLast();
        centerPile.add(card);
        isPlayerTurn = false;
        statusMessage = "CPU is thinking...";
        
        _checkForSnapOpportunity();
        
        if (isGameActive && !isGameOver) {
          _scheduleCpuTurn();
        }
      } else {
        // CPU Turn logic is handled by timer, but this is the execution
        if (cpuDeck.isEmpty) {
          _endGame(true); // CPU out of cards
          return;
        }
        PlayingCard card = cpuDeck.removeLast();
        centerPile.add(card);
        isPlayerTurn = true;
        statusMessage = "Your Turn! Tap your deck.";
        
        _checkForSnapOpportunity();
      }
    });
  }

  void _scheduleCpuTurn() {
    _cpuTimer?.cancel();
    _cpuTimer = Timer(const Duration(milliseconds: 1500), () {
      if (mounted && !isPlayerTurn && isGameActive) {
        _playTurn();
      }
    });
  }

  void _checkForSnapOpportunity() {
    if (centerPile.length < 2) return;

    PlayingCard topCard = centerPile.last;
    PlayingCard secondCard = centerPile[centerPile.length - 2];

    if (topCard.rank == secondCard.rank) {
      statusMessage = "SNAP! Match found!";
      // Schedule CPU reaction
      int reactionDelay = Random().nextInt(reactionTimeMax - reactionTimeMin) + reactionTimeMin;
      _reactionTimer?.cancel();
      _reactionTimer = Timer(Duration(milliseconds: reactionDelay), () {
        if (mounted && isGameActive) {
          _cpuSnap();
        }
      });
    }
  }

  void _playerSnap() {
    if (!isGameActive || isGameOver) return;

    if (centerPile.length < 2) {
      // False alarm penalty
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("False Alarm! No match.")),
      );
      return;
    }

    PlayingCard topCard = centerPile.last;
    PlayingCard secondCard = centerPile[centerPile.length - 2];

    if (topCard.rank == secondCard.rank) {
      // Player wins the pile
      _reactionTimer?.cancel(); // Cancel CPU reaction
      setState(() {
        playerDeck.insertAll(0, centerPile); // Add to bottom of deck
        centerPile.clear();
        statusMessage = "You won the pile! Your turn.";
        isPlayerTurn = true;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("SNAP! You won the pile!")),
      );
    } else {
      // False alarm penalty logic could go here
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("False Alarm! Ranks don't match.")),
      );
    }
  }

  void _cpuSnap() {
    if (!isGameActive || isGameOver) return;
    
    // CPU wins the pile
    setState(() {
      cpuDeck.insertAll(0, centerPile);
      centerPile.clear();
      statusMessage = "CPU Snapped! CPU's turn.";
      isPlayerTurn = false;
      _scheduleCpuTurn();
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("CPU Snapped first! CPU wins pile.")),
    );
  }

  void _endGame(bool playerWon) {
    setState(() {
      isGameActive = false;
      isGameOver = true;
      winnerMessage = playerWon ? "YOU WIN!" : "GAME OVER";
      statusMessage = playerWon ? "Congratulations!" : "Better luck next time.";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade900,
      appBar: AppBar(
        title: const Text("Snap Game"),
        backgroundColor: Colors.green.shade800,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _startNewGame,
          )
        ],
      ),
      body: Column(
        children: [
          // CPU Area
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(16),
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "CPU: ${cpuDeck.length} cards",
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  CardWidget(
                    isFaceUp: false,
                    width: 60,
                    height: 90,
                  ),
                ],
              ),
            ),
          ),

          // Center Pile Area
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              color: Colors.black12,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    statusMessage,
                    style: const TextStyle(color: Colors.yellowAccent, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      if (centerPile.isEmpty)
                        Container(
                          width: 100,
                          height: 150,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white24, width: 2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(child: Text("Pile Empty", style: TextStyle(color: Colors.white24))),
                        ),
                      ...centerPile.map((card) {
                        // Show only last few cards to save memory/rendering, but logically keep all
                        int index = centerPile.indexOf(card);
                        if (index < centerPile.length - 3) return const SizedBox.shrink();
                        
                        // Add slight rotation for visual messiness
                        double rotation = (index % 5 - 2) * 0.05;
                        
                        return Transform.rotate(
                          angle: rotation,
                          child: CardWidget(
                            card: card,
                            isFaceUp: true,
                            width: 100,
                            height: 150,
                          ),
                        );
                      }),
                    ],
                  ),
                  if (winnerMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Text(
                        winnerMessage!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          shadows: [Shadow(color: Colors.black, blurRadius: 10)],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Player Area
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: (isPlayerTurn && isGameActive) ? _playTurn : null,
                    child: Opacity(
                      opacity: (isPlayerTurn && isGameActive) ? 1.0 : 0.5,
                      child: CardWidget(
                        isFaceUp: false,
                        width: 80,
                        height: 120,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "You: ${playerDeck.length} cards",
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  if (isPlayerTurn && isGameActive)
                    const Text(
                      "(Tap deck to deal)",
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                ],
              ),
            ),
          ),
          
          // Snap Button Area
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: Colors.black26,
            child: ElevatedButton(
              onPressed: isGameActive ? _playerSnap : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                "SNAP!",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
