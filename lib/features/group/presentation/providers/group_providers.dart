import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/group_repository.dart';
import '../../domain/group.dart';

final groupRepositoryProvider = Provider<GroupRepository>((ref) {
  return GroupRepository();
});

/// 현재 사용자가 속한 그룹 목록
final userGroupsProvider = StreamProvider<List<Group>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value([]);
  return ref.watch(groupRepositoryProvider).watchUserGroups(user.uid);
});

/// 현재 선택된 그룹 ID — 캘린더/지도가 이 값을 watch
final selectedGroupIdProvider = StateProvider<String?>((ref) => null);
