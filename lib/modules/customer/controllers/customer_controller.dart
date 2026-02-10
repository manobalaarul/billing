import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/utils/app_helpers.dart';
import '../../../../data/models/customer_model.dart';
import '../../../../data/repositories/customer_repository.dart';

class CustomerController extends GetxController {
  final CustomerRepository _repository = CustomerRepository();
  final ImagePicker _imagePicker = ImagePicker();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final notesController = TextEditingController();

  final RxBool isLoading = false.obs;
  final RxList<CustomerModel> customers = <CustomerModel>[].obs;
  final RxString selectedCustomerType = 'Retail'.obs;
  final Rx<File?> selectedImage = Rx<File?>(null);
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadCustomers();
  }

  Future<void> loadCustomers({String? search}) async {
    isLoading.value = true;

    final result = await _repository.getCustomers(search: search);

    isLoading.value = false;

    if (result['success']) {
      customers.value = result['data'];
    } else {
      AppHelpers.showErrorSnackbar(result['message']);
    }
  }

  Future<void> createCustomer() async {
    if (!_validateInputs()) return;

    isLoading.value = true;

    final customer = CustomerModel(
      name: nameController.text.trim(),
      email: emailController.text.trim(),
      phone: phoneController.text.trim(),
      address: addressController.text.trim(),
      customerType: selectedCustomerType.value,
      notes: notesController.text.isEmpty ? null : notesController.text,
      createdAt: DateTime.now(),
    );

    final result = await _repository.createCustomer(
      customer,
      photoPath: selectedImage.value?.path,
    );

    isLoading.value = false;

    if (result['success']) {
      AppHelpers.showSuccessSnackbar(result['message']);
      _clearForm();
      Get.back();
      loadCustomers();
    } else {
      AppHelpers.showErrorSnackbar(result['message']);
    }
  }

  Future<void> updateCustomer(CustomerModel customer) async {
    if (!_validateInputs()) return;

    isLoading.value = true;

    final updatedCustomer = customer.copyWith(
      name: nameController.text.trim(),
      email: emailController.text.trim(),
      phone: phoneController.text.trim(),
      address: addressController.text.trim(),
      customerType: selectedCustomerType.value,
      notes: notesController.text.isEmpty ? null : notesController.text,
      updatedAt: DateTime.now(),
    );

    final result = await _repository.updateCustomer(
      updatedCustomer,
      photoPath: selectedImage.value?.path,
    );

    isLoading.value = false;

    if (result['success']) {
      AppHelpers.showSuccessSnackbar(result['message']);
      _clearForm();
      Get.back();
      loadCustomers();
    } else {
      AppHelpers.showErrorSnackbar(result['message']);
    }
  }

  Future<void> deleteCustomer(String id) async {
    final confirmed = await AppHelpers.showConfirmDialog(
      title: 'Delete Customer',
      message: 'Are you sure you want to delete this customer?',
      confirmText: 'Delete',
    );

    if (!confirmed) return;

    AppHelpers.showLoadingDialog();

    final result = await _repository.deleteCustomer(id);

    AppHelpers.hideLoadingDialog();

    if (result['success']) {
      AppHelpers.showSuccessSnackbar(result['message']);
      loadCustomers();
    } else {
      AppHelpers.showErrorSnackbar(result['message']);
    }
  }

  bool _validateInputs() {
    if (nameController.text.trim().isEmpty) {
      AppHelpers.showErrorSnackbar('Please enter customer name');
      return false;
    }

    if (emailController.text.trim().isEmpty) {
      AppHelpers.showErrorSnackbar('Please enter email');
      return false;
    }

    if (phoneController.text.trim().isEmpty) {
      AppHelpers.showErrorSnackbar('Please enter phone number');
      return false;
    }

    if (addressController.text.trim().isEmpty) {
      AppHelpers.showErrorSnackbar('Please enter address');
      return false;
    }

    return true;
  }

  Future<void> pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        selectedImage.value = File(image.path);
      }
    } catch (e) {
      AppHelpers.showErrorSnackbar('Failed to pick image');
    }
  }

  Future<void> takePhoto() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        selectedImage.value = File(image.path);
      }
    } catch (e) {
      AppHelpers.showErrorSnackbar('Failed to take photo');
    }
  }

  void removeImage() {
    selectedImage.value = null;
  }

  void selectCustomerType(String type) {
    selectedCustomerType.value = type;
  }

  void searchCustomers(String query) {
    searchQuery.value = query;
    loadCustomers(search: query);
  }

  void _clearForm() {
    nameController.clear();
    emailController.clear();
    phoneController.clear();
    addressController.clear();
    notesController.clear();
    selectedCustomerType.value = 'Retail';
    selectedImage.value = null;
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    notesController.dispose();
    super.onClose();
  }
}
