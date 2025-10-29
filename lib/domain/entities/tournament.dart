import 'package:cloud_firestore/cloud_firestore.dart';

enum TournamentStatus { scheduled, recruiting, inProgress, completed }

class Tournament {
  const Tournament({
    required this.id,
    required this.name,
    required this.status,
    required this.participants,
    required this.maxPlayers,
    required this.createdAt,
    this.startsAt,
  });

  final String id;
  final String name;
  final TournamentStatus status;
  final List<String> participants;
  final int maxPlayers;
  final DateTime createdAt;
  final DateTime? startsAt;

  bool get isFull => participants.length >= maxPlayers;

  static Tournament fromMap(String id, Map<String, dynamic> data) {
    return Tournament(
      id: id,
      name: (data['name'] as String?) ?? 'Tournament',
      status: _statusFromString((data['status'] as String?) ?? 'recruiting'),
      participants: List<String>.from((data['participants'] as List?) ?? const <String>[]),
      maxPlayers: (data['maxPlayers'] as num?)?.toInt() ?? 16,
      createdAt: _readTimestamp(data['createdAt']) ?? DateTime.now(),
      startsAt: _readTimestamp(data['startsAt']),
    );
  }

  static TournamentStatus _statusFromString(String value) {
    switch (value) {
      case 'scheduled':
        return TournamentStatus.scheduled;
      case 'in_progress':
        return TournamentStatus.inProgress;
      case 'completed':
        return TournamentStatus.completed;
      case 'recruiting':
      default:
        return TournamentStatus.recruiting;
    }
  }

  static String _statusToString(TournamentStatus status) {
    switch (status) {
      case TournamentStatus.scheduled:
        return 'scheduled';
      case TournamentStatus.inProgress:
        return 'in_progress';
      case TournamentStatus.completed:
        return 'completed';
      case TournamentStatus.recruiting:
      default:
        return 'recruiting';
    }
  }

  static DateTime? _readTimestamp(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'status': _statusToString(status),
      'participants': participants,
      'maxPlayers': maxPlayers,
      'createdAt': Timestamp.fromDate(createdAt),
      'startsAt': startsAt == null ? null : Timestamp.fromDate(startsAt!),
    };
  }
}
