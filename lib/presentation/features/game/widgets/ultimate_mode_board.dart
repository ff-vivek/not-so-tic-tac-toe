import 'package:flutter/material.dart';
import 'package:not_so_tic_tac_toe_game/domain/entities/board_position.dart';
import 'package:not_so_tic_tac_toe_game/domain/entities/game_status.dart';
import 'package:not_so_tic_tac_toe_game/domain/entities/player_mark.dart';
import 'package:not_so_tic_tac_toe_game/domain/entities/ultimate_board_state.dart';

typedef UltimateCellSelected = void Function(BoardPosition position);
typedef UltimateCanSelectCell = bool Function(BoardPosition position);

class UltimateModeBoard extends StatelessWidget {
  const UltimateModeBoard({
    super.key,
    required this.state,
    required this.onCellSelected,
    required this.canSelectCell,
    required this.matchStatus,
    this.localPlayerMark,
    this.lastMove,
  });

  final UltimateBoardState state;
  final UltimateCellSelected onCellSelected;
  final UltimateCanSelectCell canSelectCell;
  final GameStatus matchStatus;
  final PlayerMark? localPlayerMark;
  final BoardPosition? lastMove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        return AspectRatio(
          aspectRatio: 1,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: theme.colorScheme.outline.withOpacity(0.4),
                width: 1.4,
              ),
            ),
            child: GridView.count(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              crossAxisCount: 3,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              children: List.generate(9, (index) {
                final miniBoard = state.boardAt(index);
                final isBoardActive = _isBoardActive(index, miniBoard);
                return _MiniBoard(
                  board: miniBoard,
                  boardIndex: index,
                  onCellSelected: onCellSelected,
                  canSelectCell: canSelectCell,
                  isActive: isBoardActive,
                  lastMove: lastMove,
                  matchStatus: matchStatus,
                );
              }),
            ),
          ),
        );
      },
    );
  }

  bool _isBoardActive(int index, UltimateMiniBoard board) {
    if (!board.isPlayable) return false;
    if (board.openCellIndices.isEmpty) return false;
    if (state.activeBoardIndex == null) {
      return true;
    }
    return state.activeBoardIndex == index;
  }
}

class _MiniBoard extends StatelessWidget {
  const _MiniBoard({
    required this.board,
    required this.boardIndex,
    required this.onCellSelected,
    required this.canSelectCell,
    required this.isActive,
    required this.lastMove,
    required this.matchStatus,
  });

  final UltimateMiniBoard board;
  final int boardIndex;
  final UltimateCellSelected onCellSelected;
  final UltimateCanSelectCell canSelectCell;
  final bool isActive;
  final BoardPosition? lastMove;
  final GameStatus matchStatus;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseColor = board.isPlayable
        ? theme.colorScheme.surface
        : theme.colorScheme.surfaceVariant.withOpacity(0.85);
    final borderColor = board.isWon
        ? theme.colorScheme.secondary
        : board.isDraw
            ? theme.colorScheme.tertiary
            : isActive
                ? theme.colorScheme.primary
                : theme.colorScheme.outlineVariant;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: borderColor.withOpacity(isActive ? 0.9 : 0.6),
          width: isActive ? 2.6 : 1.6,
        ),
        boxShadow: [
          if (isActive)
            BoxShadow(
              color: borderColor.withOpacity(0.25),
              blurRadius: 14,
              spreadRadius: 1,
            ),
        ],
      ),
      child: Stack(
        children: [
          GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
            ),
            itemCount: 9,
            itemBuilder: (context, cellIndex) {
              final cellRow = cellIndex ~/ 3;
              final cellCol = cellIndex % 3;
              final globalRow = (boardIndex ~/ 3) * 3 + cellRow;
              final globalCol = (boardIndex % 3) * 3 + cellCol;
              final position = BoardPosition(
                row: globalRow,
                col: globalCol,
                dimension: 9,
              );
              final mark = board.cells[cellIndex];
              final selectable = canSelectCell(position) && matchStatus == GameStatus.inProgress;
              final isLastMove = lastMove != null && lastMove == position;

              return _UltimateCell(
                mark: mark,
                onTap: selectable
                    ? () => onCellSelected(position)
                    : null,
                isSelectable: selectable,
                isLastMove: isLastMove,
              );
            },
          ),
          if (board.isWon || board.isDraw)
            _ResolvedBoardOverlay(
              winner: board.winner,
              isDraw: board.isDraw,
            ),
        ],
      ),
    );
  }
}

class _UltimateCell extends StatelessWidget {
  const _UltimateCell({
    required this.mark,
    required this.onTap,
    required this.isSelectable,
    required this.isLastMove,
  });

  final PlayerMark? mark;
  final VoidCallback? onTap;
  final bool isSelectable;
  final bool isLastMove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final highlightColor = theme.colorScheme.secondaryContainer.withOpacity(0.25);
    final baseColor = mark == null
        ? (isSelectable
            ? theme.colorScheme.surface
            : theme.colorScheme.surfaceVariant.withOpacity(0.6))
        : theme.colorScheme.surfaceVariant.withOpacity(0.95);

    final borderColor = isLastMove
        ? theme.colorScheme.secondary
        : isSelectable
            ? theme.colorScheme.primary.withOpacity(0.7)
            : theme.colorScheme.outlineVariant;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor,
          width: isLastMove ? 2 : 1.3,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        splashColor: highlightColor,
        child: Center(
          child: Text(
            mark?.label ?? '',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: mark == null
                  ? theme.colorScheme.primary
                  : mark == PlayerMark.x
                      ? theme.colorScheme.primary
                      : theme.colorScheme.secondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _ResolvedBoardOverlay extends StatelessWidget {
  const _ResolvedBoardOverlay({
    this.winner,
    required this.isDraw,
  });

  final PlayerMark? winner;
  final bool isDraw;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isDraw
        ? theme.colorScheme.tertiary
        : winner == PlayerMark.x
            ? theme.colorScheme.primary
            : theme.colorScheme.secondary;

    final icon = isDraw
        ? Icons.handshake_rounded
        : Icons.emoji_events_rounded;

    final label = isDraw ? 'Draw' : winner?.label ?? '';

    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: color.withOpacity(0.12),
          border: Border.all(
            color: color.withOpacity(0.4),
            width: 1.8,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color.withOpacity(0.85), size: 28),
              const SizedBox(height: 6),
              Text(
                label,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: color.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}