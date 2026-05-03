import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/crypto/secret_crypto.dart';

/// 그룹 공유 메모. 일반(평문) 또는 비밀(암호화) 두 종류.
///
/// Firestore 스키마: groups/{groupId}/memos/{memoId}
///   - title: String (항상 평문 — 검색/리스트 표시용)
///   - isSecret: bool
///   - body: String (isSecret=false일 때만, 평문)
///   - secret: { ciphertext, nonce, mac } (isSecret=true일 때만)
///   - createdBy, createdAt, updatedAt
class Memo {
  const Memo({
    required this.id,
    required this.groupId,
    required this.title,
    required this.isSecret,
    required this.createdBy,
    this.body,
    this.secret,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String groupId;
  final String title;
  final bool isSecret;

  /// 평문 본문 (isSecret=false)
  final String? body;

  /// 암호화된 본문 (isSecret=true)
  final EncryptedBlob? secret;

  final String createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory Memo.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
    String groupId,
  ) {
    final d = doc.data() ?? {};
    final isSecret = d['isSecret'] as bool? ?? false;
    return Memo(
      id: doc.id,
      groupId: groupId,
      title: d['title'] as String? ?? '',
      isSecret: isSecret,
      body: isSecret ? null : d['body'] as String?,
      secret: isSecret && d['secret'] != null
          ? EncryptedBlob.fromJson(
              Map<String, dynamic>.from(d['secret'] as Map),
            )
          : null,
      createdBy: d['createdBy'] as String? ?? '',
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (d['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'title': title,
        'isSecret': isSecret,
        if (!isSecret) 'body': body,
        if (isSecret && secret != null) 'secret': secret!.toJson(),
        'createdBy': createdBy,
        'createdAt': createdAt != null
            ? Timestamp.fromDate(createdAt!)
            : FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
}
