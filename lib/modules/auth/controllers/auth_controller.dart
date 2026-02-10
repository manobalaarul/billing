import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/utils/app_helpers.dart';
import '../../../../data/models/user_model.dart';
import '../../../../data/repositories/auth_repository.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final RxBool isLoading = false.obs;
  final RxBool isPasswordVisible = false.obs;
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);

  @override
  void onInit() {
    super.onInit();
    checkLoginStatus();
  }

  void checkLoginStatus() {
    if (_authRepository.isLoggedIn()) {
      currentUser.value = _authRepository.getCurrentUser();
      Get.offAllNamed(AppRoutes.dashboard);
    }
  }

  Future<void> login() async {
    if (!_validateInputs()) return;

    isLoading.value = true;

    final result = await _authRepository.login(
      email: emailController.text.trim(),
      password: passwordController.text,
    );

    isLoading.value = false;

    if (result['success']) {
      currentUser.value = result['user'];
      AppHelpers.showSuccessSnackbar(result['message']);
      Get.offAllNamed(AppRoutes.dashboard);
    } else {
      AppHelpers.showErrorSnackbar(result['message']);
    }
  }

  bool _validateInputs() {
    if (emailController.text.trim().isEmpty) {
      AppHelpers.showErrorSnackbar('Please enter email');
      return false;
    }

    if (passwordController.text.isEmpty) {
      AppHelpers.showErrorSnackbar('Please enter password');
      return false;
    }

    return true;
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  Future<void> logout() async {
    final confirmed = await AppHelpers.showConfirmDialog(
      title: 'Logout',
      message: 'Are you sure you want to logout?',
      confirmText: 'Logout',
    );

    if (!confirmed) return;

    AppHelpers.showLoadingDialog();

    await _authRepository.logout();

    AppHelpers.hideLoadingDialog();

    currentUser.value = null;
    Get.offAllNamed(AppRoutes.login);
    AppHelpers.showSuccessSnackbar('Logged out successfully');
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
