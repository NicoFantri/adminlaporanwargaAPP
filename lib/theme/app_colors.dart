import 'package:flutter/material.dart';

class AppColors {
  // Primary red color scheme - refined for better contrast and accessibility
  static const Color primary = Color(0xFFDC2626); // Modern red (Tailwind red-600)
  static const Color primaryLight = Color(0xFFEF4444); // red-500
  static const Color primaryDark = Color(0xFFB91C1C); // red-700
  static const Color primaryAccent = Color(0xFF991B1B); // red-800

  // Primary color variations with opacity
  static const Color primary10 = Color(0x1ADC2626); // 10% opacity
  static const Color primary20 = Color(0x33DC2626); // 20% opacity
  static const Color primary50 = Color(0x80DC2626); // 50% opacity

  // Secondary colors - expanded palette
  static const Color secondary = Color(0xFF64748B); // Slate-500
  static const Color secondaryLight = Color(0xFF94A3B8); // Slate-400
  static const Color secondaryDark = Color(0xFF475569); // Slate-600

  // Status colors - refined for better UX
  static const Color success = Color(0xFF059669); // Emerald-600
  static const Color successLight = Color(0xFF10B981); // Emerald-500
  static const Color warning = Color(0xFFD97706); // Amber-600
  static const Color warningLight = Color(0xFFF59E0B); // Amber-500
  static const Color error = Color(0xFFE11D48); // Rose-600 (different from primary)
  static const Color errorLight = Color(0xFFF43F5E); // Rose-500
  static const Color info = Color(0xFF0EA5E9); // Sky-500
  static const Color infoLight = Color(0xFF38BDF8); // Sky-400

  // Background colors - modern neutral palette
  static const Color background = Color(0xFFFAFAFA); // Neutral-50
  static const Color backgroundSecondary = Color(0xFFF5F5F5); // Neutral-100
  static const Color surface = Colors.white;
  static const Color surfaceVariant = Color(0xFFF8FAFC); // Slate-50
  static const Color surfaceElevated = Color(0xFFFFFFFF); // Pure white with shadow

  // Card and container backgrounds
  static const Color cardBackground = Colors.white;
  static const Color containerLight = Color(0xFFF1F5F9); // Slate-100
  static const Color containerDark = Color(0xFFE2E8F0); // Slate-200

  // Sidebar colors
  static const Color sidebarBg = Color(0xFF1E293B); // Slate-800
  static const Color sidebarHover = Color(0xFF334155); // Slate-700
  static const Color sidebarActive = Color(0xFFDC2626); // Red-600

  // Text colors - improved hierarchy
  static const Color textPrimary = Color(0xFF0F172A); // Slate-900
  static const Color textSecondary = Color(0xFF334155); // Slate-700
  static const Color textTertiary = Color(0xFF64748B); // Slate-500
  static const Color textLight = Color(0xFF94A3B8); // Slate-400
  static const Color textOnPrimary = Colors.white;
  static const Color textOnDark = Colors.white;

  // Border and divider colors
  static const Color divider = Color(0xFFE2E8F0); // Slate-200
  static const Color border = Color(0xFFCBD5E1); // Slate-300
  static const Color borderLight = Color(0xFFF1F5F9); // Slate-100
  static const Color borderFocus = primary; // Use primary for focused states

  // Interactive states
  static const Color hover = Color(0xFFF8FAFC); // Slate-50
  static const Color pressed = Color(0xFFE2E8F0); // Slate-200
  static const Color disabled = Color(0xFF94A3B8); // Slate-400
  static const Color disabledBackground = Color(0xFFF1F5F9); // Slate-100

  // Gradient definitions - enhanced with more options
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFDC2626), // red-600
      Color(0xFFEF4444), // red-500
    ],
  );

  static const LinearGradient primaryDarkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF991B1B), // red-800
      Color(0xFFB91C1C), // red-700
    ],
  );

  static const LinearGradient sidebarGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF1E293B), // Slate-800
      Color(0xFF0F172A), // Slate-900
    ],
  );

  static const LinearGradient surfaceGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Colors.white,
      Color(0xFFF8FAFC), // Slate-50
    ],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Colors.white,
      Color(0xFFFAFAFA), // Neutral-50
    ],
  );

  // Red color variants - expanded palette
  static const Color red50 = Color(0xFFFEF2F2);
  static const Color red100 = Color(0xFFFEE2E2);
  static const Color red200 = Color(0xFFFECACA);
  static const Color red300 = Color(0xFFFCA5A5);
  static const Color red400 = Color(0xFFF87171);
  static const Color red500 = Color(0xFFEF4444);
  static const Color red600 = Color(0xFFDC2626); // Primary
  static const Color red700 = Color(0xFFB91C1C);
  static const Color red800 = Color(0xFF991B1B);
  static const Color red900 = Color(0xFF7F1D1D);

  // Neutral grays - complete scale
  static const Color gray50 = Color(0xFFFAFAFA);
  static const Color gray100 = Color(0xFFF5F5F5);
  static const Color gray200 = Color(0xFFE5E5E5);
  static const Color gray300 = Color(0xFFD4D4D4);
  static const Color gray400 = Color(0xFFA3A3A3);
  static const Color gray500 = Color(0xFF737373);
  static const Color gray600 = Color(0xFF525252);
  static const Color gray700 = Color(0xFF404040);
  static const Color gray800 = Color(0xFF262626);
  static const Color gray900 = Color(0xFF171717);

  // Slate grays - for UI elements
  static const Color slate50 = Color(0xFFF8FAFC);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate300 = Color(0xFFCBD5E1);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate600 = Color(0xFF475569);
  static const Color slate700 = Color(0xFF334155);
  static const Color slate800 = Color(0xFF1E293B);
  static const Color slate900 = Color(0xFF0F172A);

  // Semantic colors for specific use cases
  static const Color positive = Color(0xFF059669); // Success variant
  static const Color negative = Color(0xFFE11D48); // Error variant
  static const Color neutral = Color(0xFF64748B); // Secondary variant

  // Special purpose colors
  static const Color overlay = Color(0x80000000); // Black with 50% opacity
  static const Color overlayLight = Color(0x33000000); // Black with 20% opacity
  static const Color overlayDark = Color(0xCC000000); // Black with 80% opacity
  static const Color shadowColor = Color(0x1A000000); // Black with 10% opacity

  // Theme-specific colors (for dark mode support)
  static const Color onSurfaceVariant = Color(0xFF49454F);
  static const Color outline = Color(0xFF79747E);
  static const Color outlineVariant = Color(0xFFCAC4D0);

  // Chart colors - optimized for data visualization
  static const List<Color> chartColors = [
    Color(0xFFDC2626), // Red
    Color(0xFF059669), // Emerald
    Color(0xFFD97706), // Amber
    Color(0xFF2563EB), // Blue
    Color(0xFF7C3AED), // Violet
    Color(0xFFEC4899), // Pink
    Color(0xFF0EA5E9), // Sky
    Color(0xFF84CC16), // Lime
  ];

  // Status specific colors
  static Color getStatusColor(String status) {
    switch (status) {
      case 'Baru':
        return warning;
      case 'Sedang Ditinjau':
        return info;
      case 'Sedang Dikerjakan':
        return primaryLight;
      case 'Selesai':
        return success;
      case 'Ditolak':
        return error;
      default:
        return textSecondary;
    }
  }

  // Priority specific colors
  static Color getPriorityColor(String priority) {
    switch (priority) {
      case 'Urgent':
        return error;
      case 'High':
        return warning;
      case 'Medium':
        return info;
      case 'Low':
        return success;
      default:
        return textSecondary;
    }
  }

  // Utility methods for color manipulation
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }

  static Color lighten(Color color, [double amount = 0.1]) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0)).toColor();
  }

  static Color darken(Color color, [double amount = 0.1]) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
  }

  // Color scheme getter for easy theming
  static ColorScheme get lightColorScheme => ColorScheme.light(
    primary: primary,
    primaryContainer: red100,
    secondary: secondary,
    secondaryContainer: Color(0xFFE2E8F0),
    surface: surface,
    background: background,
    error: error,
    onPrimary: textOnPrimary,
    onSecondary: textOnDark,
    onSurface: textPrimary,
    onBackground: textPrimary,
    onError: textOnDark,
  );

  // Dark color scheme (for future dark mode support)
  static ColorScheme get darkColorScheme => ColorScheme.dark(
    primary: red400,
    primaryContainer: red800,
    secondary: Color(0xFF94A3B8),
    secondaryContainer: Color(0xFF334155),
    surface: Color(0xFF1E293B),
    background: Color(0xFF0F172A),
    error: Color(0xFFF87171),
    onPrimary: Color(0xFF000000),
    onSecondary: Color(0xFF000000),
    onSurface: Color(0xFFE2E8F0),
    onBackground: Color(0xFFE2E8F0),
    onError: Color(0xFF000000),
  );
}