import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─── Theme Provider & Persisted Mode ─────────────────────────────────────────

class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.system) {
    _loadTheme();
  }

  static const _key = 'theme_mode';

  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedMode = prefs.getString(_key);
      if (savedMode != null) {
        state = ThemeMode.values.firstWhere(
          (e) => e.toString() == savedMode,
          orElse: () => ThemeMode.system,
        );
      }
    } catch (_) {
      // SharedPreferences might fail in mock or testing environments, fallback gracefully
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, mode.toString());
    } catch (_) {}
  }
}

final themeModeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

// ─── Brightness Notifier (lets the whole tree react to theme changes) ─────────
class BrightnessNotifier extends StateNotifier<Brightness> {
  BrightnessNotifier() : super(Brightness.light);

  void update(Brightness brightness) {
    if (state != brightness) {
      state = brightness;
      VelocityColors.isDark = brightness == Brightness.dark;
    }
  }
}

final brightnessProvider = StateNotifierProvider<BrightnessNotifier, Brightness>((ref) {
  return BrightnessNotifier();
});

// ─── Figma Color Tokens ────────────────────────────────────────────────────
class VelocityColors {
  VelocityColors._();

  static bool isDark = false;

  static void updateBrightness(Brightness brightness) {
    isDark = (brightness == Brightness.dark);
  }

  // Primary greens
  static Color get primary => isDark ? const Color(0xFF3FFF8B) : const Color(0xFF006A33);
  static Color get primaryDark => isDark ? const Color(0xFF24F07E) : const Color(0xFF005C2B);
  static Color get primaryDarker => isDark ? const Color(0xFFF0FDF4) : const Color(0xFF013622);

  // Accent neon greens
  static const Color accent = Color(0xFF3FFF8B);
  static const Color accentBright = Color(0xFF24F07E);

  // Light tints (backgrounds, glassmorphism)
  static Color get surfaceLight => isDark ? const Color(0xFF1E293B) : const Color(0xFFDBFFE8);
  static Color get surfaceMint => isDark ? const Color(0xFF0F172A) : const Color(0xFFCDFFD3);
  static Color get surfacePale => isDark ? const Color(0xFF334155) : const Color(0xFFB8F6D2);
  static Color get cardSurface => isDark ? const Color(0xFF1E293B) : const Color(0xFFC5FEDC);

  // Muted greens (secondary text, borders)
  static Color get secondary => isDark ? const Color(0xFF64748B) : const Color(0xFF87B89C);
  static Color get secondaryDark => isDark ? const Color(0xFF94A3B8) : const Color(0xFF36654D);

  // Neutrals
  static const Color white = Color(0xFFFFFFFF);
  static Color get background => isDark ? const Color(0xFF0B1320) : const Color(0xFFDBFFE8);
  static Color get surfaceCard => isDark ? const Color(0xFF1E293B) : const Color(0xFFF4F4F5);
  static Color get textPrimary => isDark ? const Color(0xFFF8FAFC) : const Color(0xFF09090B);
  static Color get textSecondary => isDark ? const Color(0xFF94A3B8) : const Color(0xFF4A505D);
  static Color get textMuted => isDark ? const Color(0xFF64748B) : const Color(0xFFA1A1AA);
  static Color get divider => isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1);
  static Color get inputBg => isDark ? const Color(0xFF1E293B) : const Color(0xFFDDE2F3);

  // Status
  static const Color error = Color(0xFFFB5151);
  static Color get errorBg => isDark ? const Color(0xFF451A1A) : const Color(0xFFFFEFEE);
  static const Color warning = Color(0xFFFBBC05);

  // Gradient stops for primary button
  static List<Color> get primaryGradient => [primary, accentBright];

  static LinearGradient get primaryButtonGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [primary, accentBright],
      );

  static LinearGradient get backgroundGradient => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: isDark 
            ? [const Color(0xFF0B1320), const Color(0xFF0F172A)] 
            : [white, surfaceLight],
      );

  static LinearGradient get bottomFadeGradient => LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: isDark 
            ? [const Color(0xFF0B1320), Colors.transparent] 
            : [surfaceLight, Colors.transparent],
      );
}

// ─── Typography ────────────────────────────────────────────────────────────
class VelocityText {
  VelocityText._();

  // Plus Jakarta Sans — display / headings
  static TextStyle displayLarge({Color? color}) =>
      GoogleFonts.plusJakartaSans(
        fontSize: 48, fontWeight: FontWeight.w800,
        letterSpacing: -1.2, height: 1.25,
        color: color ?? VelocityColors.primaryDarker,
      );

  static TextStyle displayMedium({Color? color}) =>
      GoogleFonts.plusJakartaSans(
        fontSize: 40, fontWeight: FontWeight.w800,
        letterSpacing: -1.0, height: 1.25,
        color: color ?? VelocityColors.primaryDarker,
      );

  static TextStyle headlineLarge({Color? color}) =>
      GoogleFonts.plusJakartaSans(
        fontSize: 36, fontWeight: FontWeight.w800,
        letterSpacing: -0.9, height: 1.25,
        color: color ?? VelocityColors.primaryDarker,
      );

  static TextStyle headlineMedium({Color? color}) =>
      GoogleFonts.plusJakartaSans(
        fontSize: 30, fontWeight: FontWeight.w700,
        letterSpacing: -0.5, height: 1.3,
        color: color ?? VelocityColors.primaryDarker,
      );

  static TextStyle headlineSmall({Color? color}) =>
      GoogleFonts.plusJakartaSans(
        fontSize: 24, fontWeight: FontWeight.w700,
        letterSpacing: -0.3, height: 1.33,
        color: color ?? VelocityColors.primaryDarker,
      );

  static TextStyle titleLarge({Color? color}) =>
      GoogleFonts.plusJakartaSans(
        fontSize: 20, fontWeight: FontWeight.w700,
        letterSpacing: -0.2, height: 1.4,
        color: color ?? VelocityColors.primaryDarker,
      );

  // Brand wordmark
  static TextStyle brandWordmark({Color? color}) =>
      GoogleFonts.plusJakartaSans(
        fontSize: 24, fontWeight: FontWeight.w900,
        fontStyle: FontStyle.italic, letterSpacing: -0.6,
        color: color ?? VelocityColors.primary,
      );

  // Inter — body / labels
  static TextStyle bodyLarge({Color? color}) =>
      GoogleFonts.inter(
        fontSize: 18, fontWeight: FontWeight.w400,
        height: 1.625,
        color: color ?? VelocityColors.textSecondary,
      );

  static TextStyle bodyMedium({Color? color}) =>
      GoogleFonts.inter(
        fontSize: 16, fontWeight: FontWeight.w400,
        height: 1.5,
        color: color ?? VelocityColors.textSecondary,
      );

  static TextStyle bodySmall({Color? color}) =>
      GoogleFonts.inter(
        fontSize: 14, fontWeight: FontWeight.w500,
        height: 1.43,
        color: color ?? VelocityColors.textSecondary,
      );

  static TextStyle labelLarge({Color? color}) =>
      GoogleFonts.inter(
        fontSize: 18, fontWeight: FontWeight.w700,
        color: color ?? VelocityColors.white,
      );

  static TextStyle labelMedium({Color? color}) =>
      GoogleFonts.inter(
        fontSize: 14, fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        color: color ?? VelocityColors.textPrimary,
      );

  static TextStyle labelSmall({Color? color}) =>
      GoogleFonts.inter(
        fontSize: 12, fontWeight: FontWeight.w500,
        letterSpacing: 1.2,
        color: color ?? VelocityColors.textMuted,
      );

  static TextStyle overline({Color? color}) =>
      GoogleFonts.inter(
        fontSize: 10, fontWeight: FontWeight.w600,
        letterSpacing: 1.5,
        color: color ?? VelocityColors.secondary,
      );
}

// ─── Themes ─────────────────────────────────────────────────────────────────
ThemeData velocityLightTheme() {
  final base = ThemeData.light(useMaterial3: true);

  return base.copyWith(
    scaffoldBackgroundColor: const Color(0xFFDBFFE8),
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF006A33),
      secondary: Color(0xFF3FFF8B),
      surface: Colors.white,
      error: Color(0xFFFB5151),
    ),
    textTheme: GoogleFonts.interTextTheme(base.textTheme),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      titleTextStyle: VelocityText.headlineSmall(color: const Color(0xFF013622)),
      iconTheme: const IconThemeData(color: Color(0xFF013622)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF006A33),
        foregroundColor: const Color(0xFFCDFFD3),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
        textStyle: VelocityText.labelLarge(),
      ),
    ),
  );
}

ThemeData velocityDarkTheme() {
  final base = ThemeData.dark(useMaterial3: true);

  return base.copyWith(
    scaffoldBackgroundColor: const Color(0xFF0B1320),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF3FFF8B),
      secondary: Color(0xFF24F07E),
      surface: Color(0xFF1E293B),
      error: Color(0xFFFB5151),
    ),
    textTheme: GoogleFonts.interTextTheme(base.textTheme),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      titleTextStyle: VelocityText.headlineSmall(color: const Color(0xFFF8FAFC)),
      iconTheme: const IconThemeData(color: Color(0xFFF8FAFC)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF008F47),
        foregroundColor: Colors.white,
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
        textStyle: VelocityText.labelLarge(),
      ),
    ),
  );
}
