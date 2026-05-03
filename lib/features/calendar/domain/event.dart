import 'package:cloud_firestore/cloud_firestore.dart';

class CalendarEvent {
  const CalendarEvent({
    required this.id,
    required this.groupId,
    required this.title,
    required this.startAt,
    required this.endAt,
    required this.createdBy,
    this.description,
    this.assignedTo = const [],
    this.locationRef,
  });

  final String id;
  final String groupId;
  final String title;
  final String? description;
  final DateTime startAt;
  final DateTime endAt;
  final String createdBy;
  final List<String> assignedTo;

  /// 지도 핀과 약하게 연결 — 옵션 (pins/{pinId})
  final String? locationRef;

  factory CalendarEvent.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
    String groupId,
  ) {
    final d = doc.data() ?? {};
    return CalendarEvent(
      id: doc.id,
      groupId: groupId,
      title: d['title'] as String? ?? '',
      description: d['description'] as String?,
      startAt: (d['startAt'] as Timestamp).toDate(),
      endAt: (d['endAt'] as Timestamp).toDate(),
      createdBy: d['createdBy'] as String? ?? '',
      assignedTo: List<String>.from(d['assignedTo'] as List? ?? []),
      locationRef: d['locationRef'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'title': title,
        'description': description,
        'startAt': Timestamp.fromDate(startAt),
        'endAt': Timestamp.fromDate(endAt),
        'createdBy': createdBy,
        'assignedTo': assignedTo,
        'locationRef': locationRef,
        'updatedAt': FieldValue.serverTimestamp(),
      };
}
