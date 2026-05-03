import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';

/// 그룹 비밀번호 기반 클라이언트 사이드 암호화.
///
/// 흐름:
///   1. 그룹 만들 때 사용자가 비밀번호 설정
///   2. 무작위 salt 생성 → Firestore groups/{id}.secretSalt에 저장
///   3. PBKDF2(비밀번호, salt) → 32바이트 AES 키 유도
///   4. 메모마다 무작위 nonce 생성 → AES-GCM(키, nonce, 평문) → 암호문 + 태그
///   5. Firestore에 저장: { ciphertext, nonce, mac } (모두 base64)
///
/// 주의:
///   - 비밀번호 자체는 절대 Firestore에 저장하지 않음.
///   - salt는 평문 저장 (PBKDF2의 salt는 비밀이 아님).
///   - 비밀번호를 잊으면 데이터 복구 불가능. UI에서 명시적 경고 필수.
class SecretCrypto {
  SecretCrypto._();

  // OWASP 권장 (2023 기준) — 모바일 부하 고려해 최소값
  static const _pbkdf2Iterations = 100000;
  static const _saltBytes = 16;
  static const _keyBytes = 32; // AES-256

  static final _pbkdf2 = Pbkdf2(
    macAlgorithm: Hmac.sha256(),
    iterations: _pbkdf2Iterations,
    bits: _keyBytes * 8,
  );
  static final _aesGcm = AesGcm.with256bits();
  static final _rand = Random.secure();

  /// 새 그룹 생성 시 호출. 무작위 salt 생성.
  static String generateSaltBase64() {
    final bytes = List<int>.generate(_saltBytes, (_) => _rand.nextInt(256));
    return base64Encode(bytes);
  }

  /// 사용자에게 보여주지 않고 시스템이 자동 생성하는 강력한 비밀번호.
  /// 22자 base64url (≈ 132비트 엔트로피). 초대 링크에 포함됨.
  static String generateAutoPassword() {
    final bytes = List<int>.generate(16, (_) => _rand.nextInt(256));
    return base64Url.encode(bytes).replaceAll('=', '');
  }

  /// 비밀번호 검증용 알려진 평문. 키 유도 후 이걸 복호화해보면 비밀번호가 맞는지 알 수 있음.
  static const verifyPlaintext = 'orbit-verify-v1';

  /// 비밀번호 + salt → AES 키 유도. 결과는 메모리에만 보관.
  static Future<SecretKey> deriveKey({
    required String password,
    required String saltBase64,
  }) async {
    final salt = base64Decode(saltBase64);
    return _pbkdf2.deriveKeyFromPassword(password: password, nonce: salt);
  }

  /// 평문을 암호화. 결과 EncryptedBlob은 그대로 Firestore에 저장 가능.
  static Future<EncryptedBlob> encrypt({
    required String plaintext,
    required SecretKey key,
  }) async {
    final secretBox = await _aesGcm.encrypt(
      utf8.encode(plaintext),
      secretKey: key,
    );
    return EncryptedBlob(
      ciphertext: base64Encode(secretBox.cipherText),
      nonce: base64Encode(secretBox.nonce),
      mac: base64Encode(secretBox.mac.bytes),
    );
  }

  /// EncryptedBlob → 평문. 비밀번호가 틀리면 SecretBoxAuthenticationError 발생.
  static Future<String> decrypt({
    required EncryptedBlob blob,
    required SecretKey key,
  }) async {
    final secretBox = SecretBox(
      base64Decode(blob.ciphertext),
      nonce: base64Decode(blob.nonce),
      mac: Mac(base64Decode(blob.mac)),
    );
    final clear = await _aesGcm.decrypt(secretBox, secretKey: key);
    return utf8.decode(clear);
  }
}

/// Firestore에 저장 가능한 암호문 묶음.
class EncryptedBlob {
  const EncryptedBlob({
    required this.ciphertext,
    required this.nonce,
    required this.mac,
  });

  final String ciphertext;
  final String nonce;
  final String mac;

  Map<String, dynamic> toJson() => {
        'ciphertext': ciphertext,
        'nonce': nonce,
        'mac': mac,
      };

  factory EncryptedBlob.fromJson(Map<String, dynamic> j) => EncryptedBlob(
        ciphertext: j['ciphertext'] as String,
        nonce: j['nonce'] as String,
        mac: j['mac'] as String,
      );
}
