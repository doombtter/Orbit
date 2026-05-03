import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_theme.dart';
import 'router.dart';

class OrbitApp extends ConsumerWidget {
  const OrbitApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Orbit',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      // 다크 테마는 v0.8 이후 본격 다듬을 예정. 일단 라이트 고정.
      themeMode: ThemeMode.light,
      routerConfig: router,
    );
  }
}
