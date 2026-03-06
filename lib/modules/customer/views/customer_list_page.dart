import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../data/models/customer_model.dart';
import '../controllers/customer_controller.dart';

class CustomerListPage extends StatelessWidget {
  const CustomerListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final CustomerController controller = Get.find<CustomerController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.loadCustomers(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed(AppRoutes.customerForm),
        icon: const Icon(Icons.person_add),
        label: const Text('Add Customer'),
        backgroundColor: AppColors.primary,
      ),
      body: Column(
        children: [
          // ── Search + Filter Bar ──────────────────────────────────────
          Container(
            color: Colors.grey[50],
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search by name, mobile or code...',
                      prefixIcon: Icon(Icons.search),
                      isDense: true,
                    ),
                    onChanged: controller.searchCustomers,
                  ),
                ),
                const SizedBox(width: 10),

                // Status filter
                Obx(
                  () => DropdownButtonHideUnderline(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white,
                      ),
                      child: DropdownButton<String>(
                        value: controller.filterStatus.value.isEmpty
                            ? null
                            : controller.filterStatus.value,
                        hint: const Text(
                          'Status',
                          style: TextStyle(fontSize: 13),
                        ),
                        isDense: true,
                        items: const [
                          DropdownMenuItem(value: null, child: Text('All')),
                          DropdownMenuItem(value: '1', child: Text('Active')),
                          DropdownMenuItem(value: '0', child: Text('Inactive')),
                        ],
                        onChanged: (v) => controller.applyStatusFilter(v ?? ''),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Customer List ────────────────────────────────────────────
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const LoadingWidget();
              }

              if (controller.customers.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.person_off_outlined,
                        size: 64,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No customers found.',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () => Get.toNamed(AppRoutes.customerForm),
                        child: const Text('Add the first one →'),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                itemCount: controller.customers.length,
                itemBuilder: (context, index) {
                  final c = controller.customers[index];
                  return _CustomerCard(customer: c, controller: controller);
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ─── Customer Card ────────────────────────────────────────────────────────────

class _CustomerCard extends StatelessWidget {
  const _CustomerCard({required this.customer, required this.controller});

  final CustomerModel customer;
  final CustomerController controller;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Row 1: Avatar + Name + Code + Status ──────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                _Avatar(customer: customer),
                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name
                      Text(
                        customer.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2d2d2d),
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Customer Code chip + Relation
                      Row(
                        children: [
                          if (customer.customerCode != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                customer.customerCode!,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          if (customer.relationType != null &&
                              customer.relationName != null) ...[
                            const SizedBox(width: 6),
                            Text(
                              '${customer.relationType} ${customer.relationName}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // Status badge
                _StatusBadge(isActive: customer.isActive),
              ],
            ),
            const SizedBox(height: 10),

            // ── Row 2: Info chips ──────────────────────────────────────
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                // Mobile
                _InfoItem(
                  icon: Icons.phone_outlined,
                  value: customer.mobile,
                  bold: true,
                ),

                // Alt mobile
                if (customer.altMobile != null &&
                    customer.altMobile!.isNotEmpty)
                  _InfoItem(
                    icon: Icons.phone_outlined,
                    value: customer.altMobile!,
                    color: Colors.grey,
                  ),

                // City
                if (customer.city != null && customer.city!.isNotEmpty)
                  _InfoItem(
                    icon: Icons.location_city_outlined,
                    value: customer.city!,
                  ),

                // Aadhar masked
                if (customer.aadharNumber != null &&
                    customer.aadharNumber!.isNotEmpty)
                  _InfoItem(
                    icon: Icons.credit_card_outlined,
                    value: customer.maskedAadhar,
                    mono: true,
                  ),

                // Joined date
                if (customer.createdAt != null)
                  _InfoItem(
                    icon: Icons.calendar_today_outlined,
                    value: DateFormat(
                      'dd MMM yyyy',
                    ).format(customer.createdAt!),
                    color: Colors.grey,
                  ),
              ],
            ),
            const Divider(height: 18),

            // ── Actions Row ────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Edit
                _ActionBtn(
                  icon: Icons.edit_outlined,
                  tooltip: 'Edit',
                  color: Colors.orange,
                  onTap: () {
                    controller.populateForm(customer);
                    Get.toNamed(AppRoutes.customerForm, arguments: customer);
                  },
                ),
                const SizedBox(width: 6),

                // New Girvi
                _ActionBtn(
                  icon: Icons.diamond_outlined,
                  tooltip: 'New Girvi',
                  color: Colors.blue,
                  onTap: () => Get.toNamed(
                    AppRoutes.girviForm,
                    parameters: {'customer_id': customer.id ?? ''},
                  ),
                ),
                const SizedBox(width: 6),

                // Delete
                _ActionBtn(
                  icon: Icons.delete_outline,
                  tooltip: 'Delete',
                  color: Colors.red,
                  onTap: () => customer.id != null
                      ? controller.deleteCustomer(customer.id!, customer.name)
                      : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Avatar ───────────────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  const _Avatar({required this.customer});
  final CustomerModel customer;

  @override
  Widget build(BuildContext context) {
    if (customer.photoUrl != null && customer.photoUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: 24,
        backgroundImage: NetworkImage(customer.photoUrl!),
      );
    }
    return CircleAvatar(
      radius: 24,
      backgroundColor: AppColors.primary,
      child: Text(
        customer.name.isNotEmpty ? customer.name[0].toUpperCase() : '?',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 16,
        ),
      ),
    );
  }
}

// ─── Status Badge ─────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.isActive});
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: isActive
            ? Colors.green.withOpacity(0.1)
            : Colors.red.withOpacity(0.1),
        border: Border.all(
          color: isActive ? Colors.green.shade200 : Colors.red.shade200,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isActive ? 'Active' : 'Inactive',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: isActive ? const Color(0xFF1a7a4a) : const Color(0xFFc0392b),
        ),
      ),
    );
  }
}

// ─── Info Item ────────────────────────────────────────────────────────────────

class _InfoItem extends StatelessWidget {
  const _InfoItem({
    required this.icon,
    required this.value,
    this.bold = false,
    this.mono = false,
    this.color,
  });

  final IconData icon;
  final String value;
  final bool bold;
  final bool mono;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: Colors.grey),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
            fontFamily: mono ? 'monospace' : null,
            color: color ?? const Color(0xFF333333),
          ),
        ),
      ],
    );
  }
}

// ─── Action Button ────────────────────────────────────────────────────────────

class _ActionBtn extends StatelessWidget {
  const _ActionBtn({
    required this.icon,
    required this.tooltip,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(7),
        child: Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(7),
          ),
          child: Icon(icon, size: 17, color: color),
        ),
      ),
    );
  }
}
