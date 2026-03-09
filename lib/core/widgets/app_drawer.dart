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

                    // ── Pledge expandable section ──
                    _buildExpandableDrawerItem(
                      icon: Icons.balance,
                      title: 'Pledge',
                      children: [
                        _buildSubItem(
                          icon: Icons.add_circle_outline,
                          title: 'Pledge',
                          route: AppRoutes.girviForm,
                        ),
                        _buildSubItem(
                          icon: Icons.history,
                          title: 'Old Pledge',
                          route: AppRoutes.girviForm,
                        ),
                        _buildSubItem(
                          icon: Icons.edit,
                          title: 'Pledge Edit',
                          route: AppRoutes.girviForm,
                        ),
                        _buildSubItem(
                          icon: Icons.receipt_long,
                          title: 'Rebill',
                          route: AppRoutes.girviForm,
                        ),
                        _buildSubItem(
                          icon: Icons.delete_outline,
                          title: 'Delete Pledge',
                          route: AppRoutes.girviForm,
                        ),
                        _buildSubItem(
                          icon: Icons.bar_chart,
                          title: 'Pledge Report',
                          route: AppRoutes.girviForm,
                        ),
                        _buildSubItem(
                          icon: Icons.menu_book,
                          title: 'Ledger',
                          route: AppRoutes.girviForm,
                        ),
                        _buildSubItem(
                          icon: Icons.money_off,
                          title: 'Pledge in Loss',
                          route: AppRoutes.girviForm,
                        ),
                        _buildSubItem(
                          icon: Icons.notifications_active_outlined,
                          title: 'Notice',
                          route: AppRoutes.girviForm,
                        ),
                        _buildSubItem(
                          icon: Icons.today,
                          title: 'Day Report',
                          route: AppRoutes.girviForm,
                        ),
                      ],
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

                    // ── Bank expandable section ──
                    _buildExpandableDrawerItem(
                      icon: Icons.account_balance,
                      title: 'Bank',
                      children: [
                        _buildSubItem(
                          icon: Icons.cases_outlined,
                          title: 'Potli Master',
                          route: AppRoutes.goldRateForm,
                        ),
                        _buildSubItem(
                          icon: Icons.lock_outline,
                          title: 'Potli Pledge',
                          route: AppRoutes.goldRateForm,
                        ),
                        _buildSubItem(
                          icon: Icons.lock_open,
                          title: 'Bank and Potli Release',
                          route: AppRoutes.goldRateForm,
                        ),
                        _buildSubItem(
                          icon: Icons.summarize_outlined,
                          title: 'Bank and Potli Report',
                          route: AppRoutes.goldRateForm,
                        ),
                      ],
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

  /// Expandable section with a header tile and indented sub-items.
  Widget _buildExpandableDrawerItem({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return ExpansionTile(
      leading: Icon(icon),
      title: Text(title),
      childrenPadding: const EdgeInsets.only(left: 16),
      tilePadding: const EdgeInsets.symmetric(horizontal: 16),
      children: children,
    );
  }

  /// Indented sub-item used inside an expandable section.
  Widget _buildSubItem({
    required IconData icon,
    required String title,
    required String route,
  }) {
    return ListTile(
      dense: true,
      leading: Icon(icon, size: 20),
      title: Text(title, style: const TextStyle(fontSize: 14)),
      onTap: () {
        Get.back();
        if (Get.currentRoute != route) {
          Get.toNamed(route);
        }
      },
    );
  }
}
