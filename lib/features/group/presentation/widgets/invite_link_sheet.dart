import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/orbit_tokens.dart';
import '../../../../core/widgets/orbit_button.dart';

class InviteLinkSheet extends StatelessWidget {
  const InviteLinkSheet({
    super.key,
    required this.groupName,
    required this.inviteLink,
    required this.hasSecret,
  });

  final String groupName;
  final Uri inviteLink;

  /// 비밀 메모가 활성화된 그룹인지. true면 추가 경고 문구 표시.
  final bool hasSecret;

  @override
  Widget build(BuildContext context) {
    final url = inviteLink.toString();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          OrbitTokens.space20,
          OrbitTokens.space12,
          OrbitTokens.space20,
          OrbitTokens.space20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: OrbitTokens.primary40,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: OrbitTokens.space20),
            Text(
              '$groupName 초대',
              style: const TextStyle(
                fontSize: OrbitTokens.fsHeading,
                fontWeight: FontWeight.w600,
                color: OrbitTokens.primary,
              ),
            ),
            const SizedBox(height: OrbitTokens.space6),
            const Text(
              '이 링크를 보내면 같은 궤도에 합류해요.',
              style: TextStyle(
                fontSize: OrbitTokens.fsLabel,
                color: OrbitTokens.primary60,
              ),
            ),
            const SizedBox(height: OrbitTokens.space20),

            // 링크 박스
            Container(
              padding: const EdgeInsets.all(OrbitTokens.space14),
              decoration: BoxDecoration(
                color: OrbitTokens.surfaceDim,
                borderRadius: BorderRadius.circular(OrbitTokens.radiusLg),
              ),
              child: Text(
                url,
                style: const TextStyle(
                  fontSize: OrbitTokens.fsCaption,
                  fontFamily: 'monospace',
                  color: OrbitTokens.primary,
                  height: 1.5,
                ),
              ),
            ),

            if (hasSecret) ...[
              const SizedBox(height: OrbitTokens.space12),
              Container(
                padding: const EdgeInsets.all(OrbitTokens.space12),
                decoration: BoxDecoration(
                  color: OrbitTokens.accent50,
                  borderRadius: BorderRadius.circular(OrbitTokens.radiusMd),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.shield_outlined,
                        size: 16, color: OrbitTokens.primary80),
                    SizedBox(width: OrbitTokens.space8),
                    Expanded(
                      child: Text(
                        '비밀 메모 키가 링크에 포함돼 있어요. 신뢰하는 사람에게만 보내세요.',
                        style: TextStyle(
                          fontSize: OrbitTokens.fsCaption,
                          color: OrbitTokens.primary80,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: OrbitTokens.space20),

            OrbitButton(
              label: '링크 복사',
              icon: Icons.copy,
              variant: OrbitButtonVariant.primary,
              fullWidth: true,
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: url));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('복사됐어요')),
                  );
                }
              },
            ),
            const SizedBox(height: OrbitTokens.space8),
            OrbitButton(
              label: '닫기',
              variant: OrbitButtonVariant.ghost,
              fullWidth: true,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}
