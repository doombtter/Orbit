import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/memo_repository.dart';
import '../../domain/memo.dart';

final memoRepositoryProvider = Provider<MemoRepository>((ref) {
  return MemoRepository();
});

/// 그룹 ID → 메모 목록 스트림
final groupMemosProvider =
    StreamProvider.family<List<Memo>, String>((ref, groupId) {
  return ref.watch(memoRepositoryProvider).watchGroup(groupId);
});
