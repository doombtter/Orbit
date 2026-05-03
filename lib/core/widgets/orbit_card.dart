import 'package:flutter/material.dart';

import '../theme/orbit_tokens.dart';

/// Orbit 표준 카드. 그룹·이벤트·핀 모든 리스트 항목의 기본 컨테이너.
/// onTap이 있으면 InkWell로 감싸서 탭 가능.
class OrbitCard extends StatelessWidget {
  const OrbitCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(OrbitTokens.space16),
    this.radius = OrbitTokens.radiusXl,
    this.background,
    this.border = true,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets padding;
  final double radius;
  final Color? background;
  final bool border;

  @override
  Widget build(BuildContext context) {
    final shape = BorderRadius.circular(radius);

    final container = Material(
      color: background ?? OrbitTokens.surface,
      borderRadius: shape,
      child: InkWell(
        onTap: onTap,
        borderRadius: shape,
        child: Padding(padding: padding, child: child),
      ),
    );

    if (!border) return container;

    return Container(
      decoration: BoxDecoration(
        borderRadius: shape,
        border: Border.all(color: OrbitTokens.border, width: 0.5),
      ),
      child: container,
    );
  }
}
