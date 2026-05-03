/// 초대 링크 포맷:
///   https://orbit.app/i/{inviteCode}#k={password}
///
/// **fragment(`#`) 사용 이유**: URL fragment는 브라우저가 서버로 전송하지 않음.
/// 따라서 도메인 제공자(Firebase Hosting, CDN, 로그)가 비밀번호를 보지 않음.
/// 다만 카카오톡/SMS 등 메신저는 평문 전송이라 그쪽은 별도 위협 모델.
///
/// 비밀 메모를 안 쓰는 그룹은 fragment 없이:
///   https://orbit.app/i/{inviteCode}
class InviteLink {
  InviteLink._();

  static const _scheme = 'https';
  static const _host = 'orbit.app';
  static const _path = '/i';

  static Uri build({
    required String inviteCode,
    String? secretPassword,
  }) {
    final uri = Uri(
      scheme: _scheme,
      host: _host,
      path: '$_path/$inviteCode',
    );
    if (secretPassword == null) return uri;
    return uri.replace(fragment: 'k=$secretPassword');
  }

  /// 외부에서 받은 URL을 파싱. orbit.app/i/* 형식이 아니면 null.
  static ParsedInvite? parse(Uri uri) {
    if (uri.host != _host) return null;
    if (uri.pathSegments.length < 2 || uri.pathSegments[0] != 'i') return null;

    final inviteCode = uri.pathSegments[1];
    if (inviteCode.isEmpty) return null;

    String? password;
    if (uri.fragment.isNotEmpty) {
      // fragment 형식: "k=PASSWORD" 또는 그냥 "PASSWORD"
      final f = uri.fragment;
      if (f.startsWith('k=')) {
        password = f.substring(2);
      }
    }

    return ParsedInvite(inviteCode: inviteCode, password: password);
  }
}

class ParsedInvite {
  const ParsedInvite({required this.inviteCode, this.password});

  final String inviteCode;
  final String? password;

  bool get hasSecret => password != null && password!.isNotEmpty;
}
