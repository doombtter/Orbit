import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/crypto/secret_crypto.dart';

enum GroupType { family, couple, team, friends, other }

class Group {
  const Group({
    required this.id,
    required this.name,
    required this.type,
    required this.ownerId,
    required this.memberIds,
    required this.inviteCode,
    this.secretSalt,
    this.secretVerifier,
    this.createdAt,
  });

  final String id;
  final String name;
  final GroupType type;
  final String ownerId;
  final List<String> memberIds;

  /// 초대 링크용 짧은 코드. 그룹 ID와 별개로 두어 ID 노출 최소화.
  final String inviteCode;

  /// 비밀 메모용 salt (base64). null이면 비밀 메모 미활성.
  /// 한 번 설정되면 변경 불가 (변경 시 기존 비밀 메모 복호화 불가).
  final String? secretSalt;

  /// 비밀번호 검증용 — 알려진 평문(SecretCrypto.verifyPlaintext)을 그룹 키로
  /// 암호화한 결과. 잠금 해제 시 이걸 먼저 복호화해보고 성공해야 진행.
  final EncryptedBlob? secretVerifier;

  final DateTime? createdAt;

  bool get hasSecretEnabled => secretSalt != null && secretVerifier != null;

  factory Group.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return Group(
      id: doc.id,
      name: d['name'] as String? ?? '',
      type: GroupType.values.firstWhere(
        (t) => t.name == (d['type'] as String? ?? 'other'),
        orElse: () => GroupType.other,
      ),
      ownerId: d['ownerId'] as String? ?? '',
      memberIds: List<String>.from(d['memberIds'] as List? ?? []),
      inviteCode: d['inviteCode'] as String? ?? '',
      secretSalt: d['secretSalt'] as String?,
      secretVerifier: d['secretVerifier'] != null
          ? EncryptedBlob.fromJson(
              Map<String, dynamic>.from(d['secretVerifier'] as Map),
            )
          : null,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'name': name,
        'type': type.name,
        'ownerId': ownerId,
        'memberIds': memberIds,
        'inviteCode': inviteCode,
        if (secretSalt != null) 'secretSalt': secretSalt,
        if (secretVerifier != null)
          'secretVerifier': secretVerifier!.toJson(),
        'createdAt': createdAt != null
            ? Timestamp.fromDate(createdAt!)
            : FieldValue.serverTimestamp(),
      };
}
