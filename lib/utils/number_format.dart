import 'package:intl/intl.dart';

/// ينسّق رقمًا بفواصل الآلاف ويضيف اللاحقة (عملة) إن وُجدت.
/// تُستخدم أرقام عربية غربية (0-9) لتسهيل القراءة على الجميع.
String formatNumber(double value, {int decimals = 0, String suffix = ''}) {
  final pattern = decimals > 0 ? '#,##0.${'0' * decimals}' : '#,##0';
  final formatted = NumberFormat(pattern, 'en_US').format(value);
  return suffix.isEmpty ? formatted : '$formatted $suffix';
}
