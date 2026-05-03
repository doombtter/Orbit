import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/event.dart';

class EventRepository {
  EventRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _eventsOf(String groupId) =>
      _firestore.collection('groups').doc(groupId).collection('events');

  /// 특정 월의 이벤트 스트림
  Stream<List<CalendarEvent>> watchMonth({
    required String groupId,
    required DateTime month,
  }) {
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 1);
    return _eventsOf(groupId)
        .where('startAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('startAt', isLessThan: Timestamp.fromDate(end))
        .snapshots()
        .map((s) => s.docs.map((d) => CalendarEvent.fromFirestore(d, groupId)).toList());
  }

  Future<void> create(CalendarEvent event) {
    return _eventsOf(event.groupId).doc(event.id).set(event.toFirestore());
  }

  Future<void> delete({required String groupId, required String eventId}) {
    return _eventsOf(groupId).doc(eventId).delete();
  }
}
