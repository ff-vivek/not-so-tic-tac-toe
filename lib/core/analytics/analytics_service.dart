import 'package:firebase_analytics/firebase_analytics.dart';

/// Thin wrapper around FirebaseAnalytics with strongly-typed helpers
/// for the events defined in docs/tasks_breakdown.md (User Story 4.2).
class AnalyticsService {
  AnalyticsService(this._analytics);

  final FirebaseAnalytics _analytics;

  // Event names
  static const String _evMatchStart = 'match_start';
  static const String _evMatchEnd = 'match_end';
  static const String _evModifierPlayed = 'modifier_played';
  static const String _evShareButtonClick = 'share_button_click';
  static const String _evStoreVisit = 'store_visit';
  static const String _evMatchSearchStart = 'match_search_start';

  Future<void> matchSearchStart() {
    return _analytics.logEvent(name: _evMatchSearchStart);
  }

  Future<void> matchStart({
    required String matchId,
    String? modifierCategory,
    String? modifierId,
  }) async {
    await _analytics.logEvent(
      name: _evMatchStart,
      parameters: {
        'match_id': matchId,
        if (modifierCategory != null) 'modifier_category': modifierCategory,
        if (modifierId != null) 'modifier_id': modifierId,
      },
    );

    if (modifierId != null || modifierCategory != null) {
      await _analytics.logEvent(
        name: _evModifierPlayed,
        parameters: {
          'match_id': matchId,
          if (modifierCategory != null) 'modifier_category': modifierCategory,
          if (modifierId != null) 'modifier_id': modifierId,
        },
      );
    }
  }

  Future<void> matchEnd({
    required String matchId,
    required String status, // 'won' | 'draw'
    String? winnerPlayerId,
    String? trigger, // optional: 'board' | 'forfeit' | 'ultimate'
  }) {
    return _analytics.logEvent(
      name: _evMatchEnd,
      parameters: {
        'match_id': matchId,
        'status': status,
        if (winnerPlayerId != null) 'winner_player_id': winnerPlayerId,
        if (trigger != null) 'trigger': trigger,
      },
    );
  }

  Future<void> shareButtonClick({
    required String matchId,
    required String target, // 'general' | 'tiktok' | 'instagram'
  }) {
    return _analytics.logEvent(
      name: _evShareButtonClick,
      parameters: {
        'match_id': matchId,
        'target': target,
      },
    );
  }

  Future<void> storeVisit({String? source}) {
    return _analytics.logEvent(
      name: _evStoreVisit,
      parameters: {
        if (source != null) 'source': source,
      },
    );
  }
}
