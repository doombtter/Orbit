import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/orbit_tokens.dart';
import '../../../../core/widgets/orbit_button.dart';
import '../providers/auth_providers.dart';

class SignInScreen extends ConsumerWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(flex: 2),
              const _OrbitWordmark(),
              const SizedBox(height: OrbitTokens.space12),
              Text(
                '함께 도는 캘린더와 지도',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: OrbitTokens.primary60,
                    ),
              ),
              const Spacer(flex: 3),
              OrbitButton(
                label: '시작하기',
                fullWidth: true,
                onPressed: () async {
                  await ref.read(authRepositoryProvider).signInAnonymously();
                },
              ),
              const SizedBox(height: OrbitTokens.space12),
              OrbitButton(
                label: 'Google로 계속하기',
                variant: OrbitButtonVariant.outline,
                fullWidth: true,
                icon: Icons.login,
                onPressed: null, // TODO: 구글 로그인 연동
              ),
              const SizedBox(height: OrbitTokens.space20),
              Center(
                child: Text(
                  '계속하면 이용약관에 동의하는 것으로 간주됩니다',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: OrbitTokens.primary40,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrbitWordmark extends StatelessWidget {
  const _OrbitWordmark();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 52,
          height: 52,
          child: CustomPaint(painter: _LogoPainter()),
        ),
        const SizedBox(width: OrbitTokens.space12),
        const Text(
          'rbit',
          style: TextStyle(
            fontSize: 44,
            fontWeight: FontWeight.w500,
            letterSpacing: -1.2,
            color: OrbitTokens.primary,
            height: 1.0,
          ),
        ),
      ],
    );
  }
}

class _LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    canvas.drawCircle(
      Offset(cx, cy),
      18,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..color = OrbitTokens.primary,
    );

    // 핀 (12시 방향)
    canvas.save();
    canvas.translate(cx, cy - 18);
    final pinPath = Path()
      ..moveTo(0, -5)
      ..cubicTo(2.8, -5, 5, -2.8, 5, 0)
      ..cubicTo(5, 2.5, 3.5, 5, 0, 9)
      ..cubicTo(-3.5, 5, -5, 2.5, -5, 0)
      ..cubicTo(-5, -2.8, -2.8, -5, 0, -5)
      ..close();
    canvas.drawPath(pinPath, Paint()..color = OrbitTokens.accent);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
