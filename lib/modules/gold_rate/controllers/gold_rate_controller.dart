import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/utils/app_helpers.dart';
import '../../../../data/models/gold_rate_model.dart';
import '../../../../data/repositories/gold_rate_repository.dart';

class GoldRateController extends GetxController {
  final GoldRateRepository _repository = GoldRateRepository();

  final purityController = TextEditingController();
  final rateController = TextEditingController();
  final notesController = TextEditingController();

  final RxBool isLoading = false.obs;
  final RxList<GoldRateModel> goldRates = <GoldRateModel>[].obs;
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final RxString selectedPurity = '24K'.obs;

  @override
  void onInit() {
    super.onInit();
    loadGoldRates();
  }

  Future<void> loadGoldRates() async {
    isLoading.value = true;

    final result = await _repository.getGoldRates();

    isLoading.value = false;

    if (result['success']) {
      goldRates.value = result['data'];
    } else {
      AppHelpers.showErrorSnackbar(result['message']);
    }
  }

  Future<void> createGoldRate() async {
    if (!_validateInputs()) return;

    isLoading.value = true;

    final goldRate = GoldRateModel(
      purity: selectedPurity.value,
      rate: double.parse(rateController.text),
      date: selectedDate.value,
      notes: notesController.text.isEmpty ? null : notesController.text,
      createdAt: DateTime.now(),
    );

    final result = await _repository.createGoldRate(goldRate);

    isLoading.value = false;

    if (result['success']) {
      AppHelpers.showSuccessSnackbar(result['message']);
      _clearForm();
      Get.back();
      loadGoldRates();
    } else {
      AppHelpers.showErrorSnackbar(result['message']);
    }
  }

  bool _validateInputs() {
    if (rateController.text.isEmpty) {
      AppHelpers.showErrorSnackbar('Please enter rate');
      return false;
    }

    if (double.tryParse(rateController.text) == null) {
      AppHelpers.showErrorSnackbar('Please enter valid rate');
      return false;
    }

    return true;
  }

  void _clearForm() {
    rateController.clear();
    notesController.clear();
    selectedDate.value = DateTime.now();
    selectedPurity.value = '24K';
  }

  void selectDate(DateTime date) {
    selectedDate.value = date;
  }

  void selectPurity(String purity) {
    selectedPurity.value = purity;
  }

  @override
  void onClose() {
    purityController.dispose();
    rateController.dispose();
    notesController.dispose();
    super.onClose();
  }
}
