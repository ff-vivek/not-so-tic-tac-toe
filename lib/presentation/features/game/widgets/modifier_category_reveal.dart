import 'dart:async';

import 'package:flutter/material.dart';
import 'package:not_so_tic_tac_toe_game/domain/modifiers/modifier_category.dart';

class ModifierCategoryReveal extends StatefulWidget {
  const ModifierCategoryReveal({
    super.key,
    required this.category,
    this.onRevealComplete,
  });

  final ModifierCategory category;
  final VoidCallback? onRevealComplete;

  @override
  State<ModifierCategoryReveal> createState() => _ModifierCategoryRevealState();
}

class _ModifierCategoryRevealState extends State<ModifierCategoryReveal> {
  static const List<Duration> _spinIntervals = [
    Duration(milliseconds: 140),
    Duration(milliseconds: 140),
    Duration(milliseconds: 160),
    Duration(milliseconds: 200),
    Duration(milliseconds: 240),
    Duration(milliseconds: 280),
    Duration(milliseconds: 340),
    Duration(milliseconds: 420),
  ];

  late ModifierCategory _displayedCategory;
  bool _isSpinning = true;
  int _animationToken = 0;

  @override
  void initState() {
    super.initState();
    _startReveal();
  }

  @override
  void didUpdateWidget(covariant ModifierCategoryReveal oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.category != widget.category || oldWidget.key != widget.key) {
      _startReveal();
    }
  }

  @override
  void dispose() {
    _animationToken++;
    super.dispose();
  }

  void _startReveal() {
    _animationToken++;
    final token = _animationToken;
    final categories = ModifierCategory.values;

    if (categories.length <= 1) {
      _displayedCategory = widget.category;
      _isSpinning = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          widget.onRevealComplete?.call();
        }
      });
      return;
    }

    final targetIndex = categories.indexOf(widget.category);
    final nextIndex = (targetIndex + 1) % categories.length;
    _displayedCategory = categories[nextIndex];
    _isSpinning = true;

    Future<void>.microtask(() async {
      for (final interval in _spinIntervals) {
        if (!mounted || token != _animationToken) return;
        await Future<void>.delayed(interval);
        if (!mounted || token != _animationToken) return;
        setState(() {
          final currentIndex = categories.indexOf(_displayedCategory);
          _displayedCategory =
              categories[(currentIndex + 1) % categories.length];
        });
      }

      if (!mounted || token != _animationToken) return;
      await Future<void>.delayed(const Duration(milliseconds: 420));
      if (!mounted || token != _animationToken) return;

      setState(() {
        _isSpinning = false;
        _displayedCategory = widget.category;
      });
      widget.onRevealComplete?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categories = ModifierCategory.values;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primaryContainer.withOpacity(0.45),
            theme.colorScheme.secondaryContainer.withOpacity(0.45),
          ],
        ),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.35),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Game Mode Roulette',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (final category in categories)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: _CategoryPill(
                      category: category,
                      isActive: category == _displayedCategory,
                      isFinal: !_isSpinning && category == widget.category,
                      isTarget: category == widget.category,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: Text(
              _isSpinning
                  ? 'Spinning up a category...'
                  : 'Mode locked: ${widget.category.displayName}',
              key: ValueKey<bool>(_isSpinning),
              style: theme.textTheme.bodyMedium,
            ),
          ),
          if (!_isSpinning) ...[
            const SizedBox(height: 6),
            Text(
              widget.category.tagline,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CategoryPill extends StatelessWidget {
  const _CategoryPill({
    required this.category,
    required this.isActive,
    required this.isFinal,
    required this.isTarget,
  });

  final ModifierCategory category;
  final bool isActive;
  final bool isFinal;
  final bool isTarget;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeColor = isTarget
        ? theme.colorScheme.secondary
        : theme.colorScheme.primary;
    final baseColor = isActive ? activeColor : theme.colorScheme.surface;
    final borderColor = isFinal
        ? activeColor
        : theme.colorScheme.primary.withOpacity(isActive ? 0.45 : 0.25);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: isFinal ? 2 : 1.3),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: activeColor.withOpacity(0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            category.displayName,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: isFinal ? FontWeight.w700 : FontWeight.w600,
              color: isActive
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          AnimatedOpacity(
            opacity: isFinal ? 1 : 0,
            duration: const Duration(milliseconds: 220),
            child: Icon(
              Icons.check_circle_rounded,
              size: 20,
              color: theme.colorScheme.onPrimary,
            ),
          ),
        ],
      ),
    );
  }
}