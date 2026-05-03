import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/auth_repository.dart';
import '../../domain/app_user.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

/// Firebase 인증 상태 — 라우터 가드의 진실 소스
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});

/// 현재 앱 사용자 (Firestore 문서) — 그룹 ID 등 추가 정보 포함
final currentAppUserProvider = StreamProvider<AppUser?>((ref) {
  return ref.watch(authRepositoryProvider).currentAppUserStream();
});
