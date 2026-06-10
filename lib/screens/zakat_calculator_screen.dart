import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:namaz_timetable/widgets/common_app_bar.dart';

class ZakatCalculatorScreen extends StatefulWidget {
  const ZakatCalculatorScreen({super.key});

  @override
  State<ZakatCalculatorScreen> createState() => _ZakatCalculatorScreenState();
}

class _ZakatCalculatorScreenState extends State<ZakatCalculatorScreen> {
  final _formKey = GlobalKey<FormState>();

  // Input Controllers
  final goldController = TextEditingController();
  final silverController = TextEditingController();
  final cashController = TextEditingController();
  final savingsController = TextEditingController();
  final businessController = TextEditingController();
  final debtsController = TextEditingController();

  // Price Controllers (Default estimates)
  final goldPriceController = TextEditingController(text: "75000"); // 10g 24k
  final silverPriceController = TextEditingController(text: "90000"); // 1kg

  double totalWealth = 0.0;
  double zakatPayable = 0.0;
  bool isAboveNisab = false;

  // Unit toggles for weight
  String goldUnit = "g"; // "g" or "tola"
  String silverUnit = "g";

  // Unit toggles for market prices
  String goldPriceUnit = "10g"; // "10g" or "tola"
  String silverPriceUnit = "kg"; // "kg" or "tola"

  double goldSubtotal = 0.0;
  double silverSubtotal = 0.0;
  double cashSubtotal = 0.0;
  double savingsSubtotal = 0.0;
  double businessSubtotal = 0.0;
  double debtsSubtotal = 0.0;

  void _calculateZakat() {
    double goldInput = double.tryParse(goldController.text) ?? 0;
    double silverInput = double.tryParse(silverController.text) ?? 0;

    // Convert to grams for consistent calculation (Standard: 1 Tola = 11.66g)
    const double tolaToGrams = 11.66;
    double goldGrams = goldUnit == "tola" ? goldInput * tolaToGrams : goldInput;
    double silverGrams = silverUnit == "tola" ? silverInput * tolaToGrams : silverInput;

    // Prices
    double goldPriceInput = double.tryParse(goldPriceController.text) ?? 0;
    double silverPriceInput = double.tryParse(silverPriceController.text) ?? 0;

    double goldRatePerGram = goldPriceUnit == "tola" 
        ? goldPriceInput / tolaToGrams 
        : goldPriceInput / 10;

    double silverRatePerGram = silverPriceUnit == "tola"
        ? silverPriceInput / tolaToGrams
        : silverPriceInput / 1000;

    goldSubtotal = goldGrams * goldRatePerGram;
    silverSubtotal = silverGrams * silverRatePerGram;
    cashSubtotal = double.tryParse(cashController.text) ?? 0;
    savingsSubtotal = double.tryParse(savingsController.text) ?? 0;
    businessSubtotal = double.tryParse(businessController.text) ?? 0;
    debtsSubtotal = double.tryParse(debtsController.text) ?? 0;

    setState(() {
      totalWealth =
          goldSubtotal +
          silverSubtotal +
          cashSubtotal +
          savingsSubtotal +
          businessSubtotal -
          debtsSubtotal;

      // Nisab Threshold: 52.5 Tolas of Silver = 612.36g
      double silverNisabThreshold = silverRatePerGram * 612.36;

      isAboveNisab = totalWealth >= silverNisabThreshold;
      zakatPayable = isAboveNisab ? totalWealth * 0.025 : 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: CommonAppBar(title: "Zakat Calculator".tr),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderCard(isDark),
              SizedBox(height: 24.h),
              _buildSectionTitle("Assets & Wealth".tr),
              _buildInputGroup([
                _buildWeightField(goldController, "Gold".tr, goldUnit, (val) {
                  setState(() => goldUnit = val!);
                  _calculateZakat();
                }, Icons.layers),
                _buildWeightField(silverController, "Silver".tr, silverUnit, (val) {
                  setState(() => silverUnit = val!);
                  _calculateZakat();
                }, Icons.layers_outlined),
                _buildInputField(cashController, "Cash on Hand".tr, Icons.money, "Enter amount"),
                _buildInputField(
                  savingsController,
                  "Bank Savings".tr,
                  Icons.account_balance,
                  "Enter amount",
                ),
                _buildInputField(
                  businessController,
                  "Business Assets".tr,
                  Icons.store,
                  "Stock value",
                ),
              ], isDark),
              SizedBox(height: 16.h),
              _buildSectionTitle("Liabilities".tr),
              _buildInputGroup([
                _buildInputField(
                  debtsController,
                  "Debts / Expenses".tr,
                  Icons.remove_circle_outline,
                  "Amount to subtract",
                  isDebt: true,
                ),
              ], isDark),
              SizedBox(height: 24.h),
              _buildSectionTitle("Market Prices".tr),
              _buildInputGroup([
                _buildPriceInputField(
                  goldPriceController,
                  "Gold Rate".tr,
                  goldPriceUnit,
                  (val) { setState(() => goldPriceUnit = val!); _calculateZakat(); },
                  ["10g", "tola"]
                ),
                _buildPriceInputField(
                  silverPriceController,
                  "Silver Rate".tr,
                  silverPriceUnit,
                  (val) { setState(() => silverPriceUnit = val!); _calculateZakat(); },
                  ["kg", "tola"]
                ),
              ], isDark),
              Padding(
                padding: EdgeInsets.only(top: 8.h, left: 4.w),
                child: Text(
                  "* Please check current rates for accurate calculation.".tr,
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: Colors.orange.shade700,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              SizedBox(height: 32.h),
              _buildResultCard(theme, isDark),
              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard(bool isDark) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.green.shade700,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.calculate, color: Colors.white, size: 40.sp),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Zakat".tr,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Calculate your annual charity (2.5% of total wealth)".tr,
                  style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12.sp),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(left: 4.w, bottom: 8.h),
      child: Text(
        title,
        style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.grey),
      ),
    );
  }

  Widget _buildInputGroup(List<Widget> children, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildInputField(
    TextEditingController controller,
    String label,
    IconData icon,
    String hint, {
    bool isDebt = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: (_) => _calculateZakat(),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 20.sp, color: isDebt ? Colors.redAccent : Colors.green),
        border: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      ),
    );
  }

  Widget _buildPriceInputField(
    TextEditingController controller, 
    String label, 
    String currentUnit, 
    Function(String?) onUnitChanged,
    List<String> units
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          Icon(Icons.currency_rupee, size: 20.sp, color: Colors.green),
          SizedBox(width: 12.w),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (_) => _calculateZakat(),
              decoration: InputDecoration(
                labelText: "$label (per $currentUnit)",
                border: InputBorder.none,
              ),
            ),
          ),
          DropdownButton<String>(
            value: currentUnit,
            underline: const SizedBox(),
            items: units.map((unit) => DropdownMenuItem(
              value: unit, 
              child: Text(unit.tr)
            )).toList(),
            onChanged: onUnitChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildWeightField(
    TextEditingController controller,
    String label,
    String currentUnit,
    Function(String?) onUnitChanged,
    IconData icon,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          Icon(icon, size: 20.sp, color: Colors.green),
          SizedBox(width: 12.w),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (_) => _calculateZakat(),
              decoration: InputDecoration(
                labelText: "$label ($currentUnit)",
                border: InputBorder.none,
              ),
            ),
          ),
          DropdownButton<String>(
            value: currentUnit,
            underline: const SizedBox(),
            items: [
              DropdownMenuItem(value: "g", child: Text("Gram".tr)),
              DropdownMenuItem(value: "tola", child: Text("Tola".tr)),
            ],
            onChanged: onUnitChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard(ThemeData theme, bool isDark) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: isAboveNisab ? Colors.green.withOpacity(0.5) : Colors.orange.withOpacity(0.5),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Text(
            "Breakdown".tr,
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16.h),
          _buildResultRow("Gold Value".tr, goldSubtotal.toStringAsFixed(0), false),
          _buildResultRow("Silver Value".tr, silverSubtotal.toStringAsFixed(0), false),
          _buildResultRow(
            "Cash & Savings".tr,
            (cashSubtotal + savingsSubtotal).toStringAsFixed(0),
            false,
          ),
          _buildResultRow("Business Assets".tr, businessSubtotal.toStringAsFixed(0), false),
          _buildResultRow(
            "Liabilities".tr,
            "-${debtsSubtotal.toStringAsFixed(0)}",
            false,
            isRed: true,
          ),
          const Divider(),
          _buildResultRow("Total Net Wealth".tr, totalWealth.toStringAsFixed(2), false),
          _buildResultRow("Zakat Payable (2.5%)".tr, zakatPayable.toStringAsFixed(2), true),
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: isAboveNisab ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                Icon(
                  isAboveNisab ? Icons.check_circle : Icons.info,
                  color: isAboveNisab ? Colors.green : Colors.orange,
                  size: 16.sp,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    isAboveNisab
                        ? "Your wealth is above Nisab threshold. Paying Zakat is mandatory.".tr
                        : "Your wealth is below Nisab threshold. You are not required to pay Zakat."
                              .tr,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: isAboveNisab ? Colors.green : Colors.orange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isAboveNisab)
            Padding(
              padding: EdgeInsets.only(top: 12.h),
              child: Text(
                "Estimated based on silver Nisab (612.36g). Consult a scholar for complex cases."
                    .tr,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 9.sp, color: Colors.grey),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildResultRow(String label, String value, bool isHighlight, {bool isRed = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 13.sp, color: Colors.grey),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isHighlight ? 18.sp : 14.sp,
              fontWeight: FontWeight.bold,
              color: isHighlight ? Colors.green : (isRed ? Colors.redAccent : null),
            ),
          ),
        ],
      ),
    );
  }
}
