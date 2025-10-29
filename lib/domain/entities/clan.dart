import 'package:cloud_firestore/cloud_firestore.dart';

class Clan {
  const Clan({
    required this.id,
    required this.name,
    required this.ownerId,
    required this.members,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String ownerId;
  final List<String> members;
  final DateTime createdAt;

  static Clan fromMap(String id, Map<String, dynamic> data) {
    return Clan(
      id: id,
      name: (data['name'] as String?) ?? 'Clan',
      ownerId: (data['ownerId'] as String?) ?? '',
      members: List<String>.from((data['members'] as List?) ?? const <String>[]),
      createdAt: _readTimestamp(data['createdAt']) ?? DateTime.now(),
    );
  }

  static DateTime? _readTimestamp(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'ownerId': ownerId,
      'members': members,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
