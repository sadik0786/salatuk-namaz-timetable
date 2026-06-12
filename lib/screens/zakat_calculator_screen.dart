import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

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

  final NumberFormat currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );
  final NumberFormat zakatFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  void _clearAll() {
    goldController.clear();
    silverController.clear();
    cashController.clear();
    savingsController.clear();
    businessController.clear();
    debtsController.clear();
    _calculateZakat();
  }

  void _calculateZakat() {
    double goldInput = (double.tryParse(goldController.text) ?? 0).abs();
    double silverInput = (double.tryParse(silverController.text) ?? 0).abs();

    // Convert to grams for consistent calculation (Standard: 1 Tola = 11.66g)
    const double tolaToGrams = 11.66;
    double goldGrams = goldUnit == "tola" ? goldInput * tolaToGrams : goldInput;
    double silverGrams = silverUnit == "tola"
        ? silverInput * tolaToGrams
        : silverInput;

    // Prices
    double goldPriceInput = (double.tryParse(goldPriceController.text) ?? 0)
        .abs();
    double silverPriceInput = (double.tryParse(silverPriceController.text) ?? 0)
        .abs();

    double goldRatePerGram = goldPriceUnit == "tola"
        ? goldPriceInput / tolaToGrams
        : goldPriceInput / 10;

    double silverRatePerGram = silverPriceUnit == "tola"
        ? silverPriceInput / tolaToGrams
        : silverPriceInput / 1000;

    goldSubtotal = goldGrams * goldRatePerGram;
    silverSubtotal = silverGrams * silverRatePerGram;
    cashSubtotal = (double.tryParse(cashController.text) ?? 0).abs();
    savingsSubtotal = (double.tryParse(savingsController.text) ?? 0).abs();
    businessSubtotal = (double.tryParse(businessController.text) ?? 0).abs();
    debtsSubtotal = (double.tryParse(debtsController.text) ?? 0).abs();

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
      backgroundColor: isDark
          ? const Color(0xFF0F172A)
          : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text("Zakat Calculator".tr),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _clearAll,
            tooltip: 'Clear All'.tr,
          ),
        ],
      ),
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
                _buildWeightField(silverController, "Silver".tr, silverUnit, (
                  val,
                ) {
                  setState(() => silverUnit = val!);
                  _calculateZakat();
                }, Icons.layers_outlined),
                _buildInputField(
                  cashController,
                  "Cash on Hand".tr,
                  Icons.money,
                  "Enter amount",
                  helpText: "Cash you have at home or in hand.",
                ),
                _buildInputField(
                  savingsController,
                  "Bank Savings".tr,
                  Icons.account_balance,
                  "Enter amount",
                  helpText: "Money saved in bank accounts.",
                ),
                _buildInputField(
                  businessController,
                  "Business Assets".tr,
                  Icons.store,
                  "Stock value",
                  helpText: "Value of goods/stock meant for sale.",
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
                  helpText: "Money you owe or pending bills for this year.",
                ),
              ], isDark),
              SizedBox(height: 0.h),
              Theme(
                data: Theme.of(
                  context,
                ).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  initiallyExpanded: false,
                  title: _buildSectionTitle("Market Prices (Tap to Edit)".tr),
                  children: [
                    _buildInputGroup([
                      _buildPriceInputField(
                        goldPriceController,
                        "Gold Rate".tr,
                        goldPriceUnit,
                        (val) {
                          setState(() => goldPriceUnit = val!);
                          _calculateZakat();
                        },
                        ["10g", "tola"],
                      ),
                      _buildPriceInputField(
                        silverPriceController,
                        "Silver Rate".tr,
                        silverPriceUnit,
                        (val) {
                          setState(() => silverPriceUnit = val!);
                          _calculateZakat();
                        },
                        ["kg", "tola"],
                      ),
                    ], isDark),
                    Padding(
                      padding: EdgeInsets.only(
                        top: 8.h,
                        left: 4.w,
                        bottom: 8.h,
                      ),
                      child: Text(
                        "* Please check current rates for accurate calculation."
                            .tr,
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: Colors.orange.shade700,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 5.h),
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
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F766E), Color(0xFF10B981)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
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
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 12.sp,
                  ),
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
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildInputGroup(List<Widget> children, bool isDark) {
    return Column(
      children: children
          .map(
            (child) => Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: child,
            ),
          )
          .toList(),
    );
  }

  Widget _buildInputField(
    TextEditingController controller,
    String label,
    IconData icon,
    String hint, {
    bool isDebt = false,
    String? helpText,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        onChanged: (_) => _calculateZakat(),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(
            icon,
            size: 20.sp,
            color: isDebt ? Colors.redAccent : Colors.green,
          ),
          suffixIcon: helpText != null
              ? IconButton(
                  icon: Icon(
                    Icons.help_outline,
                    color: Colors.grey,
                    size: 18.sp,
                  ),
                  onPressed: () {
                    Get.snackbar(
                      label.tr,
                      helpText.tr,
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.black87,
                      colorText: Colors.white,
                      margin: EdgeInsets.all(16.w),
                      borderRadius: 12.r,
                    );
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 16.h,
          ),
        ),
      ),
    );
  }

  Widget _buildPriceInputField(
    TextEditingController controller,
    String label,
    String currentUnit,
    Function(String?) onUnitChanged,
    List<String> units,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.currency_rupee, size: 20.sp, color: Colors.green),
          SizedBox(width: 12.w),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              onChanged: (_) => _calculateZakat(),
              decoration: InputDecoration(
                labelText: "$label (per $currentUnit)",
                hintText: "0.0",
                hintStyle: TextStyle(color: Colors.grey.withOpacity(0.5)),
                border: InputBorder.none,
              ),
            ),
          ),
          DropdownButton<String>(
            value: currentUnit,
            underline: const SizedBox(),
            items: units
                .map(
                  (unit) => DropdownMenuItem(value: unit, child: Text(unit.tr)),
                )
                .toList(),
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 20.sp, color: Colors.green),
          SizedBox(width: 12.w),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              onChanged: (_) => _calculateZakat(),
              decoration: InputDecoration(
                labelText: "$label ($currentUnit)",
                hintText: "0.0",
                hintStyle: TextStyle(color: Colors.grey.withOpacity(0.5)),
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
          color: isAboveNisab
              ? Colors.green.withOpacity(0.5)
              : Colors.orange.withOpacity(0.5),
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
          _buildResultRow(
            "Gold Value".tr,
            currencyFormat.format(goldSubtotal),
            false,
          ),
          _buildResultRow(
            "Silver Value".tr,
            currencyFormat.format(silverSubtotal),
            false,
          ),
          _buildResultRow(
            "Cash & Savings".tr,
            currencyFormat.format(cashSubtotal + savingsSubtotal),
            false,
          ),
          _buildResultRow(
            "Business Assets".tr,
            currencyFormat.format(businessSubtotal),
            false,
          ),
          _buildResultRow(
            "Liabilities".tr,
            "-${currencyFormat.format(debtsSubtotal)}",
            false,
            isRed: true,
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            child: Divider(color: Colors.grey.withOpacity(0.3), thickness: 1.5),
          ),
          _buildResultRow(
            "Total Net Wealth".tr,
            currencyFormat.format(totalWealth),
            false,
            isBold: true,
          ),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: isAboveNisab ? Colors.green.shade50 : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: isAboveNisab
                    ? Colors.green.shade200
                    : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: _buildResultRow(
              "Zakat Payable (2.5%)".tr,
              zakatFormat.format(zakatPayable),
              true,
            ),
          ),
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: isAboveNisab
                  ? Colors.green.withOpacity(0.1)
                  : Colors.orange.withOpacity(0.1),
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
                        ? "Your wealth is above Nisab threshold. Paying Zakat is mandatory."
                              .tr
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

  Widget _buildResultRow(
    String label,
    String value,
    bool isHighlight, {
    bool isRed = false,
    bool isBold = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isBold ? 14.sp : 13.sp,
              color: isBold ? null : Colors.grey,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isHighlight ? 20.sp : (isBold ? 16.sp : 14.sp),
              fontWeight: FontWeight.bold,
              color: isHighlight
                  ? Colors.green.shade700
                  : (isRed ? Colors.redAccent : null),
            ),
          ),
        ],
      ),
    );
  }
}
