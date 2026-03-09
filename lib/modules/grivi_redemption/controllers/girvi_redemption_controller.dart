import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/utils/app_helpers.dart';
import '../../../../data/models/girvi_model.dart';
import '../../../../data/repositories/girvi_repository.dart';

class GirviRedemptionController extends GetxController {
  final GirviRepository _repository = GirviRepository();

  // ── Form controllers ──────────────────────────────────────────────────────
  final redemptionNoController = TextEditingController();
  final pledgeNoController = TextEditingController();
  final pledgedByController = TextEditingController();
  final releasedByController = TextEditingController();
  final customerNameController = TextEditingController();
  final addressController = TextEditingController();
  final articleDescController = TextEditingController();

  // Interest calculation controllers
  final loanAmountController = TextEditingController(text: '0');
  final interestRateController = TextEditingController(text: '2');
  final noOfMonthsController = TextEditingController(text: '0');
  final paymentReceivedController = TextEditingController(text: '0');
  final interestLessController = TextEditingController(text: '0');
  final noticeChargeController = TextEditingController(text: '0');
  final otherChargeController = TextEditingController(text: '0');
  final deductionController = TextEditingController(text: '0');

  // ── Observables ───────────────────────────────────────────────────────────
  final RxBool isLoading = false.obs;

  // Dates
  final Rx<DateTime> redemptionDate = DateTime.now().obs;
  final Rx<DateTime?> pledgeDate = Rx<DateTime?>(null);

  // Licensee
  final RxString selectedLicensee = 'AP'.obs;
  final List<String> licensees = ['AP', 'TS', 'KA', 'MH', 'TN', 'DL'];

  // Source girvi (pre-filled when navigating from a girvi record)
  final Rx<GirviModel?> sourceGirvi = Rx<GirviModel?>(null);

  // Computed values
  final RxDouble interest = 0.0.obs;
  final RxDouble finalInterest = 0.0.obs;
  final RxDouble total = 0.0.obs;
  final RxDouble receive = 0.0.obs;

  // Flash / form error
  final RxString formError = ''.obs;

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    // Auto-generate redemption number
    redemptionNoController.text = 'A00414'; // TODO: replace with API call
    // Pre-fill if a GirviModel was passed as argument
    final arg = Get.arguments;
    if (arg is GirviModel) {
      prefillFromGirvi(arg);
    }
    recalculate();
  }

  @override
  void onClose() {
    redemptionNoController.dispose();
    pledgeNoController.dispose();
    pledgedByController.dispose();
    releasedByController.dispose();
    customerNameController.dispose();
    addressController.dispose();
    articleDescController.dispose();
    loanAmountController.dispose();
    interestRateController.dispose();
    noOfMonthsController.dispose();
    paymentReceivedController.dispose();
    interestLessController.dispose();
    noticeChargeController.dispose();
    otherChargeController.dispose();
    deductionController.dispose();
    super.onClose();
  }

  // ── Pre-fill from existing Girvi ──────────────────────────────────────────

  void prefillFromGirvi(GirviModel girvi) {
    sourceGirvi.value = girvi;
    pledgeNoController.text = girvi.girviNo;
    customerNameController.text = girvi.customerName;
    loanAmountController.text = girvi.loanAmount.toString();
    pledgeDate.value = girvi.createdAt;

    // Back-calculate interest rate from stored amounts
    if (girvi.loanAmount > 0 && girvi.interestAmount > 0) {
      final pct = (girvi.interestAmount / girvi.loanAmount) * 100;
      interestRateController.text = pct.toStringAsFixed(2);
    }

    // Auto-calc months from pledge date → today
    final diff = DateTime.now().difference(girvi.createdAt).inDays;
    noOfMonthsController.text = (diff / 30).ceil().toString();

    recalculate();
  }

  // ── Calculations ──────────────────────────────────────────────────────────

  /// Mirrors the Interest Calculation panel on the redemption form.
  void recalculate() {
    final loan = double.tryParse(loanAmountController.text) ?? 0;
    final rate = double.tryParse(interestRateController.text) ?? 0;
    final months = double.tryParse(noOfMonthsController.text) ?? 0;
    final paid = double.tryParse(paymentReceivedController.text) ?? 0;
    final less = double.tryParse(interestLessController.text) ?? 0;
    final notice = double.tryParse(noticeChargeController.text) ?? 0;
    final other = double.tryParse(otherChargeController.text) ?? 0;
    final ded = double.tryParse(deductionController.text) ?? 0;

    final calcInterest = (loan * rate * months) / 100;
    final calcFinalInterest = (calcInterest - less + notice + other - ded)
        .clamp(0.0, double.infinity);
    final calcTotal = loan + calcFinalInterest;
    final calcReceive = calcTotal - paid;

    interest.value = calcInterest;
    finalInterest.value = calcFinalInterest;
    total.value = calcTotal;
    receive.value = calcReceive;
  }

  // ── Date helpers ──────────────────────────────────────────────────────────

  void setRedemptionDate(DateTime date) {
    redemptionDate.value = date;
    _autoCalcMonths();
    recalculate();
  }

  void setPledgeDate(DateTime date) {
    pledgeDate.value = date;
    _autoCalcMonths();
    recalculate();
  }

  void _autoCalcMonths() {
    if (pledgeDate.value == null) return;
    final diff = redemptionDate.value.difference(pledgeDate.value!).inDays;
    noOfMonthsController.text = (diff / 30).ceil().clamp(0, 999).toString();
  }

  // ── Validation ────────────────────────────────────────────────────────────

  bool _validate() {
    formError.value = '';

    if (pledgeNoController.text.trim().isEmpty) {
      formError.value = 'Please enter the Pledge (Girvi) Number.';
      return false;
    }
    if (customerNameController.text.trim().isEmpty) {
      formError.value = 'Please enter the customer name.';
      return false;
    }
    final loan = double.tryParse(loanAmountController.text) ?? 0;
    if (loan <= 0) {
      formError.value = 'Loan amount must be greater than zero.';
      return false;
    }
    return true;
  }

  // ── Save Redemption ───────────────────────────────────────────────────────

  Future<void> saveRedemption() async {
    if (!_validate()) return;

    isLoading.value = true;

    // TODO: wire to _repository.createRedemption(payload) once API is ready
    // Example payload:
    // final payload = {
    //   'redemption_no': redemptionNoController.text.trim(),
    //   'pledge_no': pledgeNoController.text.trim(),
    //   'redemption_date': redemptionDate.value.toIso8601String(),
    //   'pledge_date': pledgeDate.value?.toIso8601String(),
    //   'licensee': selectedLicensee.value,
    //   'pledged_by': pledgedByController.text.trim(),
    //   'released_by': releasedByController.text.trim(),
    //   'customer_name': customerNameController.text.trim(),
    //   'address': addressController.text.trim(),
    //   'article_description': articleDescController.text.trim(),
    //   'loan_amount': double.tryParse(loanAmountController.text) ?? 0,
    //   'interest_rate': double.tryParse(interestRateController.text) ?? 0,
    //   'no_of_months': double.tryParse(noOfMonthsController.text) ?? 0,
    //   'interest': interest.value,
    //   'payment_received': double.tryParse(paymentReceivedController.text) ?? 0,
    //   'interest_less': double.tryParse(interestLessController.text) ?? 0,
    //   'notice_charge': double.tryParse(noticeChargeController.text) ?? 0,
    //   'other_charge': double.tryParse(otherChargeController.text) ?? 0,
    //   'deduction': double.tryParse(deductionController.text) ?? 0,
    //   'final_interest': finalInterest.value,
    //   'total': total.value,
    //   'receive': receive.value,
    // };
    // final result = await _repository.createRedemption(payload);

    await Future.delayed(
      const Duration(milliseconds: 600),
    ); // remove when wired
    isLoading.value = false;

    // if (result['success']) {
    AppHelpers.showSuccessSnackbar('Redemption saved successfully');
    _clearForm();
    Get.back();
    // } else {
    //   formError.value = result['message'] ?? 'Failed to save redemption';
    //   AppHelpers.showErrorSnackbar(result['message']);
    // }
  }

  // ── Reset ─────────────────────────────────────────────────────────────────

  void resetForm() {
    _clearForm();
    redemptionNoController.text = 'A00414'; // TODO: re-fetch from API
    recalculate();
  }

  void _clearForm() {
    pledgeNoController.clear();
    pledgedByController.clear();
    releasedByController.clear();
    customerNameController.clear();
    addressController.clear();
    articleDescController.clear();
    loanAmountController.text = '0';
    interestRateController.text = '2';
    noOfMonthsController.text = '0';
    paymentReceivedController.text = '0';
    interestLessController.text = '0';
    noticeChargeController.text = '0';
    otherChargeController.text = '0';
    deductionController.text = '0';
    pledgeDate.value = null;
    redemptionDate.value = DateTime.now();
    selectedLicensee.value = 'AP';
    sourceGirvi.value = null;
    formError.value = '';
    interest.value = 0;
    finalInterest.value = 0;
    total.value = 0;
    receive.value = 0;
  }
}
