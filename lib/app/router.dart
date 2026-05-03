import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/orbit_tokens.dart';
import '../core/widgets/orbit_nav_bar.dart';
import '../features/auth/presentation/providers/auth_providers.dart';
import '../features/auth/presentation/screens/sign_in_screen.dart';
import '../features/calendar/presentation/screens/calendar_screen.dart';
import '../features/group/presentation/screens/group_list_screen.dart';
import '../features/map/presentation/screens/map_screen.dart';
import '../splash/orbit_splash.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isLoggedIn = authState.value != null;
      final loggingIn = state.matchedLocation == '/sign-in';
      final atSplash = state.matchedLocation == '/splash';

      if (atSplash) return null;
      if (!isLoggedIn && !loggingIn) return '/sign-in';
      if (isLoggedIn && loggingIn) return '/calendar';
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (_, __) => const OrbitSplash(),
      ),
      GoRoute(
        path: '/sign-in',
        builder: (_, __) => const SignInScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => HomeShell(child: child),
        routes: [
          GoRoute(
            path: '/calendar',
            builder: (_, __) => const CalendarScreen(),
          ),
          GoRoute(
            path: '/map',
            builder: (_, __) => const MapScreen(),
          ),
          GoRoute(
            path: '/more',
            builder: (_, __) => const MoreScreen(),
            routes: [
              GoRoute(
                path: 'groups',
                builder: (_, __) => const GroupListScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

class HomeShell extends StatelessWidget {
  const HomeShell({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final index = switch (location) {
      '/calendar' => 0,
      '/map' => 1,
      _ when location.startsWith('/more') => 2,
      _ => 0,
    };

    return Scaffold(
      // extendBody: 컨텐츠가 하단 네비 뒤로 들어가서 떠 있는 느낌이 살아남.
      // 각 화면에서는 SliverPadding이나 SafeArea bottom을 추가해 컨텐츠가
      // 네비에 가리지 않게 처리.
      extendBody: true,
      body: child,
      bottomNavigationBar: OrbitNavBar(
        currentIndex: index,
        onTap: (i) {
          switch (i) {
            case 0:
              context.go('/calendar');
            case 1:
              context.go('/map');
            case 2:
              context.go('/more');
          }
        },
        items: const [
          OrbitNavItem(icon: Icons.calendar_today_outlined, label: '캘린더'),
          OrbitNavItem(icon: Icons.map_outlined, label: '지도'),
          OrbitNavItem(icon: Icons.menu_outlined, label: '더보기'),
        ],
      ),
    );
  }
}

/// 더보기 탭 — 그룹 관리, 멤버, 설정으로 진입
class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OrbitTokens.background,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            OrbitTokens.space20,
            OrbitTokens.space20,
            OrbitTokens.space20,
            120, // 하단 네비 + 여유
          ),
          children: [
            const Text(
              '더보기',
              style: TextStyle(
                fontSize: OrbitTokens.fsDisplay,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.5,
                color: OrbitTokens.primary,
                height: 1.1,
              ),
            ),
            const SizedBox(height: OrbitTokens.space24),
            _MoreTile(
              icon: Icons.public,
              label: '내 궤도',
              subtitle: '그룹 관리',
              onTap: () => context.go('/more/groups'),
            ),
            const _MoreTile(
              icon: Icons.person_outline,
              label: '프로필',
              subtitle: '이름, 사진',
              onTap: null,
            ),
            const _MoreTile(
              icon: Icons.notifications_outlined,
              label: '알림',
              subtitle: '푸시 설정',
              onTap: null,
            ),
            const _MoreTile(
              icon: Icons.settings_outlined,
              label: '설정',
              subtitle: '테마, 언어',
              onTap: null,
            ),
          ],
        ),
      ),
    );
  }
}

class _MoreTile extends StatelessWidget {
  const _MoreTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: OrbitTokens.space10),
      child: Material(
        color: OrbitTokens.surface,
        borderRadius: BorderRadius.circular(OrbitTokens.radiusXl),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(OrbitTokens.radiusXl),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(OrbitTokens.radiusXl),
              border: Border.all(color: OrbitTokens.border, width: 0.5),
            ),
            padding: const EdgeInsets.all(OrbitTokens.space16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: OrbitTokens.surfaceDim,
                    borderRadius: BorderRadius.circular(OrbitTokens.radiusMd),
                  ),
                  child: Icon(icon, size: 20, color: OrbitTokens.primary),
                ),
                const SizedBox(width: OrbitTokens.space14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          fontSize: OrbitTokens.fsTitle,
                          fontWeight: FontWeight.w500,
                          color: OrbitTokens.primary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: OrbitTokens.fsCaption,
                          color: OrbitTokens.primary40,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: OrbitTokens.primary40,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
