import 'package:flutter/material.dart';

import '../dominio/eventos.dart';

/// Paleta café: espresso, caramelo, latte y crema.
class Cafe {
  static const espresso = Color(0xFF3B2A20); // títulos y tarjetas oscuras
  static const principal = Color(0xFF6F4E37); // botones y acentos
  static const caramelo = Color(0xFFB98B5E);
  static const latte = Color(0xFFEDE3D6); // fondos suaves
  static const crema = Color(0xFFF7F2EA); // fondo general
  static const texto = Color(0xFF2B211A);
  static const suave = Color(0xFF8A7565);
  static const borde = Color(0xFFE6DACB);
  static const entra = Color(0xFF4F7A5A); // dinero que entra
  static const sale = Color(0xFFA84B3C); // dinero que sale
}

/// Ícono de cada servicio / mini-app (en lugar de emojis).
IconData iconoServicio(Servicio s) => switch (s) {
      Servicio.mensajeria => Icons.chat_bubble_outline_rounded,
      Servicio.pagos => Icons.account_balance_wallet_outlined,
      Servicio.comercio => Icons.storefront_outlined,
      Servicio.transporte => Icons.local_taxi_outlined,
    };

IconData iconoMiniApp(String id) => switch (id) {
      'chat' => Icons.chat_bubble_outline_rounded,
      'monedero' => Icons.account_balance_wallet_outlined,
      'tienda' => Icons.storefront_outlined,
      'viajes' => Icons.local_taxi_outlined,
      'horoscopo' => Icons.nights_stay_outlined,
      _ => Icons.apps_rounded,
    };

IconData iconoTienda(String id) => switch (id) {
      'tortilleria' => Icons.bakery_dining_outlined,
      'cajeta' => Icons.icecream_outlined,
      'talavera' => Icons.local_florist_outlined,
      _ => Icons.store_outlined,
    };

class TemaCafe {
  static ThemeData get claro {
    const esquema = ColorScheme(
      brightness: Brightness.light,
      primary: Cafe.principal,
      onPrimary: Colors.white,
      primaryContainer: Cafe.latte,
      onPrimaryContainer: Cafe.espresso,
      secondary: Cafe.caramelo,
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFFF3E4D0),
      onSecondaryContainer: Cafe.espresso,
      error: Cafe.sale,
      onError: Colors.white,
      errorContainer: Color(0xFFF6E1DC),
      onErrorContainer: Color(0xFF5C2219),
      surface: Colors.white,
      onSurface: Cafe.texto,
      onSurfaceVariant: Cafe.suave,
      outline: Cafe.borde,
    );

    final redondo = RoundedRectangleBorder(borderRadius: BorderRadius.circular(14));

    return ThemeData(
      useMaterial3: true,
      colorScheme: esquema,
      scaffoldBackgroundColor: Cafe.crema,
      appBarTheme: const AppBarTheme(
        backgroundColor: Cafe.crema,
        foregroundColor: Cafe.espresso,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: Cafe.espresso,
          fontSize: 21,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Cafe.borde),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: Cafe.principal,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Cafe.latte,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          shape: redondo,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Cafe.principal,
          side: const BorderSide(color: Cafe.borde),
          backgroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
          shape: redondo,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: Cafe.principal),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        hintStyle: const TextStyle(color: Cafe.suave),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Cafe.borde),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Cafe.borde),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Cafe.principal, width: 1.6),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: Cafe.latte,
        elevation: 0,
        iconTheme: WidgetStateProperty.resolveWith(
          (s) => IconThemeData(color: s.contains(WidgetState.selected) ? Cafe.espresso : Cafe.suave),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (s) => TextStyle(
            fontSize: 12,
            fontWeight: s.contains(WidgetState.selected) ? FontWeight.w600 : FontWeight.w400,
            color: s.contains(WidgetState.selected) ? Cafe.espresso : Cafe.suave,
          ),
        ),
      ),
      badgeTheme: const BadgeThemeData(backgroundColor: Cafe.caramelo),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: Cafe.espresso,
        behavior: SnackBarBehavior.floating,
      ),
      dividerTheme: const DividerThemeData(color: Cafe.borde, space: 1),
    );
  }
}
