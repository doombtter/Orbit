import 'package:cryptography/cryptography.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'secret_crypto.dart';

/// 그룹별 비밀 메모용 AES 키를 메모리에만 보관.
///
/// 의도적으로 디스크에 안 저장:
///   - 앱 재시작 시 비밀번호 다시 입력 → "잠긴" 상태가 일관됨
///   - 디바이스 탈취 시 메모리 덤프 외엔 키 노출 불가
///
/// 추후 옵션으로 flutter_secure_storage(키체인/키스토어) 캐시 추가 가능.
/// 그땐 디바이스 잠금(Face ID/지문) 의존.
class SecretKeyStore {
  final Map<String, SecretKey> _keys = {};

  void put(String groupId, SecretKey key) {
    _keys[groupId] = key;
  }

  SecretKey? get(String groupId) => _keys[groupId];

  bool isUnlocked(String groupId) => _keys.containsKey(groupId);

  void lock(String groupId) {
    _keys.remove(groupId);
  }

  void lockAll() {
    _keys.clear();
  }

  /// 비밀번호 + salt로 키 유도 후, verifier 복호화로 검증. 성공 시 키 캐시.
  /// 비밀번호가 틀리면 false 반환 (예외 안 던짐 — 호출자가 UX 처리하기 쉽게).
  Future<bool> tryUnlock({
    required String groupId,
    required String password,
    required String saltBase64,
    required EncryptedBlob verifier,
  }) async {
    try {
      final key = await SecretCrypto.deriveKey(
        password: password,
        saltBase64: saltBase64,
      );
      final clear =
          await SecretCrypto.decrypt(blob: verifier, key: key);
      if (clear != SecretCrypto.verifyPlaintext) return false;
      put(groupId, key);
      return true;
    } catch (_) {
      return false;
    }
  }
}

final secretKeyStoreProvider = Provider<SecretKeyStore>((ref) {
  final store = SecretKeyStore();
  // 앱 종료 시 자동 정리
  ref.onDispose(store.lockAll);
  return store;
});

/// 특정 그룹의 잠금 상태를 watch — UI 잠금/해제 화면 분기에 사용.
/// SecretKeyStore는 Provider 외에서 변경되므로 별도 StateProvider로 추적.
final groupUnlockStatusProvider =
    StateProvider.family<bool, String>((ref, groupId) => false);
