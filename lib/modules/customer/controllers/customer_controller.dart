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

  // ── Basic Info ────────────────────────────────────────────────────────────
  final nameController = TextEditingController();
  final dateOfBirthController = TextEditingController();
  final relationNameController = TextEditingController();

  // ── Contact Details ───────────────────────────────────────────────────────
  final mobileController = TextEditingController();
  final altMobileController = TextEditingController();
  final emailController = TextEditingController();
  final address1Controller = TextEditingController();
  final address2Controller = TextEditingController();
  final locationController = TextEditingController();
  final cityController = TextEditingController();
  final pincodeController = TextEditingController();

  // ── KYC ───────────────────────────────────────────────────────────────────
  final aadharNumberController = TextEditingController();
  final panNumberController = TextEditingController();
  final rationCardController = TextEditingController();
  final otherProofController = TextEditingController();
  final notesController = TextEditingController();

  // ── Observables ───────────────────────────────────────────────────────────
  final RxBool isLoading = false.obs;
  final RxList<CustomerModel> customers = <CustomerModel>[].obs;
  final RxString searchQuery = ''.obs;
  final RxString filterStatus = ''.obs;

  // Form state
  final RxString selectedSex = 'MALE'.obs;
  final RxString selectedRelationType = ''.obs;
  final Rx<DateTime?> selectedDateOfBirth = Rx<DateTime?>(null);
  final RxString nextCustomerCode = 'C-001'.obs;

  // Photo
  final Rx<File?> selectedPhoto = Rx<File?>(null);

  // KYC file uploads
  final Rx<File?> aadharPhotoFile = Rx<File?>(null);
  final Rx<File?> otherProofPhotoFile = Rx<File?>(null);

  final List<String> relationTypes = ['', 'S/O', 'D/O', 'W/O', 'H/O', 'C/O'];

  @override
  void onInit() {
    super.onInit();
    loadCustomers();
  }

  // ── Load / Search ─────────────────────────────────────────────────────────

  Future<void> loadCustomers({String? search, String? status}) async {
    isLoading.value = true;

    final result = await _repository.getCustomers(
      search: search ?? searchQuery.value,
      status: status ?? filterStatus.value,
    );

    isLoading.value = false;

    if (result['success']) {
      customers.value = result['data'];
    } else {
      AppHelpers.showErrorSnackbar(result['message']);
    }
  }

  void searchCustomers(String query) {
    searchQuery.value = query;
    loadCustomers(search: query);
  }

  void applyStatusFilter(String status) {
    filterStatus.value = status;
    loadCustomers();
  }

  // ── Create ────────────────────────────────────────────────────────────────

  Future<void> createCustomer() async {
    if (!_validateInputs()) return;

    isLoading.value = true;

    final customer = CustomerModel(
      name: nameController.text.trim(),
      dateOfBirth: dateOfBirthController.text.isEmpty
          ? null
          : dateOfBirthController.text.trim(),
      relationType: selectedRelationType.value.isEmpty
          ? null
          : selectedRelationType.value,
      relationName: relationNameController.text.isEmpty
          ? null
          : relationNameController.text.trim(),
      sex: selectedSex.value,
      mobile: mobileController.text.trim(),
      altMobile: altMobileController.text.isEmpty
          ? null
          : altMobileController.text.trim(),
      email: emailController.text.isEmpty ? null : emailController.text.trim(),
      address1: address1Controller.text.isEmpty
          ? null
          : address1Controller.text.trim(),
      address2: address2Controller.text.isEmpty
          ? null
          : address2Controller.text.trim(),
      location: locationController.text.isEmpty
          ? null
          : locationController.text.trim(),
      city: cityController.text.isEmpty ? null : cityController.text.trim(),
      pincode: pincodeController.text.isEmpty
          ? null
          : pincodeController.text.trim(),
      aadharNumber: aadharNumberController.text.isEmpty
          ? null
          : aadharNumberController.text.trim(),
      panNumber: panNumberController.text.isEmpty
          ? null
          : panNumberController.text.trim(),
      rationCard: rationCardController.text.isEmpty
          ? null
          : rationCardController.text.trim(),
      otherProof: otherProofController.text.isEmpty
          ? null
          : otherProofController.text.trim(),
      notes: notesController.text.isEmpty ? null : notesController.text.trim(),
      createdAt: DateTime.now(),
    );

    final result = await _repository.createCustomer(
      customer,
      photoPath: selectedPhoto.value?.path,
      aadharPhotoPath: aadharPhotoFile.value?.path,
      otherProofPhotoPath: otherProofPhotoFile.value?.path,
    );

    isLoading.value = false;

    if (result['success']) {
      AppHelpers.showSuccessSnackbar(result['message'] ?? 'Customer saved');
      _clearForm();
      Get.back();
      loadCustomers();
    } else {
      AppHelpers.showErrorSnackbar(result['message']);
    }
  }

  // ── Update ────────────────────────────────────────────────────────────────

  Future<void> updateCustomer(CustomerModel existing) async {
    if (!_validateInputs()) return;

    isLoading.value = true;

    final updated = existing.copyWith(
      name: nameController.text.trim(),
      dateOfBirth: dateOfBirthController.text.isEmpty
          ? null
          : dateOfBirthController.text.trim(),
      relationType: selectedRelationType.value.isEmpty
          ? null
          : selectedRelationType.value,
      relationName: relationNameController.text.isEmpty
          ? null
          : relationNameController.text.trim(),
      sex: selectedSex.value,
      mobile: mobileController.text.trim(),
      altMobile: altMobileController.text.isEmpty
          ? null
          : altMobileController.text.trim(),
      email: emailController.text.isEmpty ? null : emailController.text.trim(),
      address1: address1Controller.text.isEmpty
          ? null
          : address1Controller.text.trim(),
      address2: address2Controller.text.isEmpty
          ? null
          : address2Controller.text.trim(),
      location: locationController.text.isEmpty
          ? null
          : locationController.text.trim(),
      city: cityController.text.isEmpty ? null : cityController.text.trim(),
      pincode: pincodeController.text.isEmpty
          ? null
          : pincodeController.text.trim(),
      aadharNumber: aadharNumberController.text.isEmpty
          ? null
          : aadharNumberController.text.trim(),
      panNumber: panNumberController.text.isEmpty
          ? null
          : panNumberController.text.trim(),
      rationCard: rationCardController.text.isEmpty
          ? null
          : rationCardController.text.trim(),
      otherProof: otherProofController.text.isEmpty
          ? null
          : otherProofController.text.trim(),
      notes: notesController.text.isEmpty ? null : notesController.text.trim(),
      updatedAt: DateTime.now(),
    );

    final result = await _repository.updateCustomer(
      updated,
      photoPath: selectedPhoto.value?.path,
      aadharPhotoPath: aadharPhotoFile.value?.path,
      otherProofPhotoPath: otherProofPhotoFile.value?.path,
    );

    isLoading.value = false;

    if (result['success']) {
      AppHelpers.showSuccessSnackbar(result['message'] ?? 'Customer updated');
      _clearForm();
      Get.back();
      loadCustomers();
    } else {
      AppHelpers.showErrorSnackbar(result['message']);
    }
  }

  // ── Delete ────────────────────────────────────────────────────────────────

  Future<void> deleteCustomer(String id, String name) async {
    final confirmed = await AppHelpers.showConfirmDialog(
      title: 'Delete Customer',
      message: 'Delete $name? This cannot be undone.',
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

  // ── Populate form for edit ────────────────────────────────────────────────

  void populateForm(CustomerModel c) {
    nameController.text = c.name;
    dateOfBirthController.text = c.dateOfBirth ?? '';
    relationNameController.text = c.relationName ?? '';
    mobileController.text = c.mobile;
    altMobileController.text = c.altMobile ?? '';
    emailController.text = c.email ?? '';
    address1Controller.text = c.address1 ?? '';
    address2Controller.text = c.address2 ?? '';
    locationController.text = c.location ?? '';
    cityController.text = c.city ?? '';
    pincodeController.text = c.pincode ?? '';
    aadharNumberController.text = c.aadharNumber ?? '';
    panNumberController.text = c.panNumber ?? '';
    rationCardController.text = c.rationCard ?? '';
    otherProofController.text = c.otherProof ?? '';
    notesController.text = c.notes ?? '';
    selectedSex.value = c.sex;
    selectedRelationType.value = c.relationType ?? '';
    selectedPhoto.value = null;
    aadharPhotoFile.value = null;
    otherProofPhotoFile.value = null;
  }

  // ── Validation ────────────────────────────────────────────────────────────

  bool _validateInputs() {
    if (nameController.text.trim().isEmpty) {
      AppHelpers.showErrorSnackbar('Please enter full name');
      return false;
    }
    if (mobileController.text.trim().isEmpty) {
      AppHelpers.showErrorSnackbar('Please enter mobile number');
      return false;
    }
    if (mobileController.text.trim().length < 10) {
      AppHelpers.showErrorSnackbar('Enter a valid mobile number');
      return false;
    }
    return true;
  }

  // ── Photo ─────────────────────────────────────────────────────────────────

  Future<void> pickPhoto({bool fromCamera = false}) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (image != null) selectedPhoto.value = File(image.path);
    } catch (e) {
      AppHelpers.showErrorSnackbar('Failed to pick image');
    }
  }

  void removePhoto() => selectedPhoto.value = null;

  // ── KYC file pickers ──────────────────────────────────────────────────────

  Future<void> pickAadharPhoto() async {
    try {
      final XFile? file = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (file != null) aadharPhotoFile.value = File(file.path);
    } catch (e) {
      AppHelpers.showErrorSnackbar('Failed to pick aadhar photo');
    }
  }

  Future<void> pickOtherProofPhoto() async {
    try {
      final XFile? file = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (file != null) otherProofPhotoFile.value = File(file.path);
    } catch (e) {
      AppHelpers.showErrorSnackbar('Failed to pick proof photo');
    }
  }

  // ── Gender / Relation ─────────────────────────────────────────────────────

  void selectSex(String sex) => selectedSex.value = sex;

  void selectRelationType(String type) => selectedRelationType.value = type;

  // ── Aadhar formatting ─────────────────────────────────────────────────────

  void formatAadhar(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    final trimmed = digits.substring(
      0,
      digits.length > 12 ? 12 : digits.length,
    );
    final formatted = trimmed.replaceAllMapped(
      RegExp(r'(\d{4})(?=\d)'),
      (m) => '${m[1]} ',
    );
    if (aadharNumberController.text != formatted) {
      aadharNumberController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
  }

  // ── Clear ─────────────────────────────────────────────────────────────────

  void _clearForm() {
    for (final c in [
      nameController,
      dateOfBirthController,
      relationNameController,
      mobileController,
      altMobileController,
      emailController,
      address1Controller,
      address2Controller,
      locationController,
      cityController,
      pincodeController,
      aadharNumberController,
      panNumberController,
      rationCardController,
      otherProofController,
      notesController,
    ]) {
      c.clear();
    }
    selectedSex.value = 'MALE';
    selectedRelationType.value = '';
    selectedDateOfBirth.value = null;
    selectedPhoto.value = null;
    aadharPhotoFile.value = null;
    otherProofPhotoFile.value = null;
  }

  @override
  void onClose() {
    for (final c in [
      nameController,
      dateOfBirthController,
      relationNameController,
      mobileController,
      altMobileController,
      emailController,
      address1Controller,
      address2Controller,
      locationController,
      cityController,
      pincodeController,
      aadharNumberController,
      panNumberController,
      rationCardController,
      otherProofController,
      notesController,
    ]) {
      c.dispose();
    }
    super.onClose();
  }
}
