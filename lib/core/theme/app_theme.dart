import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// ═══════════════════════════════════════════════════════════════════════
/// MODERN BRUTALISM DESIGN SYSTEM
/// Style: Raw, bold, high-impact. Block-letter feel. Heavy borders.
/// ═══════════════════════════════════════════════════════════════════════
class AppTheme {
  // ── Core Palette ─────────────────────────────────────────────────────
  static const Color primary        = Color(0xFFFFD700); // kuning Brutalism
  static const Color primaryLight   = Color(0xFFFFE45C);
  static const Color primaryDark    = Color(0xFFE6B800);

  static const Color ink            = Color(0xFF000000); // hitam pekat
  static const Color paper          = Color(0xFFFFFBF0); // krem terang
  static const Color backgroundLight = Color(0xFFFFF6E0);

  static const Color surfaceLight   = Color(0xFFFFFFFF);
  static const Color surfaceDark    = Color(0xFF161616);

  // ── Dark Mode Palette (dioptimal untuk mata, kontras tinggi) ──
  static const Color backgroundDark = Color(0xFF0D0D0D); // Hitam pekat sebagai canvas
  static const Color cardDark       = Color(0xFF1E1E1E); // Abu gelap untuk elevated card
  static const Color surfaceDarkAlt = Color(0xFF242424); // Alternatif untuk nested surface

  static const Color textPrimaryLight   = Color(0xFF000000);
  static const Color textPrimaryDark    = Color(0xFFFFFBF0); // Krem terang = anti silau
  static const Color textSecondaryLight = Color(0xFF333333);
  static const Color textSecondaryDark  = Color(0xFFB0B0B0); // Abu medium, readable

  static const Color borderLight  = Color(0xFF000000); // TEKAS HITAM
  static const Color borderDark   = Color(0xFFFFFBF0); // Krem terang → kontras lembut

  // ── Aksen Neón (untuk status / prioritas) ──
  static const Color acidPink    = Color(0xFFFF3D7F);
  static const Color acidRed     = Color(0xFFFF3030);
  static const Color acidOrange  = Color(0xFFFF7A00);
  static const Color acidLime    = Color(0xFF73F74D);
  static const Color acidBlue    = Color(0xFF00C2FF);
  static const Color acidPurple  = Color(0xFFB026FF);

  // ── Status Colors ──
  static const Color statusOpen       = acidPink;
  static const Color statusInProgress = acidOrange;
  static const Color statusResolved   = acidLime;
  static const Color statusClosed     = Color(0xFFC0C0C0);

  static const Color priorityHigh   = acidRed;
  static const Color priorityMedium = acidOrange;
  static const Color priorityLow    = acidLime;

  // ── Border widths & shadows ──
  static const double borderWidth = 3.0;
  static const double borderWidthThick = 4.0;

  // ── Text Theme — BOLD, BESAR, JELAS ──
  static TextTheme _textTheme(Color text) =>
      GoogleFonts.spaceGroteskTextTheme().copyWith(
        displayLarge:   GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w900, color: text, fontSize: 36, letterSpacing: -1.5),
        displayMedium:  GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w900, color: text, fontSize: 30, letterSpacing: -1.0),
        headlineLarge:  GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w900, color: text, fontSize: 26, letterSpacing: -0.5),
        headlineMedium: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w800, color: text, fontSize: 22),
        headlineSmall:  GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w800, color: text, fontSize: 20),
        titleLarge:     GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w800, color: text, fontSize: 20, letterSpacing: 0.5),
        titleMedium:    GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700, color: text, fontSize: 17, letterSpacing: 0.3),
        titleSmall:     GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700, color: text, fontSize: 15),
        bodyLarge:      GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w500, color: text, fontSize: 16),
        bodyMedium:     GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w500, color: text, fontSize: 14),
        bodySmall:      GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w500, color: text, fontSize: 12),
        labelLarge:     GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w800, color: text, fontSize: 14, letterSpacing: 1.0),
        labelMedium:    GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700, color: text, fontSize: 12, letterSpacing: 1.5),
        labelSmall:     GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700, color: text, fontSize: 10, letterSpacing: 2.0),
      );

  // ── Shared: Border Brutal ──
  static const BorderSide _borderSide = BorderSide(color: ink, width: borderWidth);

  static OutlinedBorder get brutalShape => RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: _borderSide,
      );

  static OutlinedBorder get brutalShapeThick => RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0),
        side: const BorderSide(color: ink, width: borderWidthThick),
      );

  // ── Hard Shadow Brutalism ──
  static List<BoxShadow> get brutalShadow => const [
        BoxShadow(
          color: ink,
          offset: Offset(4, 4),
          blurRadius: 0,
          spreadRadius: 0,
        ),
      ];

  static List<BoxShadow> get brutalShadowSmall => const [
        BoxShadow(
          color: ink,
          offset: Offset(3, 3),
          blurRadius: 0,
          spreadRadius: 0,
        ),
      ];

  // ─────────────────────────────────────────────────────────────────────
  // LIGHT THEME
  // ─────────────────────────────────────────────────────────────────────
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: backgroundLight,
    colorScheme: const ColorScheme.light(
      primary: primary,
      onPrimary: ink,
      secondary: ink,
      onSecondary: paper,
      surface: surfaceLight,
      onSurface: textPrimaryLight,
      error: acidRed,
      onError: paper,
    ),
    textTheme: _textTheme(textPrimaryLight),
    appBarTheme: AppBarTheme(
      centerTitle: false,
      elevation: 0,
      backgroundColor: backgroundLight,
      foregroundColor: ink,
      scrolledUnderElevation: 0,
      toolbarHeight: 64,
      shape: const Border(bottom: BorderSide(color: ink, width: borderWidthThick)),
      titleTextStyle: GoogleFonts.spaceGrotesk(
        fontWeight: FontWeight.w900,
        fontSize: 24,
        color: ink,
        letterSpacing: -0.5,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: surfaceLight,
      shadowColor: ink,
      shape: brutalShape,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceLight,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      hintStyle: GoogleFonts.spaceGrotesk(
        color: textSecondaryLight,
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
      labelStyle: GoogleFonts.spaceGrotesk(
        color: ink,
        fontWeight: FontWeight.w800,
        fontSize: 13,
        letterSpacing: 1.2,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: ink, width: borderWidth),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: ink, width: borderWidth),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: ink, width: borderWidthThick),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: acidRed, width: borderWidth),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: acidRed, width: borderWidthThick),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: ink,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        shape: brutalShape,
        minimumSize: const Size(double.infinity, 56),
        textStyle: GoogleFonts.spaceGrotesk(
          fontWeight: FontWeight.w900,
          fontSize: 15,
          letterSpacing: 1.5,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: ink,
        side: const BorderSide(color: ink, width: borderWidth),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        shape: brutalShape,
        minimumSize: const Size(double.infinity, 56),
        textStyle: GoogleFonts.spaceGrotesk(
          fontWeight: FontWeight.w800,
          fontSize: 14,
          letterSpacing: 1.5,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: ink,
        textStyle: GoogleFonts.spaceGrotesk(
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
          decoration: TextDecoration.underline,
          decorationThickness: 2,
        ),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: paper,
      selectedItemColor: ink,
      unselectedItemColor: textSecondaryLight,
      selectedLabelStyle: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1),
      unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 10, letterSpacing: 1),
      elevation: 0,
      type: BottomNavigationBarType.fixed,
      showUnselectedLabels: true,
    ),
    dividerTheme: const DividerThemeData(color: ink, thickness: borderWidth, space: borderWidth),
    progressIndicatorTheme: const ProgressIndicatorThemeData(color: ink, linearMinHeight: 6),
    iconTheme: const IconThemeData(color: ink, size: 24),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primary,
      foregroundColor: ink,
      shape: brutalShape,
      elevation: 0,
      highlightElevation: 0,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: ink,
      contentTextStyle: GoogleFonts.spaceGrotesk(
        color: paper,
        fontWeight: FontWeight.w700,
        fontSize: 14,
      ),
      shape: brutalShape,
      behavior: SnackBarBehavior.floating,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: paper,
      shape: brutalShapeThick,
      titleTextStyle: GoogleFonts.spaceGrotesk(
        color: ink,
        fontWeight: FontWeight.w900,
        fontSize: 20,
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: paper,
      selectedColor: primary,
      labelStyle: GoogleFonts.spaceGrotesk(
        color: ink,
        fontWeight: FontWeight.w800,
        fontSize: 11,
        letterSpacing: 1,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      shape: brutalShape,
      side: const BorderSide(color: ink, width: borderWidth),
    ),
    listTileTheme: const ListTileThemeData(
      iconColor: ink,
      textColor: ink,
      tileColor: surfaceLight,
    ),
  );

// ─────────────────────────────────────────────────────────────────────
  // DARK THEME — Brutalism: canvas hitam, border krem, card abu gelap
  // ─────────────────────────────────────────────────────────────────────
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: backgroundDark,
    colorScheme: const ColorScheme.dark(
      primary: primary,
      onPrimary: ink,
      secondary: paper,
      onSecondary: ink,
      surface: cardDark,
      onSurface: textPrimaryDark,
      error: acidRed,
      onError: paper,
    ),
    textTheme: _textTheme(textPrimaryDark),
    appBarTheme: AppBarTheme(
      centerTitle: false,
      elevation: 0,
      backgroundColor: backgroundDark,
      foregroundColor: textPrimaryDark,
      scrolledUnderElevation: 0,
      toolbarHeight: 64,
      shape: const Border(bottom: BorderSide(color: borderDark, width: borderWidthThick)),
      titleTextStyle: GoogleFonts.spaceGrotesk(
        fontWeight: FontWeight.w900,
        fontSize: 24,
        color: textPrimaryDark,
        letterSpacing: -0.5,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: cardDark,
      shadowColor: borderDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: const BorderSide(color: borderDark, width: borderWidth),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: cardDark,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      hintStyle: GoogleFonts.spaceGrotesk(
        color: textSecondaryDark,
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
      labelStyle: GoogleFonts.spaceGrotesk(
        color: textPrimaryDark,
        fontWeight: FontWeight.w800,
        fontSize: 13,
        letterSpacing: 1.2,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: borderDark, width: borderWidth),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: borderDark, width: borderWidth),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: borderDark, width: borderWidthThick),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: acidRed, width: borderWidth),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: acidRed, width: borderWidthThick),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: ink,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: const BorderSide(color: ink, width: borderWidth),
        ),
        minimumSize: const Size(double.infinity, 56),
        textStyle: GoogleFonts.spaceGrotesk(
          fontWeight: FontWeight.w900,
          fontSize: 15,
          letterSpacing: 1.5,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: textPrimaryDark,
        side: const BorderSide(color: borderDark, width: borderWidth),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: const BorderSide(color: borderDark, width: borderWidth),
        ),
        minimumSize: const Size(double.infinity, 56),
        textStyle: GoogleFonts.spaceGrotesk(
          fontWeight: FontWeight.w800,
          fontSize: 14,
          letterSpacing: 1.5,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: textPrimaryDark,
        textStyle: GoogleFonts.spaceGrotesk(
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
          decoration: TextDecoration.underline,
          decorationThickness: 2,
        ),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: surfaceDark,
      selectedItemColor: primary,
      unselectedItemColor: textSecondaryDark,
      selectedLabelStyle: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1),
      unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 10, letterSpacing: 1),
      elevation: 0,
      type: BottomNavigationBarType.fixed,
      showUnselectedLabels: true,
    ),
    dividerTheme: const DividerThemeData(color: borderDark, thickness: borderWidth, space: borderWidth),
    progressIndicatorTheme: const ProgressIndicatorThemeData(color: primary, linearMinHeight: 6),
    iconTheme: const IconThemeData(color: paper, size: 24),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primary,
      foregroundColor: ink,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: const BorderSide(color: ink, width: borderWidth),
      ),
      elevation: 0,
      highlightElevation: 0,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: cardDark,
      contentTextStyle: GoogleFonts.spaceGrotesk(
        color: textPrimaryDark,
        fontWeight: FontWeight.w700,
        fontSize: 14,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: const BorderSide(color: borderDark, width: borderWidth),
      ),
      behavior: SnackBarBehavior.floating,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: surfaceDarkAlt,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
        side: const BorderSide(color: borderDark, width: borderWidthThick),
      ),
      titleTextStyle: GoogleFonts.spaceGrotesk(
        color: textPrimaryDark,
        fontWeight: FontWeight.w900,
        fontSize: 20,
      ),
      barrierColor: const Color(0x99000000), // Semi-transparent overlay
    ),
    chipTheme: ChipThemeData(
      backgroundColor: surfaceDark,
      selectedColor: primary,
      labelStyle: GoogleFonts.spaceGrotesk(
        color: textPrimaryDark,
        fontWeight: FontWeight.w800,
        fontSize: 11,
        letterSpacing: 1,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: const BorderSide(color: borderDark, width: borderWidth),
      ),
    ),
    listTileTheme: const ListTileThemeData(
      iconColor: paper,
      textColor: textPrimaryDark,
      tileColor: cardDark,
    ),
  );

  // ─────────────────────────────────────────────────────────────────────
  // HELPERS — Adapt colors based on current brightness
  // ─────────────────────────────────────────────────────────────────────

  /// Border color untuk kondisi saat ini (hitam untuk light, krem untuk dark)
  static Color adaptiveBorder(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? borderDark : ink;

  /// Shadow color untuk kondisi saat ini
  static Color adaptiveShadow(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? borderDark : ink;

  /// Text color adaptive (hitam untuk light, krem untuk dark)
  static Color adaptiveText(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? textPrimaryDark : textPrimaryLight;

  /// Surface color adaptive (putih untuk light, abu gelap untuk dark)
  static Color adaptiveSurface(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? cardDark : surfaceLight;

  /// Background color adaptive (krem terang vs hitam pekat)
  static Color adaptiveBackground(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? backgroundDark : backgroundLight;

  /// Secondary text adaptive (abu gelap untuk light, abu medium untuk dark)
  static Color adaptiveTextSecondary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? textSecondaryDark : textSecondaryLight;

  /// Returns true if the current theme is dark
  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  /// List of brutal shadows untuk kondisi saat ini
  static List<BoxShadow> adaptiveBrutalShadow(BuildContext context, {double offset = 4}) => [
        BoxShadow(
          color: adaptiveShadow(context),
          offset: Offset(offset, offset),
          blurRadius: 0,
          spreadRadius: 0,
        ),
      ];

  // ─────────────────────────────────────────────────────────────────────
  // HELPERS — Status & Priority (unchanged)
  // ─────────────────────────────────────────────────────────────────────

  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'open':        return statusOpen;
      case 'in progress': return statusInProgress;
      case 'resolved':    return statusResolved;
      case 'closed':      return statusClosed;
      default:            return statusClosed;
    }
  }

  static Color getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':   return priorityHigh;
      case 'medium': return priorityMedium;
      case 'low':    return priorityLow;
      default:       return statusClosed;
    }
  }

  /// Helper untuk membuat box dengan border & shadow brutalism
  static Widget brutalContainer({
    BuildContext? context,
    required Widget child,
    Color? backgroundColor,
    Color? borderColor,
    double borderW = borderWidth,
    double borderRadiusValue = 4,
    List<BoxShadow>? shadows,
    EdgeInsetsGeometry padding = const EdgeInsets.all(16),
    EdgeInsetsGeometry? margin,
  }) {
    final bg = backgroundColor ?? adaptiveSurface(context!);
    final bd = borderColor ?? adaptiveBorder(context!);
    final sh = shadows ?? adaptiveBrutalShadow(context!, offset: 4);
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: bd, width: borderW),
        borderRadius: BorderRadius.circular(borderRadiusValue),
        boxShadow: sh,
      ),
      child: child,
    );
  }
}
