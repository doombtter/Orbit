import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/crypto/secret_crypto.dart';
import '../../../../core/crypto/secret_key_store.dart';
import '../../../../core/theme/orbit_tokens.dart';
import '../../../../core/widgets/orbit_button.dart';
import '../../../../core/widgets/orbit_card.dart';
import '../../../group/domain/group.dart';
import '../../domain/memo.dart';
import '../providers/memo_providers.dart';

class MemoListScreen extends ConsumerWidget {
  const MemoListScreen({super.key, required this.group});

  final Group group;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memosAsync = ref.watch(groupMemosProvider(group.id));
    final unlocked = ref.watch(groupUnlockStatusProvider(group.id));

    return Scaffold(
      backgroundColor: OrbitTokens.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => context.pop(),
        ),
        title: Text('${group.name} · 메모'),
        actions: [
          if (group.hasSecretEnabled)
            IconButton(
              icon: Icon(unlocked ? Icons.lock_open : Icons.lock_outline),
              tooltip: unlocked ? '잠그기' : '잠금 해제',
              onPressed: () {
                if (unlocked) {
                  ref.read(secretKeyStoreProvider).lock(group.id);
                  ref
                      .read(groupUnlockStatusProvider(group.id).notifier)
                      .state = false;
                } else {
                  _promptUnlock(context, ref, group);
                }
              },
            ),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            memosAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('오류: $e')),
              data: (memos) => memos.isEmpty
                  ? const _EmptyState()
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(
                        OrbitTokens.space20,
                        OrbitTokens.space8,
                        OrbitTokens.space20,
                        140,
                      ),
                      itemCount: memos.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: OrbitTokens.space10),
                      itemBuilder: (_, i) => _MemoCard(
                        memo: memos[i],
                        unlocked: unlocked,
                        onUnlock: () => _promptUnlock(context, ref, group),
                      ),
                    ),
            ),
            Positioned(
              left: OrbitTokens.space20,
              right: OrbitTokens.space20,
              bottom: OrbitTokens.space16,
              child: OrbitButton(
                label: '메모 추가',
                icon: Icons.add,
                variant: OrbitButtonVariant.accent,
                fullWidth: true,
                onPressed: () {
                  // TODO: 메모 작성 시트
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _promptUnlock(
    BuildContext context,
    WidgetRef ref,
    Group group,
  ) async {
    if (!group.hasSecretEnabled) return;

    final pwd = await showDialog<String>(
      context: context,
      builder: (_) => const _UnlockDialog(),
    );
    if (pwd == null || pwd.isEmpty) return;

    final ok = await ref.read(secretKeyStoreProvider).tryUnlock(
          groupId: group.id,
          password: pwd,
          saltBase64: group.secretSalt!,
          verifier: group.secretVerifier!,
        );

    if (ok) {
      ref.read(groupUnlockStatusProvider(group.id).notifier).state = true;
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('비밀번호가 맞지 않아요')),
      );
    }
  }
}

class _MemoCard extends ConsumerStatefulWidget {
  const _MemoCard({
    required this.memo,
    required this.unlocked,
    required this.onUnlock,
  });

  final Memo memo;
  final bool unlocked;
  final VoidCallback onUnlock;

  @override
  ConsumerState<_MemoCard> createState() => _MemoCardState();
}

class _MemoCardState extends ConsumerState<_MemoCard> {
  bool _revealed = false;
  String? _decrypted;

  @override
  Widget build(BuildContext context) {
    final memo = widget.memo;
    final isSecret = memo.isSecret;

    return OrbitCard(
      onTap: isSecret ? _onTapSecret : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isSecret ? OrbitTokens.accent50 : OrbitTokens.surfaceDim,
              borderRadius: BorderRadius.circular(OrbitTokens.radiusMd),
            ),
            child: Icon(
              isSecret ? Icons.lock_outline : Icons.note_outlined,
              size: 18,
              color: OrbitTokens.primary,
            ),
          ),
          const SizedBox(width: OrbitTokens.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  memo.title,
                  style: const TextStyle(
                    fontSize: OrbitTokens.fsTitle,
                    fontWeight: FontWeight.w500,
                    color: OrbitTokens.primary,
                  ),
                ),
                const SizedBox(height: 4),
                _bodyText(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bodyText() {
    final memo = widget.memo;
    if (!memo.isSecret) {
      return Text(
        memo.body ?? '',
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: OrbitTokens.fsLabel,
          color: OrbitTokens.primary60,
        ),
      );
    }

    // 비밀 메모
    if (!widget.unlocked) {
      return Row(
        children: [
          const Text(
            '••••••••••',
            style: TextStyle(
              fontSize: OrbitTokens.fsLabel,
              color: OrbitTokens.primary40,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(width: OrbitTokens.space8),
          Text(
            '잠금 해제 필요',
            style: TextStyle(
              fontSize: OrbitTokens.fsCaption,
              color: OrbitTokens.accent.withValues(alpha: 0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    }

    if (!_revealed) {
      return const Row(
        children: [
          Text(
            '••••••••••',
            style: TextStyle(
              fontSize: OrbitTokens.fsLabel,
              color: OrbitTokens.primary40,
              letterSpacing: 2,
            ),
          ),
          SizedBox(width: OrbitTokens.space8),
          Text(
            '탭하면 표시',
            style: TextStyle(
              fontSize: OrbitTokens.fsCaption,
              color: OrbitTokens.primary40,
            ),
          ),
        ],
      );
    }

    return Text(
      _decrypted ?? '',
      maxLines: 4,
      style: const TextStyle(
        fontSize: OrbitTokens.fsLabel,
        color: OrbitTokens.primary,
        fontFamily: 'monospace',
      ),
    );
  }

  Future<void> _onTapSecret() async {
    final memo = widget.memo;
    if (memo.secret == null) return;

    if (!widget.unlocked) {
      widget.onUnlock();
      return;
    }

    if (_revealed) {
      // 다시 가리기
      setState(() {
        _revealed = false;
        _decrypted = null;
      });
      return;
    }

    final key = ref.read(secretKeyStoreProvider).get(memo.groupId);
    if (key == null) {
      widget.onUnlock();
      return;
    }

    try {
      final clear =
          await SecretCrypto.decrypt(blob: memo.secret!, key: key);
      if (mounted) {
        setState(() {
          _revealed = true;
          _decrypted = clear;
        });
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('복호화 실패. 비밀번호가 바뀌었을 수 있어요')),
        );
      }
    }
  }
}

class _UnlockDialog extends StatefulWidget {
  const _UnlockDialog();

  @override
  State<_UnlockDialog> createState() => _UnlockDialogState();
}

class _UnlockDialogState extends State<_UnlockDialog> {
  final _ctrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('잠금 해제'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '이 궤도의 비밀 메모 비밀번호를 입력하세요.',
            style: TextStyle(
                fontSize: OrbitTokens.fsLabel, color: OrbitTokens.primary60),
          ),
          const SizedBox(height: OrbitTokens.space16),
          TextField(
            controller: _ctrl,
            obscureText: _obscure,
            autofocus: true,
            decoration: InputDecoration(
              hintText: '비밀번호',
              suffixIcon: IconButton(
                icon: Icon(_obscure
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
            onSubmitted: (v) => Navigator.of(context).pop(v),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('취소'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_ctrl.text),
          child: const Text('확인'),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 32, 32, 140),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.note_outlined, size: 48, color: OrbitTokens.primary40),
            const SizedBox(height: OrbitTokens.space16),
            const Text(
              '아직 메모가 없어요',
              style: TextStyle(
                fontSize: OrbitTokens.fsTitle,
                fontWeight: FontWeight.w500,
                color: OrbitTokens.primary,
              ),
            ),
            const SizedBox(height: OrbitTokens.space6),
            const Text(
              '레시피, 약속, 비밀번호 등 함께 쓸 메모를 추가해보세요',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: OrbitTokens.fsLabel,
                color: OrbitTokens.primary60,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
