import 'dart:convert';

class AttendanceSession {
  final String sessionId;
  final String subject;
  final DateTime expiresAt;
  final double latitude;
  final double longitude;

  AttendanceSession({
    required this.sessionId,
    required this.subject,
    required this.expiresAt,
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toMap() {
    return {
      'sessionId': sessionId,
      'subject': subject,
      'expiresAt': expiresAt.millisecondsSinceEpoch,
      'lat': latitude,
      'lng': longitude,
    };
  }

  factory AttendanceSession.fromMap(Map<String, dynamic> map) {
    return AttendanceSession(
      sessionId: map['sessionId'] ?? '',
      subject: map['subject'] ?? '',
      expiresAt: DateTime.fromMillisecondsSinceEpoch(map['expiresAt'] ?? 0),
      latitude: (map['lat'] ?? 0.0).toDouble(),
      longitude: (map['lng'] ?? 0.0).toDouble(),
    );
  }

  String toJson() => json.encode(toMap());

  factory AttendanceSession.fromJson(String source) => 
      AttendanceSession.fromMap(json.decode(source));

  bool get isValid => DateTime.now().isBefore(expiresAt);
}
