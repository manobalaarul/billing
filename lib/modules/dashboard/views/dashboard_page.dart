import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/utils/app_helpers.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    // final DashboardController controller = Get.find<DashboardController>();
    // final AuthController authController = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.dashboard),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            // onPressed: authController.logout,
            onPressed: () {},
          ),
        ],
      ),
      body:
          // Obx(() {
          // if (controller.isLoading.value) {
          //   return const LoadingWidget();
          // }
          // if (controller.errorMessage.value.isNotEmpty) {
          //   return Center(
          //     child: Column(
          //       mainAxisAlignment: MainAxisAlignment.center,
          //       children: [
          //         Text(controller.errorMessage.value),
          //         const SizedBox(height: 16),
          //         ElevatedButton(
          //           onPressed: controller.loadDashboardData,
          //           child: const Text('Retry'),
          //         ),
          //       ],
          //     ),
          //   );
          // }
          // final stats = controller.dashboardStats.value;
          RefreshIndicator(
            // onRefresh: controller.refreshDashboard,
            onRefresh: () async {},
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats Cards
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: [
                      _buildStatCard(
                        context,
                        title: AppStrings.totalCustomers,
                        value: /* stats?.totalCustomers.toString() ?? */ '0',
                        icon: Icons.people,
                        color: Colors.blue,
                      ),
                      _buildStatCard(
                        context,
                        title: AppStrings.totalOrders,
                        value: /* stats?.totalOrders.toString()  ?? */ '0',
                        icon: Icons.shopping_bag,
                        color: Colors.green,
                      ),
                      _buildStatCard(
                        context,
                        title: AppStrings.todaysSales,
                        value: AppHelpers.formatCurrency(
                          /* stats?.todaysSales ?? */ 0,
                        ),
                        icon: Icons.attach_money,
                        color: Colors.orange,
                      ),
                      _buildStatCard(
                        context,
                        title: '${AppStrings.goldRate} (24K)',
                        value: AppHelpers.formatCurrency(
                          /* stats?.currentGoldRate ?? */ 0,
                        ),
                        icon: Icons.trending_up,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Quick Actions
                  Text(
                    'Quick Actions',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: _buildActionCard(
                          context,
                          title: 'Add Customer',
                          icon: Icons.person_add,
                          onTap: () => Get.toNamed(AppRoutes.customerForm),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildActionCard(
                          context,
                          title: 'Update Gold Rate',
                          icon: Icons.update,
                          onTap: () => Get.toNamed(AppRoutes.goldRateForm),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: _buildActionCard(
                          context,
                          title: 'View Customers',
                          icon: Icons.list,
                          onTap: () => Get.toNamed(AppRoutes.customerList),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildActionCard(
                          context,
                          title: 'Reports',
                          icon: Icons.assessment,
                          onTap: () {
                            AppHelpers.showInfoSnackbar('Reports coming soon!');
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Recent Activities
                  // if (stats?.recentActivities.isNotEmpty ?? false) ...[
                  //   Text(
                  //     'Recent Activities',
                  //     style: Theme.of(context).textTheme.titleLarge,
                  //   ),
                  //   const SizedBox(height: 16),

                  //   ListView.separated(
                  //     shrinkWrap: true,
                  //     physics: const NeverScrollableScrollPhysics(),
                  //     itemCount: stats!.recentActivities.length,
                  //     separatorBuilder: (context, index) => const Divider(),
                  //     itemBuilder: (context, index) {
                  //       final activity = stats.recentActivities[index];
                  //       return ListTile(
                  //         leading: CircleAvatar(
                  //           backgroundColor: AppColors.primary.withOpacity(0.2),
                  //           child: Icon(
                  //             _getActivityIcon(activity.type),
                  //             color: AppColors.primary,
                  //           ),
                  //         ),
                  //         title: Text(activity.title),
                  //         subtitle: Text(activity.description),
                  //         trailing: Text(
                  //           AppHelpers.formatTime(activity.timestamp),
                  //           style: Theme.of(context).textTheme.bodySmall,
                  //         ),
                  //       );
                  //     },
                  //   ),
                  // ],
                ],
              ),
            ),
          ),
    );
  }

  // ),
  // );
}

Widget _buildStatCard(
  BuildContext context, {
  required String title,
  required String value,
  required IconData icon,
  required Color color,
}) {
  return Card(
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    ),
  );
}

Widget _buildActionCard(
  BuildContext context, {
  required String title,
  required IconData icon,
  required VoidCallback onTap,
}) {
  return Card(
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 32, color: AppColors.primary),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    ),
  );
}

IconData _getActivityIcon(String type) {
  switch (type) {
    case 'customer':
      return Icons.person;
    case 'order':
      return Icons.shopping_bag;
    case 'payment':
      return Icons.payment;
    default:
      return Icons.info;
  }
}
