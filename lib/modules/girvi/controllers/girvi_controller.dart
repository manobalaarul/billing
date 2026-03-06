import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/utils/app_helpers.dart';
import '../../../../data/models/girvi_model.dart';
import '../../../../data/repositories/girvi_repository.dart';

class GirviStats {
  final int totalGirvi;
  final int activeGirvi;
  final int closedGirvi;
  final double totalActiveLoan;

  GirviStats({
    required this.totalGirvi,
    required this.activeGirvi,
    required this.closedGirvi,
    required this.totalActiveLoan,
  });
}

class GirviController extends GetxController {
  final GirviRepository _repository = GirviRepository();

  // ── Form controllers ──────────────────────────────────────────────────────
  final girviNoController = TextEditingController();
  final customerSearchController = TextEditingController();
  final grossWeightController = TextEditingController();
  final deductionController = TextEditingController();
  final netWeightController = TextEditingController();
  final loanAmountController = TextEditingController();
  final interestPercentController = TextEditingController(text: '2');
  final notesController = TextEditingController();

  // ── Observables ───────────────────────────────────────────────────────────
  final RxBool isLoading = false.obs;
  final RxBool isSearchingCustomer = false.obs;
  final RxList<GirviModel> girvis = <GirviModel>[].obs;
  final Rx<GirviStats?> stats = Rx<GirviStats?>(null);

  // Metal prices map: {'GOLD': 14620.0, 'SILVER': 355.0, ...}
  final RxMap<String, double> metalPrices = <String, double>{}.obs;
  final RxDouble selectedMetalPricePerGram = 0.0.obs;

  // Computed values
  final RxDouble totalMetalValue = 0.0.obs;
  final RxDouble monthlyInterest = 0.0.obs;

  // Customer search
  final RxList<Map<String, dynamic>> customerSearchResults =
      <Map<String, dynamic>>[].obs;
  final RxString selectedCustomerId = ''.obs;
  final RxString selectedCustomerName = ''.obs;
  final RxString selectedCustomerPhone = ''.obs;
  final RxBool showNoCustomerWarning = false.obs;

  // Form fields
  final RxString selectedMetalType = 'GOLD'.obs;
  final RxString selectedStatus = 'ACTIVE'.obs;
  final Rx<DateTime?> selectedDueDate = Rx<DateTime?>(null);
  final RxString nextGirviNo = 'GV-001'.obs;

  // Filters
  final RxString searchQuery = ''.obs;
  final RxString filterMetalType = ''.obs;
  final RxString filterStatus = ''.obs;

  // Flash messages
  final RxString successMessage = ''.obs;
  final RxString errorMessage = ''.obs;

  // Form error
  final RxString formError = ''.obs;

  final List<String> metalTypes = [
    'GOLD',
    'SILVER',
    'DIAMOND',
    'PLATINUM',
    'OTHER',
  ];

  // Customer search debounce
  Worker? _searchDebounce;

  @override
  void onInit() {
    super.onInit();
    // loadGirvis();
    // loadStats();
  }

  // ── Metal Prices ──────────────────────────────────────────────────────────

  Future<void> loadMetalPrices() async {
    final result = await _repository.getMetalPrices();
    if (result['success'] && result['data'] != null) {
      final List metals = result['data'] as List;
      for (final m in metals) {
        final name = (m['metal_name'] as String).toUpperCase();
        final price = (m['price_per_gram'] as num).toDouble();
        metalPrices[name] = price;
      }
      // Update price for currently selected metal
      _updateMetalPrice();
    }
  }

  void _updateMetalPrice() {
    selectedMetalPricePerGram.value =
        metalPrices[selectedMetalType.value] ?? 0.0;
    recalculate();
  }

  void selectMetalType(String type) {
    selectedMetalType.value = type;
    _updateMetalPrice();
  }

  // ── Auto Calculations (mirrors blade calcAll()) ───────────────────────────

  void recalculate() {
    final gw = double.tryParse(grossWeightController.text) ?? 0;
    final ded = double.tryParse(deductionController.text) ?? 0;
    final rate = selectedMetalPricePerGram.value;
    final loan = double.tryParse(loanAmountController.text) ?? 0;
    final intP = double.tryParse(interestPercentController.text) ?? 0;

    final net = (gw - ded).clamp(0.0, double.infinity);
    final totVal = net * rate;
    final intAmt = (loan * intP) / 100;

    netWeightController.text = net.toStringAsFixed(3);
    totalMetalValue.value = totVal;
    monthlyInterest.value = intAmt;
  }

  // ── Customer Search ───────────────────────────────────────────────────────

  void searchCustomers(String query) {
    if (query.length < 2) {
      customerSearchResults.clear();
      return;
    }
    // Simple debounce
    Future.delayed(const Duration(milliseconds: 400), () async {
      if (customerSearchController.text != query) return;
      isSearchingCustomer.value = true;
      final result = await _repository.searchCustomers(query);
      isSearchingCustomer.value = false;
      if (result['success']) {
        customerSearchResults.value = List<Map<String, dynamic>>.from(
          result['data'] ?? [],
        );
      }
    });
  }

  void selectCustomer(Map<String, dynamic> customer) {
    selectedCustomerId.value = customer['id']?.toString() ?? '';
    selectedCustomerName.value = customer['name'] ?? '';
    selectedCustomerPhone.value = customer['mobile'] ?? '';
    customerSearchController.text = customer['name'] ?? '';
    customerSearchResults.clear();
    showNoCustomerWarning.value = false;
  }

  void clearCustomerSelection() {
    selectedCustomerId.value = '';
    selectedCustomerName.value = '';
    selectedCustomerPhone.value = '';
    customerSearchController.clear();
    customerSearchResults.clear();
  }

  // ── Load ──────────────────────────────────────────────────────────────────

  // Future<void> loadGirvis({
  //   String? search,
  //   String? metalType,
  //   String? status,
  // }) async {
  //   isLoading.value = true;
  //   final result = await _repository.getGirvis(
  //     search: search ?? searchQuery.value,
  //     metalType: metalType ?? filterMetalType.value,
  //     status: status ?? filterStatus.value,
  //   );
  //   isLoading.value = false;
  //   if (result['success']) {
  //     girvis.value = result['data'];
  //   } else {
  //     AppHelpers.showErrorSnackbar(result['message']);
  //   }
  // }

  // Future<void> loadStats() async {
  //   final result = await _repository.getGirviStats();
  //   if (result['success'] && result['data'] != null) {
  //     final d = result['data'];
  //     stats.value = GirviStats(
  //       totalGirvi: d['total_girvi'] ?? 0,
  //       activeGirvi: d['active_girvi'] ?? 0,
  //       closedGirvi: d['closed_girvi'] ?? 0,
  //       totalActiveLoan: (d['total_active_loan'] ?? 0).toDouble(),
  //     );
  //   } else {
  //     _computeStatsLocally();
  //   }
  // }

  void _computeStatsLocally() {
    final total = girvis.length;
    final active = girvis.where((g) => g.isActive).length;
    final closed = total - active;
    final loanSum = girvis
        .where((g) => g.isActive)
        .fold(0.0, (s, g) => s + g.loanAmount);
    stats.value = GirviStats(
      totalGirvi: total,
      activeGirvi: active,
      closedGirvi: closed,
      totalActiveLoan: loanSum,
    );
  }

  // Future<void> loadNextGirviNo() async {
  //   final result = await _repository.getNextGirviNo();
  //   if (result['success']) {
  //     nextGirviNo.value = result['data'] ?? 'GV-001';
  //     girviNoController.text = nextGirviNo.value;
  //   }
  // }

  // ── Create / Update ───────────────────────────────────────────────────────

  // Future<void> createGirvi() async {
  //   if (!_validateForm()) return;

  //   isLoading.value = true;

  //   final interestAmt = monthlyInterest.value > 0
  //       ? monthlyInterest.value
  //       : (double.tryParse(loanAmountController.text) ?? 0) *
  //             (double.tryParse(interestPercentController.text) ?? 0) /
  //             100;

  //   final girvi = GirviModel(
  //     girviNo: girviNoController.text.trim(),
  //     customerId: selectedCustomerId.value,
  //     customerName: selectedCustomerName.value,
  //     customerPhone: selectedCustomerPhone.value,
  //     metalType: selectedMetalType.value,
  //     grossWeight: double.tryParse(grossWeightController.text) ?? 0,
  //     netWeight: double.tryParse(netWeightController.text) ?? 0,
  //     loanAmount: double.tryParse(loanAmountController.text) ?? 0,
  //     interestAmount: interestAmt,
  //     dueDate: selectedDueDate.value,
  //     status: selectedStatus.value,
  //     notes: notesController.text.isEmpty ? null : notesController.text,
  //     createdAt: DateTime.now(),
  //   );

  //   final result = await _repository.createGirvi(girvi);
  //   isLoading.value = false;

  //   if (result['success']) {
  //     AppHelpers.showSuccessSnackbar(
  //       result['message'] ?? 'Girvi created successfully',
  //     );
  //     _clearForm();
  //     Get.back();
  //     loadGirvis();
  //     loadStats();
  //   } else {
  //     formError.value = result['message'] ?? 'Failed to create girvi';
  //     AppHelpers.showErrorSnackbar(result['message']);
  //   }
  // }

  Future<void> updateGirvi(GirviModel existing) async {
    if (!_validateForm()) return;

    isLoading.value = true;

    final interestAmt = monthlyInterest.value > 0
        ? monthlyInterest.value
        : existing.interestAmount;

    final updated = existing.copyWith(
      customerName: selectedCustomerName.value.isNotEmpty
          ? selectedCustomerName.value
          : existing.customerName,
      customerPhone: selectedCustomerPhone.value.isNotEmpty
          ? selectedCustomerPhone.value
          : existing.customerPhone,
      metalType: selectedMetalType.value,
      grossWeight: double.tryParse(grossWeightController.text) ?? 0,
      netWeight: double.tryParse(netWeightController.text) ?? 0,
      loanAmount: double.tryParse(loanAmountController.text) ?? 0,
      interestAmount: interestAmt,
      dueDate: selectedDueDate.value,
      status: selectedStatus.value,
      notes: notesController.text.isEmpty ? null : notesController.text,
      updatedAt: DateTime.now(),
    );

    final result = await _repository.updateGirvi(updated);
    isLoading.value = false;

    if (result['success']) {
      AppHelpers.showSuccessSnackbar(
        result['message'] ?? 'Girvi updated successfully',
      );
      _clearForm();
      Get.back();
      // loadGirvis();
    } else {
      formError.value = result['message'] ?? 'Failed to update girvi';
      AppHelpers.showErrorSnackbar(result['message']);
    }
  }

  // ── Close / Delete ────────────────────────────────────────────────────────

  Future<void> closeGirvi(String id, String girviNo) async {
    final confirmed = await AppHelpers.showConfirmDialog(
      title: 'Close Girvi',
      message: 'Mark Girvi #$girviNo as CLOSED?',
      confirmText: 'Close',
    );
    if (!confirmed) return;

    AppHelpers.showLoadingDialog();
    final result = await _repository.closeGirvi(id);
    AppHelpers.hideLoadingDialog();

    if (result['success']) {
      AppHelpers.showSuccessSnackbar('Girvi closed successfully');
      // loadGirvis();
      // loadStats();
    } else {
      AppHelpers.showErrorSnackbar(result['message']);
    }
  }

  Future<void> deleteGirvi(String id, String girviNo) async {
    final confirmed = await AppHelpers.showConfirmDialog(
      title: 'Delete Girvi',
      message: 'Delete Girvi #$girviNo? This cannot be undone.',
      confirmText: 'Delete',
    );
    if (!confirmed) return;

    AppHelpers.showLoadingDialog();
    final result = await _repository.deleteGirvi(id);
    AppHelpers.hideLoadingDialog();

    if (result['success']) {
      AppHelpers.showSuccessSnackbar('Girvi deleted successfully');
      // loadGirvis();
      // loadStats();
    } else {
      AppHelpers.showErrorSnackbar(result['message']);
    }
  }

  // ── Populate (edit) ───────────────────────────────────────────────────────

  void populateForm(GirviModel girvi) {
    girviNoController.text = girvi.girviNo;
    grossWeightController.text = girvi.grossWeight.toString();
    netWeightController.text = girvi.netWeight.toString();
    loanAmountController.text = girvi.loanAmount.toString();
    notesController.text = girvi.notes ?? '';
    selectedMetalType.value = girvi.metalType;
    selectedDueDate.value = girvi.dueDate;
    selectedCustomerId.value = girvi.customerId;
    selectedCustomerName.value = girvi.customerName;
    selectedCustomerPhone.value = girvi.customerPhone;
    customerSearchController.text = girvi.customerName;
    selectedStatus.value = girvi.status ?? 'ACTIVE';

    // Back-calculate interest percent from stored amount + loan
    if (girvi.loanAmount > 0 && girvi.interestAmount > 0) {
      final pct = (girvi.interestAmount / girvi.loanAmount) * 100;
      interestPercentController.text = pct.toStringAsFixed(2);
    } else {
      interestPercentController.text = '2';
    }

    recalculate();
  }

  // ── Filters ───────────────────────────────────────────────────────────────

  void searchGirvis(String query) {
    searchQuery.value = query;
    // loadGirvis(search: query);
  }

  void applyFilters({String? metalType, String? status}) {
    filterMetalType.value = metalType ?? filterMetalType.value;
    filterStatus.value = status ?? filterStatus.value;
    // loadGirvis();
  }

  void clearFilters() {
    searchQuery.value = '';
    filterMetalType.value = '';
    filterStatus.value = '';
    // loadGirvis();
  }

  // ── Due date ──────────────────────────────────────────────────────────────

  void selectDueDate(DateTime date) => selectedDueDate.value = date;

  // ── Reset form ────────────────────────────────────────────────────────────

  void resetForm() {
    _clearForm();
    // loadNextGirviNo();
  }

  // ── Validation ────────────────────────────────────────────────────────────

  bool _validateForm() {
    formError.value = '';
    if (selectedCustomerId.value.isEmpty) {
      showNoCustomerWarning.value = true;
      formError.value = 'Please select a customer before saving.';
      return false;
    }
    if (netWeightController.text.trim().isEmpty ||
        double.tryParse(netWeightController.text) == null) {
      formError.value = 'Please enter a valid net weight.';
      AppHelpers.showErrorSnackbar(formError.value);
      return false;
    }
    if (loanAmountController.text.trim().isEmpty ||
        double.tryParse(loanAmountController.text) == null) {
      formError.value = 'Please enter a valid loan amount.';
      AppHelpers.showErrorSnackbar(formError.value);
      return false;
    }
    return true;
  }

  void _clearForm() {
    girviNoController.clear();
    customerSearchController.clear();
    grossWeightController.clear();
    deductionController.clear();
    netWeightController.clear();
    loanAmountController.clear();
    interestPercentController.text = '2';
    notesController.clear();
    selectedMetalType.value = 'GOLD';
    selectedStatus.value = 'ACTIVE';
    selectedDueDate.value = null;
    selectedCustomerId.value = '';
    selectedCustomerName.value = '';
    selectedCustomerPhone.value = '';
    customerSearchResults.clear();
    showNoCustomerWarning.value = false;
    formError.value = '';
    totalMetalValue.value = 0;
    monthlyInterest.value = 0;
    selectedMetalPricePerGram.value = 0;
  }

  @override
  void onClose() {
    girviNoController.dispose();
    customerSearchController.dispose();
    grossWeightController.dispose();
    deductionController.dispose();
    netWeightController.dispose();
    loanAmountController.dispose();
    interestPercentController.dispose();
    notesController.dispose();
    super.onClose();
  }
}
