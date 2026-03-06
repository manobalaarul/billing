import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../modules/auth/controllers/auth_controller.dart';
import '../constants/app_constants.dart';
import '../routes/app_routes.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    return Drawer(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
      child: SafeArea(
        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              _buildHeader(context),

              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _buildDrawerItem(
                      icon: Icons.dashboard,
                      title: AppStrings.dashboard,
                      route: AppRoutes.dashboard,
                    ),
                    _buildDrawerItem(
                      icon: Icons.people,
                      title: 'Customers',
                      route: AppRoutes.customerList,
                    ),
                    _buildDrawerItem(
                      icon: Icons.balance,
                      title: 'Pledge',
                      route: AppRoutes.girviForm,
                    ),
                    _buildDrawerItem(
                      icon: Icons.money,
                      title: 'Redeem',
                      route: AppRoutes.customerList,
                    ),
                    _buildDrawerItem(
                      icon: Icons.offline_pin_sharp,
                      title: 'Part Payment',
                      route: AppRoutes.goldRateForm,
                    ),
                    _buildDrawerItem(
                      icon: Icons.redeem,
                      title: 'Voucher',
                      route: AppRoutes.goldRateForm,
                    ),
                    _buildDrawerItem(
                      icon: Icons.currency_rupee,
                      title: 'Bank Master',
                      route: AppRoutes.goldRateForm,
                    ),
                    _buildDrawerItem(
                      icon: Icons.cases_outlined,
                      title: 'Bank / Locker',
                      route: AppRoutes.goldRateForm,
                    ),
                    _buildDrawerItem(
                      icon: Icons.cases,
                      title: 'Bank Release',
                      route: AppRoutes.goldRateForm,
                    ),

                    _buildDrawerItem(
                      icon: Icons.document_scanner,
                      title: 'Reports',
                      route: AppRoutes.goldRateForm,
                    ),
                    _buildDrawerItem(
                      icon: Icons.calendar_month,
                      title: 'Day Book',
                      route: AppRoutes.goldRateForm,
                    ),
                    _buildDrawerItem(
                      icon: Icons.settings,
                      title: 'Settings',
                      route: AppRoutes.goldRateForm,
                    ),
                    _buildDrawerItem(
                      icon: Icons.print,
                      title: 'Prints',
                      route: AppRoutes.goldRateForm,
                    ),

                    const Divider(),

                    ListTile(
                      leading: const Icon(Icons.logout, color: Colors.red),
                      title: const Text('Logout'),
                      onTap: () {
                        Get.back();
                        authController.logout();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Theme.of(context).primaryColor,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(
                radius: 30,
                child: Icon(Icons.person, size: 30),
              ),
              const SizedBox(height: 12),
              Text(
                'Welcome',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 4),
              Text(
                'Admin User',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required String route,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Get.back();

        if (Get.currentRoute != route) {
          Get.toNamed(route);
        }
      },
    );
  }
}
