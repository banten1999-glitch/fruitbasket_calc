import 'dart:convert';
import 'package:http/http.dart' as http;

/// نتيجة جلب سعر الصرف.
class RateResult {
  final double rate;
  final String source;
  final bool fallback;

  RateResult({
    required this.rate,
    required this.source,
    required this.fallback,
  });
}

/// خدمة جلب سعر الدولار مقابل الجنيه المصري.
///
/// تكرّر نفس منطق ملف api/rate.php الأصلي:
/// تحاول المصدر الأول، ثم الثاني، وإن فشل الاثنان تُعيد سعرًا احتياطيًا
/// حتى لا تتوقف الحاسبة عن العمل.
class RateService {
  static const double fallbackRate = 48.50;

  static Future<RateResult> fetchUsdToEgpRate() async {
    final sources = <Future<RateResult?> Function()>[
      _fetchFromOpenErApi,
      _fetchFromExchangerateHost,
    ];

    for (final source in sources) {
      final result = await source();
      if (result != null) return result;
    }

    return RateResult(
      rate: fallbackRate,
      source: 'سعر احتياطي (تعذر الاتصال بالإنترنت)',
      fallback: true,
    );
  }

  static Future<RateResult?> _fetchFromOpenErApi() async {
    try {
      final response = await http
          .get(Uri.parse('https://open.er-api.com/v6/latest/USD'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final rates = data['rates'] as Map<String, dynamic>?;
        final rate = rates?['EGP'];
        if (rate is num) {
          return RateResult(
            rate: rate.toDouble(),
            source: 'open.er-api.com',
            fallback: false,
          );
        }
      }
    } catch (_) {
      // تجاهل الخطأ والمرور إلى المصدر التالي.
    }
    return null;
  }

  static Future<RateResult?> _fetchFromExchangerateHost() async {
    try {
      final response = await http
          .get(Uri.parse(
              'https://api.exchangerate.host/latest?base=USD&symbols=EGP'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final rates = data['rates'] as Map<String, dynamic>?;
        final rate = rates?['EGP'];
        if (rate is num) {
          return RateResult(
            rate: rate.toDouble(),
            source: 'exchangerate.host',
            fallback: false,
          );
        }
      }
    } catch (_) {
      // تجاهل الخطأ، سيتم استخدام السعر الاحتياطي.
    }
    return null;
  }
}
