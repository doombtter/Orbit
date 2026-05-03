import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../domain/app_user.dart';

class AuthRepository {
  AuthRepository({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  /// 익명 로그인 — 개발 단계에서 빠른 진입용
  Future<User?> signInAnonymously() async {
    final cred = await _auth.signInAnonymously();
    if (cred.user != null) {
      await _ensureUserDoc(cred.user!);
    }
    return cred.user;
  }

  Future<void> signOut() => _auth.signOut();

  /// 사용자 문서가 없으면 생성
  Future<void> _ensureUserDoc(User user) async {
    final ref = _firestore.collection('users').doc(user.uid);
    final snap = await ref.get();
    if (!snap.exists) {
      await ref.set(
        AppUser(
          uid: user.uid,
          name: user.displayName ?? 'Orbit user',
          email: user.email ?? '',
          photoUrl: user.photoURL,
        ).toFirestore(),
      );
    }
  }

  /// 현재 사용자 문서 스트림
  Stream<AppUser?> currentAppUserStream() {
    return _auth.authStateChanges().asyncExpand((u) {
      if (u == null) return Stream.value(null);
      return _firestore
          .collection('users')
          .doc(u.uid)
          .snapshots()
          .map((doc) => doc.exists ? AppUser.fromFirestore(doc) : null);
    });
  }
}
