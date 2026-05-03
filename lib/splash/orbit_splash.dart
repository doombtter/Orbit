import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/orbit_tokens.dart';
import '../features/auth/presentation/providers/auth_providers.dart';

/// 스플래시 시퀀스 (총 2.4초)
/// 0.0–0.8s: 궤도 그리기
/// 0.8–1.2s: 핀 + 멤버 도트 페이드인
/// 1.2–1.7s: O가 작아지며 왼쪽으로 이동, 핀/도트 페이드아웃
/// 1.7–2.4s: r·b·i·t 차례로 등장
class OrbitSplash extends ConsumerStatefulWidget {
  const OrbitSplash({super.key});

  @override
  ConsumerState<OrbitSplash> createState() => _OrbitSplashState();
}

class _OrbitSplashState extends ConsumerState<OrbitSplash>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..forward();

    _ctrl.addStatusListener((status) async {
      if (status == AnimationStatus.completed && mounted) {
        final user = ref.read(authStateProvider).value;
        await Future<void>.delayed(const Duration(milliseconds: 200));
        if (!mounted) return;
        context.go(user == null ? '/sign-in' : '/calendar');
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OrbitTokens.primary,
      body: Center(
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) => CustomPaint(
            size: const Size(320, 120),
            painter: _OrbitSplashPainter(_ctrl.value),
          ),
        ),
      ),
    );
  }
}

class _OrbitSplashPainter extends CustomPainter {
  _OrbitSplashPainter(this.t);

  /// 0.0 ~ 1.0
  final double t;

  static const _ringR = 40.0;
  static const _ringStroke = 11.0;

  /// 워드마크는 따뜻한 베이지(=배경 톤), 핀은 액센트 베이지
  static const _foreground = OrbitTokens.background; // #FAFAF7
  static const _pinColor = OrbitTokens.accent;       // #D4A574

  /// 멤버 도트는 멤버 팔레트의 첫 두 색을 미리보기
  static final _memberA = OrbitTokens.memberPalette[0]; // Indigo
  static final _memberB = OrbitTokens.memberPalette[2]; // Emerald

  double _phase(double start, double end) {
    if (t <= start) return 0;
    if (t >= end) return 1;
    return (t - start) / (end - start);
  }

  double _easeOut(double v) => 1 - math.pow(1 - v, 3).toDouble();
  double _easeInOut(double v) =>
      v < 0.5 ? 2 * v * v : 1 - math.pow(-2 * v + 2, 2).toDouble() / 2;

  @override
  void paint(Canvas canvas, Size size) {
    final ringPhase = _easeOut(_phase(0, 800 / 2400));
    final pinPhase = _easeOut(_phase(800 / 2400, 1200 / 2400));
    final movePhase = _easeInOut(_phase(1200 / 2400, 1700 / 2400));

    final tx = -78.0 * movePhase;
    final scale = 1.0 - 0.4 * movePhase;
    final cx = size.width / 2 + tx;
    final cy = size.height / 2;

    canvas.save();
    canvas.translate(cx, cy);
    canvas.scale(scale);

    // 1. 궤도 (12시 방향에서 시계방향으로)
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _ringStroke
      ..strokeCap = StrokeCap.round
      ..color = _foreground;

    final ringPath = Path()
      ..addArc(
        Rect.fromCircle(center: Offset.zero, radius: _ringR),
        -math.pi / 2,
        2 * math.pi * ringPhase,
      );
    canvas.drawPath(ringPath, ringPaint);

    // 2. 핀 + 멤버 도트 (이동 시작하면 페이드아웃)
    final fadeOut = movePhase > 0.3 ? (1 - (movePhase - 0.3) / 0.7) : 1.0;
    final pinAlpha = (pinPhase * fadeOut).clamp(0.0, 1.0);

    if (pinAlpha > 0.01) {
      _drawPin(canvas, pinAlpha);
      _drawDot(canvas, const Offset(40, 0), _memberA, pinAlpha);
      _drawDot(canvas, const Offset(-40, 0), _memberB, pinAlpha);
    }

    canvas.restore();

    // 3. r·b·i·t 글자
    // O(궤도)의 시각 중심은 (cx, cy). O는 이동 후 scale 0.6.
    // 워드마크의 시각적 시작점: O의 오른쪽 끝에서 살짝 안쪽으로 들어가
    // "Orbit"이 한 단어처럼 붙어 보이게 함.
    const letters = ['r', 'b', 'i', 't'];
    const starts = [1700, 1850, 2000, 2150];

    // O의 최종 반지름 ≈ 24, stroke 영향까지 고려한 시각적 오른쪽 끝.
    // 거기서 약간 떨어뜨려 'O'와 'rbit'이 자연스럽게 한 단어로 읽히는 간격.
    var penX = cx + 30;

    for (var i = 0; i < letters.length; i++) {
      final lp =
          _easeOut(_phase(starts[i] / 2400, (starts[i] + 250) / 2400));

      // 미리 폭 측정 (애니메이션 진행도와 무관하게 일정한 폭 확보)
      final width = _measureLetterWidth(letters[i]);

      if (lp > 0) {
        _drawLetter(
          canvas,
          letters[i],
          Offset(penX, cy + (1 - lp) * 8),
          lp,
        );
      }
      penX += width;
    }
  }

  double _measureLetterWidth(String char) {
    final tp = TextPainter(
      text: TextSpan(text: char, style: _letterStyle(1.0)),
      textDirection: TextDirection.ltr,
    )..layout();
    return tp.width;
  }

  TextStyle _letterStyle(double alpha) => TextStyle(
        color: _foreground.withValues(alpha: alpha),
        fontSize: 56,
        fontWeight: FontWeight.w500,
        letterSpacing: -1.5,
        height: 1.0,
      );

  void _drawPin(Canvas canvas, double alpha) {
    final paint = Paint()..color = _pinColor.withValues(alpha: alpha);
    final path = Path()
      ..moveTo(0, -11)
      ..cubicTo(6.5, -11, 12, -5.5, 12, 0)
      ..cubicTo(12, 5, 8, 10, 0, 18)
      ..cubicTo(-8, 10, -12, 5, -12, 0)
      ..cubicTo(-12, -5.5, -6.5, -11, 0, -11)
      ..close();
    canvas.drawPath(path, paint);
    canvas.drawCircle(
      const Offset(0, -0.5),
      3.5,
      Paint()..color = _foreground.withValues(alpha: alpha),
    );
  }

  void _drawDot(Canvas canvas, Offset pos, Color color, double alpha) {
    canvas.drawCircle(
      pos,
      4.5,
      Paint()..color = color.withValues(alpha: alpha),
    );
  }

  void _drawLetter(Canvas canvas, String char, Offset pos, double alpha) {
    final tp = TextPainter(
      text: TextSpan(text: char, style: _letterStyle(alpha)),
      textDirection: TextDirection.ltr,
    )..layout();

    // 폰트 메트릭 기반 시각적 중심 정렬.
    // 라틴 소문자(r, b, i, t)는 ascender 영역이 비어 있어서, 글자 박스의
    // 산술 중앙(0.5)에 맞추면 시각적으로 위로 떠 보임. 18% 추가 하향
    // 보정해서 무게중심을 O의 중심선(cy)과 일치시킴.
    final yOffset = pos.dy - tp.height / 2 + tp.height * 0.18;
    tp.paint(canvas, Offset(pos.dx, yOffset));
  }

  @override
  bool shouldRepaint(_OrbitSplashPainter old) => old.t != t;
}
