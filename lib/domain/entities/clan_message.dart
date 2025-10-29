import 'package:cloud_firestore/cloud_firestore.dart';

class ClanMessage {
  const ClanMessage({
    required this.id,
    required this.senderId,
    required this.text,
    required this.sentAt,
  });

  final String id;
  final String senderId;
  final String text;
  final DateTime sentAt;

  static ClanMessage fromMap(String id, Map<String, dynamic> data) {
    return ClanMessage(
      id: id,
      senderId: (data['senderId'] as String?) ?? '',
      text: (data['text'] as String?) ?? '',
      sentAt: _readTs(data['sentAt']) ?? DateTime.now(),
    );
  }

  static DateTime? _readTs(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'text': text,
      'sentAt': Timestamp.fromDate(sentAt),
    };
  }
}
