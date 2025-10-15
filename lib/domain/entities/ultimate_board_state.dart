import 'package:collection/collection.dart';
import 'package:not_so_tic_tac_toe_game/domain/entities/board_position.dart';
import 'package:not_so_tic_tac_toe_game/domain/entities/game_status.dart';
import 'package:not_so_tic_tac_toe_game/domain/entities/player_mark.dart';

class UltimateMiniBoard {
  UltimateMiniBoard({
    required this.index,
    required List<PlayerMark?> cells,
    required this.status,
    required this.winner,
  })  : assert(cells.length == 9, 'A mini-board must contain 9 cells.'),
        cells = List<PlayerMark?>.unmodifiable(cells);

  final int index;
  final List<PlayerMark?> cells;
  final GameStatus status;
  final PlayerMark? winner;

  PlayerMark? markAt(int cellIndex) => cells[cellIndex];

  bool get isPlayable => status == GameStatus.inProgress;

  bool get isDraw => status == GameStatus.draw;

  bool get isWon => status == GameStatus.won && winner != null;

  bool get isResolved => status != GameStatus.inProgress;

  List<int> get openCellIndices {
    final indices = <int>[];
    for (var i = 0; i < cells.length; i++) {
      if (cells[i] == null) {
        indices.add(i);
      }
    }
    return indices;
  }

  Map<String, dynamic> toMap() {
    return {
      'cells': cells.map((mark) => mark?.name).toList(growable: false),
      'status': _statusToString(status),
      'winnerMark': winner?.name,
      'index': index,
    };
  }

  static UltimateMiniBoard fromMap(Map<String, dynamic> data) {
    final cellsRaw = (data['cells'] as List<dynamic>? ?? const <dynamic>[])
        .map((value) => _markFromString(value as String?))
        .toList(growable: false);
    if (cellsRaw.length != 9) {
      throw ArgumentError('Mini-board definition must include 9 cells.');
    }
    return UltimateMiniBoard(
      index: (data['index'] as num?)?.toInt() ?? 0,
      cells: cellsRaw,
      status: _statusFromString(data['status'] as String?),
      winner: _markFromString(data['winnerMark'] as String?),
    );
  }

  static PlayerMark? _markFromString(String? value) {
    switch (value) {
      case 'x':
        return PlayerMark.x;
      case 'o':
        return PlayerMark.o;
      default:
        return null;
    }
  }

  static GameStatus _statusFromString(String? value) {
    switch (value) {
      case 'won':
        return GameStatus.won;
      case 'draw':
        return GameStatus.draw;
      case 'in_progress':
      default:
        return GameStatus.inProgress;
    }
  }

  static String _statusToString(GameStatus status) {
    switch (status) {
      case GameStatus.won:
        return 'won';
      case GameStatus.draw:
        return 'draw';
      case GameStatus.inProgress:
        return 'in_progress';
    }
  }
}

class UltimateBoardState {
  UltimateBoardState({
    required List<UltimateMiniBoard> miniBoards,
    this.activeBoardIndex,
    this.lastMove,
  })  : assert(miniBoards.length == 9, 'Ultimate mode needs 9 mini-boards.'),
        miniBoards = List<UltimateMiniBoard>.unmodifiable(
          miniBoards.sorted((a, b) => a.index.compareTo(b.index)),
        );

  final List<UltimateMiniBoard> miniBoards;
  final int? activeBoardIndex;
  final BoardPosition? lastMove;

  UltimateMiniBoard boardAt(int index) => miniBoards[index];

  bool get isWildcard => activeBoardIndex == null;

  bool isBoardPlayable(int index) {
    if (index < 0 || index >= miniBoards.length) {
      return false;
    }
    return miniBoards[index].isPlayable;
  }

  bool isCellAvailable(BoardPosition absolutePosition) {
    final details = breakdownFor(absolutePosition);
    final miniBoard = miniBoards[details.miniIndex];
    if (!miniBoard.isPlayable) return false;
    return miniBoard.cells[details.cellIndex] == null;
  }

  ({
    int miniIndex,
    int cellIndex,
    int cellRow,
    int cellCol,
  }) breakdownFor(BoardPosition absolutePosition) {
    if (absolutePosition.dimension != 9) {
      throw ArgumentError(
        'Ultimate board expects absolute positions with dimension 9.',
      );
    }
    final miniRow = absolutePosition.row ~/ 3;
    final miniCol = absolutePosition.col ~/ 3;
    final cellRow = absolutePosition.row % 3;
    final cellCol = absolutePosition.col % 3;
    final miniIndex = miniRow * 3 + miniCol;
    final cellIndex = cellRow * 3 + cellCol;
    return (
      miniIndex: miniIndex,
      cellIndex: cellIndex,
      cellRow: cellRow,
      cellCol: cellCol,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'activeBoardIndex': activeBoardIndex,
      'lastMove': lastMove == null
          ? null
          : {
              'row': lastMove!.row,
              'col': lastMove!.col,
            },
      'boards': miniBoards.map((board) => board.toMap()).toList(growable: false),
    };
  }

  static UltimateBoardState fromMap(Map<String, dynamic> data) {
    final boardsRaw = (data['boards'] as List<dynamic>? ?? const <dynamic>[])
        .map((entry) => UltimateMiniBoard.fromMap(
              Map<String, dynamic>.from(entry as Map),
            ))
        .toList(growable: false);
    final lastMoveRaw = data['lastMove'] as Map<String, dynamic>?;
    return UltimateBoardState(
      miniBoards: boardsRaw,
      activeBoardIndex: (data['activeBoardIndex'] as num?)?.toInt(),
      lastMove: lastMoveRaw == null
          ? null
          : BoardPosition(
              row: (lastMoveRaw['row'] as num).toInt(),
              col: (lastMoveRaw['col'] as num).toInt(),
              dimension: 9,
            ),
    );
  }

  ({
    int miniIndex,
    int cellIndex,
    int cellRow,
    int cellCol,
  }) resolveAbsolute(BoardPosition position) => breakdownFor(position);
}