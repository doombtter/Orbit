import 'package:cloud_firestore/cloud_firestore.dart';

/// 앱 사용자 — Firestore users/{uid}
class AppUser {
  const AppUser({
    required this.uid,
    required this.name,
    required this.email,
    this.photoUrl,
    this.groupIds = const [],
  });

  final String uid;
  final String name;
  final String email;
  final String? photoUrl;
  final List<String> groupIds;

  factory AppUser.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return AppUser(
      uid: doc.id,
      name: d['name'] as String? ?? '',
      email: d['email'] as String? ?? '',
      photoUrl: d['photoUrl'] as String?,
      groupIds: List<String>.from(d['groupIds'] as List? ?? []),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'name': name,
        'email': email,
        'photoUrl': photoUrl,
        'groupIds': groupIds,
        'updatedAt': FieldValue.serverTimestamp(),
      };
}
