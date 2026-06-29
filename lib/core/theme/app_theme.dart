import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  static const EdgeInsets paddingXs = EdgeInsets.all(xs);
  static const EdgeInsets paddingSm = EdgeInsets.all(sm);
  static const EdgeInsets paddingMd = EdgeInsets.all(md);
  static const EdgeInsets paddingLg = EdgeInsets.all(lg);
  static const EdgeInsets paddingXl = EdgeInsets.all(xl);
  static const EdgeInsets horizontalMd = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets verticalMd = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets verticalSm = EdgeInsets.symmetric(vertical: sm);
}

class AppRadius {
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
}

extension TextStyleContext on BuildContext {
  TextTheme get textStyles => Theme.of(this).textTheme;
}

extension TextStyleExtensions on TextStyle {
  TextStyle get bold => copyWith(fontWeight: FontWeight.bold);
  TextStyle get semiBold => copyWith(fontWeight: FontWeight.w600);
  TextStyle get medium => copyWith(fontWeight: FontWeight.w500);
  TextStyle withColor(Color color) => copyWith(color: color);
  TextStyle withSize(double size) => copyWith(fontSize: size);
}

// ─── Paleta única ─────────────────────────────────────────────────────────────
// Roxo principal: #6C3EB8  |  Laranja acento: #F4622A  |  Azul info: #0EA5E9

class _P {
  // Primário — roxo
  static const primary        = Color(0xFF6C3EB8);
  static const primaryLight   = Color(0xFF9B6FE8);
  static const primaryContainer    = Color(0xFFEDE0FF);
  static const onPrimaryContainer  = Color(0xFF25006B);

  // Secundário — laranja
  static const secondary      = Color(0xFFF4622A);
  static const secondaryLight = Color(0xFFFF8F61);
  static const secondaryContainer    = Color(0xFFFFDDD0);
  static const onSecondaryContainer  = Color(0xFF5C1500);

  // Superfícies — claro
  static const bgLight   = Color(0xFFF5F0FF);
  static const surfLight = Color(0xFFFFFFFF);
  static const surfVarLight = Color(0xFFEFE8FB);
  static const onSurfLight  = Color(0xFF1C1B1E);
  static const onSurfVarLight = Color(0xFF4A4458);
  static const outlineLight = Color(0xFF9A8EA4);

  // Superfícies — escuro
  static const bgDark    = Color(0xFF12101A);
  static const surfDark  = Color(0xFF1C1A26);
  static const surfVarDark  = Color(0xFF2A2636);
  static const onSurfDark   = Color(0xFFE6E0EA);
  static const onSurfVarDark = Color(0xFFCBC4D2);
  static const outlineDark  = Color(0xFF958E9C);

  // Erro
  static const error   = Color(0xFFBA1A1A);
  static const onError = Color(0xFFFFFFFF);
  static const errorContainer   = Color(0xFFFFDAD6);
  static const onErrorContainer = Color(0xFF410002);
  static const errorDark   = Color(0xFFFFB4AB);
  static const onErrorDark = Color(0xFF690005);
}

// ─── Tema claro ───────────────────────────────────────────────────────────────
ThemeData get lightTheme => ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: _P.primary,
        onPrimary: Colors.white,
        primaryContainer: _P.primaryContainer,
        onPrimaryContainer: _P.onPrimaryContainer,
        secondary: _P.secondary,
        onSecondary: Colors.white,
        secondaryContainer: _P.secondaryContainer,
        onSecondaryContainer: _P.onSecondaryContainer,
        error: _P.error,
        onError: _P.onError,
        errorContainer: _P.errorContainer,
        onErrorContainer: _P.onErrorContainer,
        surface: _P.surfLight,
        onSurface: _P.onSurfLight,
        surfaceContainerHighest: _P.surfVarLight,
        onSurfaceVariant: _P.onSurfVarLight,
        outline: _P.outlineLight,
      ),
      brightness: Brightness.light,
      scaffoldBackgroundColor: _P.bgLight,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: _P.onSurfLight,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        color: _P.surfLight,
        elevation: 1,
        shadowColor: _P.primary.withOpacity(0.12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: BorderSide(color: _P.outlineLight.withOpacity(0.2)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: _P.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: _P.outlineLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: _P.primary, width: 2),
        ),
      ),
      textTheme: _buildTextTheme(),
    );

// ─── Tema escuro ──────────────────────────────────────────────────────────────
ThemeData get darkTheme => ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.dark(
        primary: _P.primaryLight,
        onPrimary: const Color(0xFF3B0090),
        primaryContainer: const Color(0xFF5200AD),
        onPrimaryContainer: _P.primaryContainer,
        secondary: _P.secondaryLight,
        onSecondary: const Color(0xFF6B2000),
        secondaryContainer: const Color(0xFF8B3500),
        onSecondaryContainer: _P.secondaryContainer,
        error: _P.errorDark,
        onError: _P.onErrorDark,
        errorContainer: const Color(0xFF93000A),
        onErrorContainer: _P.errorContainer,
        surface: _P.surfDark,
        onSurface: _P.onSurfDark,
        surfaceContainerHighest: _P.surfVarDark,
        onSurfaceVariant: _P.onSurfVarDark,
        outline: _P.outlineDark,
      ),
      brightness: Brightness.dark,
      scaffoldBackgroundColor: _P.bgDark,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: _P.onSurfDark,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        color: _P.surfVarDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: BorderSide(color: _P.outlineDark.withOpacity(0.2)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: _P.primaryLight,
          foregroundColor: const Color(0xFF3B0090),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: _P.outlineDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: _P.primaryLight, width: 2),
        ),
      ),
      textTheme: _buildTextTheme(),
    );

TextTheme _buildTextTheme() => TextTheme(
      headlineLarge:  GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.w700),
      headlineMedium: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w600),
      headlineSmall:  GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w600),
      titleLarge:     GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w600),
      titleMedium:    GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
      titleSmall:     GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
      labelLarge:     GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
      labelMedium:    GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500),
      bodyLarge:      GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w400),
      bodyMedium:     GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400),
      bodySmall:      GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400),
    );
