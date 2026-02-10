import 'package:get/get.dart';

import '../../modules/auth/bindings/auth_binding.dart';
import '../../modules/auth/views/login_page.dart';
import '../../modules/customer/bindings/customer_binding.dart';
import '../../modules/customer/views/customer_form_page.dart';
import '../../modules/customer/views/customer_list_page.dart';
import '../../modules/dashboard/bindings/dashboard_binding.dart';
import '../../modules/dashboard/views/dashboard_page.dart';
import '../../modules/gold_rate/bindings/gold_rate_binding.dart';
import '../../modules/gold_rate/views/gold_rate_form_page.dart';

class AppRoutes {
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String goldRateForm = '/gold-rate-form';
  static const String customerForm = '/customer-form';
  static const String customerList = '/customer-list';

  static final routes = [
    GetPage(name: login, page: () => const LoginPage(), binding: AuthBinding()),
    GetPage(
      name: dashboard,
      page: () => const DashboardPage(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: goldRateForm,
      page: () => const GoldRateFormPage(),
      binding: GoldRateBinding(),
    ),
    GetPage(
      name: customerForm,
      page: () => const CustomerFormPage(),
      binding: CustomerBinding(),
    ),
    GetPage(
      name: customerList,
      page: () => const CustomerListPage(),
      binding: CustomerBinding(),
    ),
  ];

  static String getInitialRoute() {
    // Check if user is logged in
    return dashboard; // Default to login
  }
}
