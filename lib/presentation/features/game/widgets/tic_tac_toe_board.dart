import 'package:flutter/material.dart';
import 'package:not_so_tic_tac_toe_game/domain/entities/board_position.dart';
import 'package:not_so_tic_tac_toe_game/domain/entities/tic_tac_toe_game.dart';
import 'package:not_so_tic_tac_toe_game/domain/entities/player_mark.dart';

typedef CellSelected = void Function(BoardPosition position);
typedef CanSelectCell = bool Function(BoardPosition position);

class TicTacToeBoard extends StatelessWidget {
  const TicTacToeBoard({
    super.key,
    required this.game,
    required this.onCellSelected,
    this.canSelectCell,
  });

  final TicTacToeGame game;
  final CellSelected onCellSelected;
  final CanSelectCell? canSelectCell;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cellSize = MediaQuery.of(context).size.width - 64;

    final board = game.board;

    return Center(
      child: AspectRatio(
        aspectRatio: 1,
        child: SizedBox(
          width: cellSize,
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: 9,
            itemBuilder: (context, index) {
              final row = index ~/ 3;
              final col = index % 3;
              final mark = board[index];
              final position = BoardPosition(row: row, col: col);
              final predicate = canSelectCell ?? game.canPlayAt;

              return _BoardCell(
                mark: mark,
                isHighlighted: game.lastMove == position,
                onTap: () => onCellSelected(position),
                isInteractive: predicate(position),
                theme: theme,
              );
            },
          ),
        ),
      ),
    );
  }
}

class _BoardCell extends StatelessWidget {
  const _BoardCell({
    required this.mark,
    required this.isHighlighted,
    required this.onTap,
    required this.isInteractive,
    required this.theme,
  });

  final PlayerMark? mark;
  final bool isHighlighted;
  final VoidCallback onTap;
  final bool isInteractive;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final borderColor = theme.colorScheme.primary.withOpacity(0.3);
    final highlightColor = theme.colorScheme.secondary.withOpacity(0.15);

    return Semantics(
      label: 'Board cell',
      hint: mark == null ? 'Tap to place your mark' : 'Occupied by ${mark!.name}',
      button: isInteractive,
      child: Material(
        color: isHighlighted ? highlightColor : Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: isInteractive ? onTap : null,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor, width: 2),
            ),
            alignment: Alignment.center,
            child: AnimatedScale(
              scale: mark == null ? 0 : 1,
              duration: const Duration(milliseconds: 160),
              child: Text(
                mark?.label ?? '',
                style: theme.textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: mark == PlayerMark.x
                      ? theme.colorScheme.primary
                      : theme.colorScheme.secondary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}