import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../domain/memo.dart';

class MemoRepository {
  MemoRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  final _uuid = const Uuid();

  CollectionReference<Map<String, dynamic>> _memosOf(String groupId) =>
      _firestore.collection('groups').doc(groupId).collection('memos');

  Stream<List<Memo>> watchGroup(String groupId) {
    return _memosOf(groupId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => Memo.fromFirestore(d, groupId)).toList());
  }

  Future<Memo> create(Memo memo) async {
    final id = memo.id.isEmpty ? _uuid.v4() : memo.id;
    final toSave = Memo(
      id: id,
      groupId: memo.groupId,
      title: memo.title,
      isSecret: memo.isSecret,
      body: memo.body,
      secret: memo.secret,
      createdBy: memo.createdBy,
      createdAt: memo.createdAt ?? DateTime.now(),
    );
    await _memosOf(memo.groupId).doc(id).set(toSave.toFirestore());
    return toSave;
  }

  Future<void> update(Memo memo) {
    return _memosOf(memo.groupId).doc(memo.id).update(memo.toFirestore());
  }

  Future<void> delete({required String groupId, required String memoId}) {
    return _memosOf(groupId).doc(memoId).delete();
  }
}
