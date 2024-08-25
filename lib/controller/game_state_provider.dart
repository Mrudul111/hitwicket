import 'package:flutter/foundation.dart';

class GameStateProvider with ChangeNotifier {
  List<String?> _board = List.filled(25, null);
  String _currentPlayer = 'Player1';
  bool _gameOver = false;
  int? _selectedCharacterIndex;
  List<int> _validMoves = [];

  List<String?> get board => _board;
  String get currentPlayer => _currentPlayer;
  bool get gameOver => _gameOver;
  int? get selectedCharacterIndex => _selectedCharacterIndex;
  List<int> get validMoves => _validMoves;

  void updateBoard(List<String?> board) {
    _board = board;
    notifyListeners();
  }

  void updateCurrentPlayer(String player) {
    _currentPlayer = player;
    notifyListeners();
  }

  void setGameOver(bool gameOver) {
    _gameOver = gameOver;
    notifyListeners();
  }

  void selectCharacter(int index) {
    if (_board[index]?.startsWith(_currentPlayer) == true) {
      _selectedCharacterIndex = index;
      _validMoves = calculateValidMoves(index);
      print('Selected character at index $index');
      print('Valid moves: $_validMoves');
      notifyListeners();
    }
  }

  void clearSelection() {
    _selectedCharacterIndex = null;
    _validMoves = [];
    notifyListeners();
  }

  void moveCharacter(int index) {
    if (_selectedCharacterIndex != null && _validMoves.contains(index)) {
      final fromIndex = _selectedCharacterIndex!;
      final movedCharacter = _board[fromIndex];

      if (movedCharacter != null) {
        if (_board[index] == null || _board[index]!.startsWith(switchPlayer())) {
          _board[index] = movedCharacter;
          _board[fromIndex] = null;
          winningCondition();
          if (!_gameOver) {
            _currentPlayer = switchPlayer();
            notifyListeners();
          }

          clearSelection();
          notifyListeners();
        }
      }
    }
  }

  String switchPlayer() => _currentPlayer == 'Player1' ? 'Player2' : 'Player1';

  void winningCondition() {
    final left_p1 = _board.any((c) => c != null && c.startsWith('Player1'));
    final left_p2 = _board.any((c) => c != null && c.startsWith('Player2'));

    if (!left_p1) {
      setGameOver(true);

      notifyListeners();
      print('Player2 wins!');

    } else if (!left_p2) {
      setGameOver(true);
      notifyListeners();
      print('Player1 wins!');
    }
  }
  List<int> calculateValidMoves(int index) {
    final validMoves = <int>[];
    final character = _board[index];
    if (character == null) return validMoves;

    final x = index % 5;
    final y = index ~/ 5;
    final type = character.split('-')[1];
    final directions = <String>[];

    switch (type) {
      case 'P1':
      case 'P2':
      case 'P3':
        directions.addAll(['L', 'R', 'F', 'B']);
        break;
      case 'H1':
        directions.addAll(['L', 'R', 'F', 'B']);
        break;
      case 'H2':
        directions.addAll(['FL', 'FR', 'BL', 'BR']);
        break;
    }

    for (final direction in directions) {
      final newMoves = getNewPositions(x, y, direction, type);
      validMoves.addAll(newMoves);
    }

    return validMoves.where((i) => i >= 0 && i < 25).toList();
  }

  List<int> getNewPositions(int x, int y, String direction, String type) {
    final positions = <int>[];
    void addValidPositions(int newX, int newY) {
      if (newX >= 0 && newX < 5 && newY >= 0 && newY < 5) {
        positions.add((newY * 5) + newX);
      }
    }

    switch (direction) {
      case 'L':
        addValidPositions(x - 1, y);
        if (type == 'H1') {
          addValidPositions(x - 2, y);
        }
        break;
      case 'R':
        addValidPositions(x + 1, y);
        if (type == 'H1') {
          addValidPositions(x + 2, y);
        }
        break;
      case 'F':
        addValidPositions(x, y - 1);
        if (type == 'H1') {
          addValidPositions(x, y - 2);
        }
        break;
      case 'B':
        addValidPositions(x, y + 1);
        if (type == 'H1') {
          addValidPositions(x, y + 2);
        }
        break;
      case 'FL':
        addValidPositions(x - 1, y - 1);
        if (type == 'H1') {
          addValidPositions(x - 2, y - 2);
        }
        break;
      case 'FR':
        addValidPositions(x + 1, y - 1);
        if (type == 'H1') {
          addValidPositions(x + 2, y - 2);
        }
        break;
      case 'BL':
        addValidPositions(x - 1, y + 1);
        if (type == 'H1') {
          addValidPositions(x - 2, y + 2);
        }
        break;
      case 'BR':
        addValidPositions(x + 1, y + 1);
        if (type == 'H1') {
          addValidPositions(x + 2, y + 2);
        }
        break;
    }

    return positions;
  }

  String? calculateMove(int targetIndex) {
    if (_selectedCharacterIndex == null) return null;

    final from_X = _selectedCharacterIndex! % 5;
    final from_Y = _selectedCharacterIndex! ~/ 5;
    final to_X = targetIndex % 5;
    final to_Y = targetIndex ~/ 5;

    if (from_X == to_X) {
      return from_Y > to_Y ? 'F' : 'B';
    } else if (from_Y == to_Y) {
      return from_X > to_X ? 'L' : 'R';
    } else if ((from_X - to_X).abs() == 2 && (from_Y - to_Y).abs() == 2) {
      if (from_X > to_X && from_Y > to_Y) return 'FL';
      if (from_X < to_X && from_Y > to_Y) return 'FR';
      if (from_X > to_X && from_Y < to_Y) return 'BL';
      if (from_X < to_X && from_Y < to_Y) return 'BR';
    }

    return null;
  }
}
