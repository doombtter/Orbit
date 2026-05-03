import 'package:flutter/material.dart';

import '../theme/orbit_tokens.dart';

enum OrbitButtonVariant {
  /// 차콜 배경 + 흰 글자. 화면당 0~1개의 주요 액션.
  primary,

  /// 베이지 배경 + 차콜 글자. CTA 전용. 화면당 0~1개.
  accent,

  /// 흰 배경 + 아웃라인. 보조 액션.
  outline,

  /// 배경 없음. 취소·나중에 등 약한 액션.
  ghost,
}

class OrbitButton extends StatelessWidget {
  const OrbitButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = OrbitButtonVariant.primary,
    this.icon,
    this.fullWidth = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final OrbitButtonVariant variant;
  final IconData? icon;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final config = _config();

    final child = Row(
      mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18),
          const SizedBox(width: OrbitTokens.space8),
        ],
        Text(label),
      ],
    );

    final style = ButtonStyle(
      backgroundColor: WidgetStatePropertyAll(config.background),
      foregroundColor: WidgetStatePropertyAll(config.foreground),
      side: WidgetStatePropertyAll(config.border),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(OrbitTokens.radiusMd),
        ),
      ),
      textStyle: const WidgetStatePropertyAll(
        TextStyle(fontSize: OrbitTokens.fsBody, fontWeight: FontWeight.w500),
      ),
      elevation: const WidgetStatePropertyAll(0),
    );

    final button = TextButton(onPressed: onPressed, style: style, child: child);

    return fullWidth ? SizedBox(width: double.infinity, child: button) : button;
  }

  _ButtonConfig _config() {
    switch (variant) {
      case OrbitButtonVariant.primary:
        return _ButtonConfig(
          background: OrbitTokens.primary,
          foreground: OrbitTokens.background,
          border: BorderSide.none,
        );
      case OrbitButtonVariant.accent:
        return _ButtonConfig(
          background: OrbitTokens.accent,
          foreground: OrbitTokens.primary80,
          border: BorderSide.none,
        );
      case OrbitButtonVariant.outline:
        return _ButtonConfig(
          background: OrbitTokens.surface,
          foreground: OrbitTokens.primary,
          border: const BorderSide(color: OrbitTokens.border, width: 0.5),
        );
      case OrbitButtonVariant.ghost:
        return _ButtonConfig(
          background: Colors.transparent,
          foreground: OrbitTokens.primary60,
          border: BorderSide.none,
        );
    }
  }
}

class _ButtonConfig {
  const _ButtonConfig({
    required this.background,
    required this.foreground,
    required this.border,
  });
  final Color background;
  final Color foreground;
  final BorderSide border;
}
