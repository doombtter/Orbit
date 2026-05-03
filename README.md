# Orbit

함께하는 캘린더 & 지도 마킹 앱. 가족·연인·팀·친구 그룹 단위로 일정과 장소를 공유합니다.

## 스택

- **Flutter** 3.24+
- **상태관리**: Riverpod 2
- **백엔드**: Firebase (Auth + Firestore + Messaging)
- **지도**: Google Maps
- **캘린더 UI**: table_calendar
- **라우팅**: GoRouter
- **모델**: Freezed (선택)

## 프로젝트 구조 (Feature-first + Clean Architecture)

```
lib/
├── main.dart
├── app/                    앱 전역 (router, theme)
├── core/                   공통 유틸 / 위젯
└── features/
    ├── auth/               인증
    ├── group/              그룹 (멤버십 / 초대)
    ├── calendar/           캘린더 (이벤트)
    └── map/                지도 (핀)
```

각 feature는 `data/` (저장소) → `domain/` (모델) ← `presentation/` (UI/상태) 3단 레이어.

## 셋업 순서

### 1. Flutter 프로젝트 초기화
이 폴더의 `lib/`는 이미 구성되어 있어요. 네이티브 설정만 추가하면 됩니다:

```bash
flutter create --org com.yourname --project-name orbit \
  --platforms=android,ios .
```

> ⚠️ `--project-name orbit`로 이름 통일. `lib/` 폴더는 덮어씌워지지 않게 주의 (이미 있는 파일은 보존됨).

### 2. 패키지 설치
```bash
flutter pub get
```

### 3. Firebase 연결
```bash
dart pub global activate flutterfire_cli
flutterfire configure
```
실행 후 `lib/main.dart`의 `firebase_options.dart` import 주석을 해제하세요.

### 4. Google Maps API 키
- **Android**: `android/app/src/main/AndroidManifest.xml`에 메타데이터 추가
- **iOS**: `ios/Runner/AppDelegate.swift`에 키 등록

### 5. 실행
```bash
flutter run
```

## 다음 단계 TODO

- [ ] 그룹 생성 다이얼로그 (`group_list_screen.dart`)
- [ ] 이벤트 생성 시트 (`calendar_screen.dart`)
- [ ] 핀 추가/삭제 (`map_screen.dart`)
- [ ] 초대 링크 (`app_links` + 딥링크)
- [ ] Firestore 보안 규칙 작성
- [ ] Google/Apple 로그인 추가
- [ ] 푸시 알림 (FCM)

## 데이터 모델 (Firestore)

```
users/{uid}                  사용자
  - groupIds: [...]          속한 그룹 IDs (역참조)

groups/{groupId}             그룹
  - memberIds: [...]         멤버 IDs (보안 규칙용)
  /events/{eventId}          캘린더 이벤트
  /pins/{pinId}              지도 핀
```

`users.groupIds`와 `groups.memberIds`는 양방향 비정규화 — 가입/탈퇴는 반드시 트랜잭션으로 (이미 `GroupRepository`에 구현됨).
