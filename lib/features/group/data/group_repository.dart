import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../../../core/crypto/secret_crypto.dart';
import '../domain/group.dart';

class GroupRepository {
  GroupRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  final _uuid = const Uuid();
  final _rand = Random.secure();

  CollectionReference<Map<String, dynamic>> get _groups =>
      _firestore.collection('groups');
  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  /// 사용자가 속한 그룹 스트림
  Stream<List<Group>> watchUserGroups(String uid) {
    return _groups
        .where('memberIds', arrayContains: uid)
        .snapshots()
        .map((s) => s.docs.map(Group.fromFirestore).toList());
  }

  Future<Group?> findByInviteCode(String inviteCode) async {
    final snap = await _groups
        .where('inviteCode', isEqualTo: inviteCode)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    return Group.fromFirestore(snap.docs.first);
  }

  /// 그룹 생성. 비밀 메모를 활성화하면 자동 비밀번호를 생성하고 [autoPassword]로 반환.
  /// 호출자는 이 비밀번호를 초대 링크에 포함해야 함 (앱 내에 따로 저장하지 않음).
  Future<({Group group, String? autoPassword})> createGroup({
    required String name,
    required GroupType type,
    required String ownerId,
    required bool enableSecret,
  }) async {
    final groupId = _uuid.v4();
    final inviteCode = _generateInviteCode();

    String? salt;
    EncryptedBlob? verifier;
    String? autoPassword;

    if (enableSecret) {
      salt = SecretCrypto.generateSaltBase64();
      autoPassword = SecretCrypto.generateAutoPassword();
      final key = await SecretCrypto.deriveKey(
        password: autoPassword,
        saltBase64: salt,
      );
      verifier = await SecretCrypto.encrypt(
        plaintext: SecretCrypto.verifyPlaintext,
        key: key,
      );
    }

    final group = Group(
      id: groupId,
      name: name,
      type: type,
      ownerId: ownerId,
      memberIds: [ownerId],
      inviteCode: inviteCode,
      secretSalt: salt,
      secretVerifier: verifier,
    );

    await _firestore.runTransaction((tx) async {
      tx.set(_groups.doc(groupId), group.toFirestore());
      tx.update(_users.doc(ownerId), {
        'groupIds': FieldValue.arrayUnion([groupId]),
      });
    });

    return (group: group, autoPassword: autoPassword);
  }

  /// 초대 코드로 그룹 가입.
  Future<void> joinByInviteCode({
    required String inviteCode,
    required String uid,
  }) async {
    final group = await findByInviteCode(inviteCode);
    if (group == null) {
      throw const _GroupNotFoundException();
    }
    if (group.memberIds.contains(uid)) return; // 이미 멤버

    await _firestore.runTransaction((tx) async {
      tx.update(_groups.doc(group.id), {
        'memberIds': FieldValue.arrayUnion([uid]),
      });
      tx.update(_users.doc(uid), {
        'groupIds': FieldValue.arrayUnion([group.id]),
      });
    });
  }

  Future<void> leaveGroup({required String groupId, required String uid}) {
    return _firestore.runTransaction((tx) async {
      tx.update(_groups.doc(groupId), {
        'memberIds': FieldValue.arrayRemove([uid]),
      });
      tx.update(_users.doc(uid), {
        'groupIds': FieldValue.arrayRemove([groupId]),
      });
    });
  }

  /// 8자 무작위 영숫자 (대소 구분, 헷갈리는 문자 제외)
  String _generateInviteCode() {
    const chars = 'abcdefghijkmnpqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    return List.generate(8, (_) => chars[_rand.nextInt(chars.length)]).join();
  }
}

class _GroupNotFoundException implements Exception {
  const _GroupNotFoundException();
  @override
  String toString() => '초대 코드에 해당하는 그룹을 찾을 수 없어요';
}
