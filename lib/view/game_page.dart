import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../controller/game_state_provider.dart';
import '../controller/theme_provider.dart';

class GamePage extends StatefulWidget {
  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  final WebSocketChannel channel = WebSocketChannel.connect(
    Uri.parse('ws://localhost:8080'),
  );

  @override
  void initState() {
    super.initState();
    channel.stream.listen((message) {
      final data = jsonDecode(message);
      final gameState = Provider.of<GameStateProvider>(context, listen: false);
      if (data['type'] == 'gameState') {
        gameState.updateBoard(List<String?>.from(data['state']['board']));
        gameState.updateCurrentPlayer(data['state']['currentPlayer']);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameStateProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    final player1Color = themeProvider.player1Color;
    final player2Color = themeProvider.player2Color;
    final selectionColor = themeProvider.selectionColor;

    return Scaffold(
      appBar: AppBar(
        title: Text('${gameState.currentPlayer}\'s Turn'),
        actions: [
          IconButton(
            icon: Icon(Icons.brightness_6),
            onPressed: () {
              themeProvider.toggleTheme();
            },
          ),
        ],
      ),
      body: !gameState.gameOver
          ? SafeArea(
        top: false,
        left: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
            ),
            itemCount: 25,
            itemBuilder: (context, index) {
              final isValidMove = gameState.validMoves.contains(index);
              final cellContent = gameState.board[index];
              final isSelected = gameState.selectedCharacterIndex == index;
              final isOwnCharacter = cellContent != null && cellContent.startsWith(gameState.currentPlayer);
              final cellColor = isSelected
                  ? selectionColor
                  : (isValidMove && !isOwnCharacter)
                  ? Colors.redAccent
                  : cellContent != null
                  ? (cellContent.startsWith('Player1') ? player1Color : player2Color)
                  : Colors.white;

              return GestureDetector(
                onTap: () {
                  if (gameState.selectedCharacterIndex == null) {
                    gameState.selectCharacter(index);
                  } else if (isValidMove && !isOwnCharacter) {
                    gameState.moveCharacter(index);
                    gameState.clearSelection();
                    final moveCommand = gameState.calculateMove(index);
                    if (moveCommand != null) {
                      channel.sink.add(jsonEncode({
                        'type': 'playerMove',
                        'move': {
                          'player': gameState.currentPlayer,
                          'characterName': gameState.board[gameState.selectedCharacterIndex!]?.split('-')[1],
                          'move': moveCommand
                        }
                      }));
                    }
                  } else {
                    gameState.clearSelection();
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    color: cellColor,
                  ),
                  child: Center(
                    child: Text(
                      cellContent ?? '',
                      style: TextStyle(
                        fontSize: 24,
                        color: cellContent != null ? Colors.black : Colors.grey,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      )
          : Center(
        child: Text(
          '${gameState.currentPlayer} Wins',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
