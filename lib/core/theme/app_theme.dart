import 'package:flutter/material.dart';

import 'orbit_tokens.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final colorScheme = const ColorScheme.light(
      primary: OrbitTokens.primary,
      onPrimary: OrbitTokens.background,
      secondary: OrbitTokens.accent,
      onSecondary: OrbitTokens.primary80,
      surface: OrbitTokens.surface,
      onSurface: OrbitTokens.primary,
      surfaceContainerLowest: OrbitTokens.surface,
      surfaceContainerLow: OrbitTokens.background,
      surfaceContainer: OrbitTokens.background,
      surfaceContainerHigh: OrbitTokens.surfaceDim,
      surfaceContainerHighest: OrbitTokens.surfaceDim,
      onSurfaceVariant: OrbitTokens.primary60,
      outline: OrbitTokens.border,
      outlineVariant: OrbitTokens.border,
      error: OrbitTokens.danger,
      onError: Colors.white,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: OrbitTokens.background,
      // fontFamily: 'Pretendard', // 폰트 추가 후 활성화
      textTheme: _textTheme(OrbitTokens.primary, OrbitTokens.primary60),
      appBarTheme: const AppBarTheme(
        backgroundColor: OrbitTokens.background,
        foregroundColor: OrbitTokens.primary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: OrbitTokens.fsTitle,
          fontWeight: FontWeight.w500,
          color: OrbitTokens.primary,
        ),
      ),
      cardTheme: CardThemeData(
        color: OrbitTokens.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(OrbitTokens.radiusXl),
          side: const BorderSide(color: OrbitTokens.border, width: 0.5),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: OrbitTokens.border,
        thickness: 0.5,
        space: 0,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: OrbitTokens.primary,
          foregroundColor: OrbitTokens.background,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: const TextStyle(
            fontSize: OrbitTokens.fsBody,
            fontWeight: FontWeight.w500,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(OrbitTokens.radiusMd),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: OrbitTokens.primary,
          backgroundColor: OrbitTokens.surface,
          side: const BorderSide(color: OrbitTokens.border, width: 0.5),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: const TextStyle(
            fontSize: OrbitTokens.fsBody,
            fontWeight: FontWeight.w500,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(OrbitTokens.radiusMd),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: OrbitTokens.primary60,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: const TextStyle(
            fontSize: OrbitTokens.fsBody,
            fontWeight: FontWeight.w500,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(OrbitTokens.radiusMd),
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: OrbitTokens.accent,
        foregroundColor: OrbitTokens.primary80,
        elevation: 2,
        highlightElevation: 4,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: OrbitTokens.surface,
        indicatorColor: OrbitTokens.accent50,
        height: 64,
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(
            fontSize: OrbitTokens.fsCaption,
            fontWeight: FontWeight.w500,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: OrbitTokens.primary, size: 22);
          }
          return const IconThemeData(color: OrbitTokens.primary60, size: 22);
        }),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: OrbitTokens.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: const TextStyle(
          color: OrbitTokens.primary40,
          fontSize: OrbitTokens.fsBody,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(OrbitTokens.radiusMd),
          borderSide: const BorderSide(color: OrbitTokens.border, width: 0.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(OrbitTokens.radiusMd),
          borderSide: const BorderSide(color: OrbitTokens.border, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(OrbitTokens.radiusMd),
          borderSide: const BorderSide(color: OrbitTokens.primary, width: 1.5),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: OrbitTokens.surface,
        surfaceTintColor: OrbitTokens.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(OrbitTokens.radius2xl),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: OrbitTokens.surface,
        surfaceTintColor: OrbitTokens.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(OrbitTokens.radius2xl),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: OrbitTokens.surfaceDim,
        side: BorderSide.none,
        labelStyle: const TextStyle(
          fontSize: OrbitTokens.fsCaption,
          color: OrbitTokens.primary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );
  }

  /// 다크 테마 — 라이트 톤 그대로 반전. Phase 2~3에서 본격 다듬을 예정
  static ThemeData get dark {
    final colorScheme = const ColorScheme.dark(
      primary: Color(0xFFFAFAF7),
      onPrimary: OrbitTokens.primary,
      secondary: OrbitTokens.accent,
      onSecondary: OrbitTokens.primary,
      surface: Color(0xFF1C1917),
      onSurface: Color(0xFFFAFAF7),
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFF0C0A09),
      // fontFamily: 'Pretendard',
    );
  }

  static TextTheme _textTheme(Color primary, Color secondary) {
    return TextTheme(
      displaySmall: TextStyle(
        fontSize: OrbitTokens.fsDisplay,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
        color: primary,
        height: 1.1,
      ),
      headlineMedium: TextStyle(
        fontSize: OrbitTokens.fsHeading,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.4,
        color: primary,
        height: 1.15,
      ),
      titleMedium: TextStyle(
        fontSize: OrbitTokens.fsTitle,
        fontWeight: FontWeight.w500,
        color: primary,
        height: 1.3,
      ),
      bodyLarge: TextStyle(
        fontSize: OrbitTokens.fsBody,
        fontWeight: FontWeight.w400,
        color: primary,
        height: 1.4,
      ),
      bodyMedium: TextStyle(
        fontSize: OrbitTokens.fsLabel,
        fontWeight: FontWeight.w400,
        color: primary,
        height: 1.4,
      ),
      bodySmall: TextStyle(
        fontSize: OrbitTokens.fsCaption,
        fontWeight: FontWeight.w400,
        color: secondary,
        height: 1.4,
      ),
      labelSmall: TextStyle(
        fontSize: OrbitTokens.fsMicro,
        fontWeight: FontWeight.w500,
        color: secondary,
        letterSpacing: 0.3,
      ),
    );
  }
}
