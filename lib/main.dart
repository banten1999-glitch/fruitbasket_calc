import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'screens/calculator_screen.dart';

void main() {
  runApp(const FruitExportCalculatorApp());
}

class FruitExportCalculatorApp extends StatelessWidget {
  const FruitExportCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.tajawalTextTheme();

    return MaterialApp(
      title: 'حاسبة تصدير الفاكهة',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F7FB),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0F766E)),
        textTheme: textTheme,
      ),
      // الصفحة الأصلية بلغة عربية واتجاه من اليمين لليسار (RTL).
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
      home: const CalculatorScreen(),
    );
  }
}
