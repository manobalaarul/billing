import 'package:flutter/material.dart';

class AppConstants {
  // App Info
  static const String appVersion = '1.0.0';

  // Validation
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 20;
  static const int minPhoneLength = 10;

  // Image
  static const int maxImageSizeInMB = 5;
  static const List<String> allowedImageFormats = ['jpg', 'jpeg', 'png'];

  // Gold Purity Types
  static const List<String> goldPurityTypes = ['24K', '22K', '18K', '14K'];

  // Customer Types
  static const List<String> customerTypes = ['Retail', 'Wholesale', 'VIP'];
}

class AppStrings {
  // Auth
  static const String login = 'Login';
  static const String logout = 'Logout';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String forgotPassword = 'Forgot Password?';

  // Dashboard
  static const String dashboard = 'Dashboard';
  static const String totalCustomers = 'Total Customers';
  static const String totalOrders = 'Total Orders';
  static const String todaysSales = 'Today\'s Sales';
  static const String goldRate = 'Gold Rate';

  // Gold Rate
  static const String goldRateManagement = 'Gold Rate Management';
  static const String addGoldRate = 'Add Gold Rate';
  static const String updateGoldRate = 'Update Gold Rate';
  static const String purity = 'Purity';
  static const String rate = 'Rate';

  // Customer
  static const String customers = 'Customers';
  static const String addCustomer = 'Add Customer';
  static const String updateCustomer = 'Update Customer';
  static const String customerName = 'Customer Name';
  static const String phoneNumber = 'Phone Number';
  static const String address = 'Address';
  static const String customerType = 'Customer Type';
  static const String photo = 'Photo';

  // Common
  static const String save = 'Save';
  static const String cancel = 'Cancel';
  static const String delete = 'Delete';
  static const String edit = 'Edit';
  static const String search = 'Search';
  static const String filter = 'Filter';
  static const String noDataFound = 'No data found';
  static const String loading = 'Loading...';
  static const String error = 'Error';
  static const String success = 'Success';

  // Validation Messages
  static const String fieldRequired = 'This field is required';
  static const String invalidEmail = 'Invalid email address';
  static const String invalidPhone = 'Invalid phone number';
  static const String passwordTooShort = 'Password is too short';
}

class AppColors {
  static const Color primary = Color(0xFFFFD700); // Gold
  static const Color primaryDark = Color(0xFFDAA520);
  static const Color secondary = Color(0xFF2C3E50);
  static const Color accent = Color(0xFFE74C3C);

  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color error = Color(0xFFE74C3C);
  static const Color success = Color(0xFF27AE60);

  static const Color textPrimary = Color(0xFF2C3E50);
  static const Color textSecondary = Color(0xFF7F8C8D);
  static const Color textLight = Color(0xFFBDC3C7);
}
