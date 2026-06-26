import 'package:flutter/material.dart';

import '../services/rate_service.dart';
import '../utils/number_format.dart';
import '../widgets/labeled_number_field.dart';
import '../widgets/result_tile.dart';

const _primary = Color(0xFF0F766E);
const _primaryDark = Color(0xFF115E59);
const _soft = Color(0xFFE6F7F4);
const _muted = Color(0xFF667085);
const _text = Color(0xFF152238);
const _warningBg = Color(0xFFFFF7ED);
const _warningBorder = Color(0xFFFED7AA);

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  // المتحكمات الخاصة بحقول الإدخال - بنفس القيم الافتراضية للصفحة الأصلية.
  final _fruitPriceEgpCtrl = TextEditingController();
  final _truckWeightCtrl = TextEditingController(text: '30000');
  final _usdEgpRateCtrl = TextEditingController();
  final _egyptDeliveryUsdCtrl = TextEditingController(text: '6000');
  final _customsUsdCtrl = TextEditingController(text: '1600');
  final _iraqDeliveryUsdCtrl = TextEditingController(text: '1000');
  final _iqdPer100UsdCtrl = TextEditingController(text: '138000');
  final _boxWeightCtrl = TextEditingController(text: '15');

  // نتائج الحساب.
  double _fruitCostEgp = 0;
  double _fruitCostUsd = 0;
  double _totalUsd = 0;
  double _totalIqd = 0;
  double _pricePerKgIqd = 0;
  double _boxPriceIqd = 0;

  // حالة سعر الصرف.
  bool _isLoadingRate = true;
  String _rateText = 'جاري الجلب...';
  String _rateSourceText = 'المصدر: --';

  @override
  void initState() {
    super.initState();
    for (final ctrl in _allControllers) {
      ctrl.addListener(_calculate);
    }
    _loadRate();
  }

  List<TextEditingController> get _allControllers => [
        _fruitPriceEgpCtrl,
        _truckWeightCtrl,
        _usdEgpRateCtrl,
        _egyptDeliveryUsdCtrl,
        _customsUsdCtrl,
        _iraqDeliveryUsdCtrl,
        _iqdPer100UsdCtrl,
        _boxWeightCtrl,
      ];

  @override
  void dispose() {
    for (final ctrl in _allControllers) {
      ctrl.removeListener(_calculate);
      ctrl.dispose();
    }
    super.dispose();
  }

  double _num(TextEditingController ctrl) =>
      double.tryParse(ctrl.text.trim()) ?? 0;

  void _calculate() {
    final fruitPriceEgp = _num(_fruitPriceEgpCtrl);
    final truckWeight = _num(_truckWeightCtrl);
    final usdEgpRate = _num(_usdEgpRateCtrl);
    final egyptDeliveryUsd = _num(_egyptDeliveryUsdCtrl);
    final customsUsd = _num(_customsUsdCtrl);
    final iraqDeliveryUsd = _num(_iraqDeliveryUsdCtrl);
    final iqdPer100Usd = _num(_iqdPer100UsdCtrl);
    final boxWeight = _num(_boxWeightCtrl);

    // نفس شرط الحماية الموجود في app.js: لا يمكن الحساب بدون هذه القيم.
    if (truckWeight == 0 || usdEgpRate == 0 || iqdPer100Usd == 0 || boxWeight == 0) {
      return;
    }

    final fruitCostEgp = fruitPriceEgp * truckWeight;
    final fruitCostUsd = fruitCostEgp / usdEgpRate;
    final totalUsd = fruitCostUsd + egyptDeliveryUsd + customsUsd + iraqDeliveryUsd;
    final usdToIqd = iqdPer100Usd / 100;
    final totalIqd = totalUsd * usdToIqd;
    final pricePerKgIqd = totalIqd / truckWeight;
    final boxPriceIqd = pricePerKgIqd * boxWeight;

    setState(() {
      _fruitCostEgp = fruitCostEgp;
      _fruitCostUsd = fruitCostUsd;
      _totalUsd = totalUsd;
      _totalIqd = totalIqd;
      _pricePerKgIqd = pricePerKgIqd;
      _boxPriceIqd = boxPriceIqd;
    });
  }

  Future<void> _loadRate() async {
    setState(() {
      _isLoadingRate = true;
      _rateText = 'جاري الجلب...';
      _rateSourceText = 'المصدر: --';
    });

    final result = await RateService.fetchUsdToEgpRate();

    _usdEgpRateCtrl.text = result.rate.toStringAsFixed(4);

    setState(() {
      _isLoadingRate = false;
      _rateText = '${result.rate.toStringAsFixed(4)} ج.م';
      _rateSourceText = result.fallback
          ? 'تعذر الجلب التلقائي حالياً - تم استخدام سعر احتياطي'
          : 'المصدر: ${result.source}';
    });

    _calculate();
  }

  void _resetDefaults() {
    _fruitPriceEgpCtrl.clear();
    _truckWeightCtrl.text = '30000';
    _egyptDeliveryUsdCtrl.text = '6000';
    _customsUsdCtrl.text = '1600';
    _iraqDeliveryUsdCtrl.text = '1000';
    _iqdPer100UsdCtrl.text = '155000';
    _boxWeightCtrl.text = '15';
    _calculate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHero(),
              const SizedBox(height: 16),
              _buildRateCard(),
              const SizedBox(height: 16),
              _buildFormPanel(),
              const SizedBox(height: 16),
              _buildResultsPanel(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _panelDecoration({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildHero() {
    return _panelDecoration(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: _soft,
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text(
              'حاسبة تصدير الفاكهة',
              style: TextStyle(
                color: _primaryDark,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'احسب تكلفة البراد من مصر إلى العراق',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              height: 1.2,
              color: _text,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRateCard() {
    return _panelDecoration(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('سعر الدولار مقابل الجنيه',
                    style: TextStyle(color: _muted, fontSize: 13)),
                const SizedBox(height: 8),
                Text(_rateText,
                    style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: _text)),
                const SizedBox(height: 4),
                Text(_rateSourceText,
                    style: const TextStyle(color: _muted, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: _isLoadingRate ? null : _loadRate,
            style: ElevatedButton.styleFrom(
              backgroundColor: _primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: _isLoadingRate
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('تحديث السعر', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildFormPanel() {
    return _panelDecoration(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('بيانات الحساب',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _text)),
          const SizedBox(height: 4),
          const Text('يمكنك تعديل القيم حسب كل شحنة.',
              style: TextStyle(color: _muted)),
          const SizedBox(height: 18),
          LabeledNumberField(
            label: 'سعر الكيلو بالجنيه المصري',
            controller: _fruitPriceEgpCtrl,
            hint: 'مثال: 18',
          ),
          const SizedBox(height: 14),
          LabeledNumberField(
            label: 'وزن البراد بالكيلو',
            controller: _truckWeightCtrl,
          ),
          const SizedBox(height: 14),
          LabeledNumberField(
            label: 'سعر الدولار مقابل الجنيه المصري',
            controller: _usdEgpRateCtrl,
            hint: 'يتم جلبه تلقائياً',
          ),
          const SizedBox(height: 14),
          LabeledNumberField(
            label: 'أجرة التوصيل داخل مصر بالدولار',
            controller: _egyptDeliveryUsdCtrl,
          ),
          const SizedBox(height: 14),
          LabeledNumberField(
            label: 'التخليص الجمركي بالدولار',
            controller: _customsUsdCtrl,
          ),
          const SizedBox(height: 14),
          LabeledNumberField(
            label: 'توصيل العراق بالدولار',
            controller: _iraqDeliveryUsdCtrl,
          ),
          const SizedBox(height: 14),
          LabeledNumberField(
            label: 'سعر الصرف العراقي لكل 100 دولار',
            controller: _iqdPer100UsdCtrl,
          ),
          const SizedBox(height: 14),
          LabeledNumberField(
            label: 'وزن الصندوق بالكيلو',
            controller: _boxWeightCtrl,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _calculate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text('احسب التكلفة',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: _resetDefaults,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _text,
                    backgroundColor: const Color(0xFFEEF2F7),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text('إعادة القيم الافتراضية',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _warningBg,
              border: Border.all(color: _warningBorder),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Text(
              'ملاحظة: في حال تعذّر جلب سعر الدولار تلقائياً، يمكنك إدخاله يدوياً وسيتم الحساب مباشرة.',
              style: TextStyle(color: _muted, height: 1.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsPanel() {
    return _panelDecoration(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('النتائج',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _text)),
          const SizedBox(height: 4),
          const Text('الأرقام تظهر حسب القيم المدخلة.',
              style: TextStyle(color: _muted)),
          const SizedBox(height: 16),
          ResultTile(
            label: 'تكلفة الفاكهة بالجنيه',
            value: formatNumber(_fruitCostEgp, decimals: 2, suffix: 'ج.م'),
          ),
          const SizedBox(height: 12),
          ResultTile(
            label: 'تكلفة الفاكهة بالدولار',
            value: formatNumber(_fruitCostUsd, decimals: 2, suffix: '\$'),
          ),
          const SizedBox(height: 12),
          ResultTile(
            label: 'إجمالي البراد واصل العراق بالدولار',
            value: formatNumber(_totalUsd, decimals: 2, suffix: '\$'),
            highlight: true,
          ),
          const SizedBox(height: 12),
          ResultTile(
            label: 'إجمالي البراد بالدينار العراقي',
            value: formatNumber(_totalIqd, suffix: 'د.ع'),
          ),
          const SizedBox(height: 12),
          ResultTile(
            label: 'سعر الكيلو بالدينار العراقي',
            value: formatNumber(_pricePerKgIqd, suffix: 'د.ع'),
            highlight: true,
          ),
          const SizedBox(height: 12),
          ResultTile(
            label: 'سعر الصندوق بالدينار العراقي',
            value: formatNumber(_boxPriceIqd, suffix: 'د.ع'),
          ),
        ],
      ),
    );
  }
}
