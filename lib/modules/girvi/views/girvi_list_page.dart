import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/loading_widget.dart';
import '../controllers/girvi_controller.dart';

class GirviListPage extends StatelessWidget {
  const GirviListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final GirviController controller = Get.find<GirviController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Girvi Register'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // controller.loadGirvis();
              // controller.loadStats();
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed(AppRoutes.girviForm),
        icon: const Icon(Icons.add),
        label: const Text('New Girvi'),
        backgroundColor: AppColors.primary,
      ),
      body: Column(
        children: [
          // Stats + Filters
          Obx(() {
            final s = controller.stats.value;
            return Container(
              color: Colors.grey[50],
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                children: [
                  // Stats Row
                  Row(
                    children: [
                      _StatCard(
                        icon: Icons.diamond,
                        color: Colors.red,
                        label: 'Total',
                        value: s?.totalGirvi.toString() ?? '0',
                      ),
                      const SizedBox(width: 10),
                      _StatCard(
                        icon: Icons.verified_user,
                        color: Colors.green,
                        label: 'Active',
                        value: s?.activeGirvi.toString() ?? '0',
                      ),
                      const SizedBox(width: 10),
                      _StatCard(
                        icon: Icons.currency_rupee,
                        color: Colors.orange,
                        label: 'Loan (Active)',
                        value: s != null
                            ? '₹${(s.totalActiveLoan / 100000).toStringAsFixed(2)}L'
                            : '₹0',
                      ),
                      const SizedBox(width: 10),
                      _StatCard(
                        icon: Icons.lock,
                        color: Colors.blue,
                        label: 'Closed',
                        value: s?.closedGirvi.toString() ?? '0',
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Search + Filter row
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            hintText: 'Search name, mobile or girvi no...',
                            prefixIcon: Icon(Icons.search),
                            isDense: true,
                          ),
                          onChanged: controller.searchGirvis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Metal type filter
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
                              value: controller.filterMetalType.value.isEmpty
                                  ? null
                                  : controller.filterMetalType.value,
                              hint: const Text(
                                'Metal',
                                style: TextStyle(fontSize: 13),
                              ),
                              isDense: true,
                              items: [
                                const DropdownMenuItem(
                                  value: null,
                                  child: Text('All Metals'),
                                ),
                                ...['GOLD', 'SILVER', 'DIAMOND', 'OTHER'].map(
                                  (m) => DropdownMenuItem(
                                    value: m,
                                    child: Text(m),
                                  ),
                                ),
                              ],
                              onChanged: (v) =>
                                  controller.applyFilters(metalType: v ?? ''),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
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
                                DropdownMenuItem(
                                  value: null,
                                  child: Text('All'),
                                ),
                                DropdownMenuItem(
                                  value: 'ACTIVE',
                                  child: Text('Active'),
                                ),
                                DropdownMenuItem(
                                  value: 'CLOSED',
                                  child: Text('Closed'),
                                ),
                              ],
                              onChanged: (v) =>
                                  controller.applyFilters(status: v ?? ''),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            );
          }),

          // List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const LoadingWidget();
              }

              if (controller.girvis.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.diamond_outlined,
                        size: 64,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No girvi records found.',
                        style: Theme.of(
                          context,
                        ).textTheme.bodyLarge?.copyWith(color: Colors.grey),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () => Get.toNamed(AppRoutes.girviForm),
                        child: const Text('Create the first one →'),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.girvis.length,
                itemBuilder: (context, index) {
                  final g = controller.girvis[index];
                  return _GirviCard(girvi: g, controller: controller);
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ─── Stat Card Widget ────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 5),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF2d2d2d),
              ),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Girvi Card Widget ───────────────────────────────────────────────────────

class _GirviCard extends StatelessWidget {
  const _GirviCard({required this.girvi, required this.controller});

  final dynamic girvi;
  final GirviController controller;

  @override
  Widget build(BuildContext context) {
    final metalColor = _metalColor(girvi.metalType);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: Girvi No + Metal badge + Status
            Row(
              children: [
                // Girvi number chip
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    girvi.girviNo,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Metal badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: metalColor.withOpacity(0.12),
                    border: Border.all(color: metalColor.withOpacity(0.4)),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    girvi.metalType,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: metalColor,
                    ),
                  ),
                ),

                const Spacer(),

                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: girvi.isActive
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    border: Border.all(
                      color: girvi.isActive
                          ? Colors.green.shade200
                          : Colors.red.shade200,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    girvi.isActive ? 'Active' : 'Closed',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: girvi.isActive
                          ? const Color(0xFF1a7a4a)
                          : AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Row 2: Customer info
            Row(
              children: [
                const Icon(Icons.person_outline, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text(
                  girvi.customerName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: Color(0xFF2d2d2d),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  girvi.customerPhone,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Row 3: Weight | Loan | Interest
            Row(
              children: [
                _InfoChip(
                  label: 'Net Wt',
                  value: '${girvi.netWeight.toStringAsFixed(3)}g',
                  icon: Icons.scale,
                ),
                const SizedBox(width: 10),
                _InfoChip(
                  label: 'Loan',
                  value: '₹${NumberFormat('#,##0').format(girvi.loanAmount)}',
                  icon: Icons.currency_rupee,
                  highlight: true,
                ),
                const SizedBox(width: 10),
                _InfoChip(
                  label: 'Interest/Mo',
                  value:
                      '₹${NumberFormat('#,##0.##').format(girvi.interestAmount)}',
                  icon: Icons.percent,
                  color: Colors.orange,
                ),
              ],
            ),

            // Due date row (if present)
            if (girvi.dueDate != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'Due: ${DateFormat('dd MMM yyyy').format(girvi.dueDate!)}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(width: 6),
                  if (girvi.isOverdue)
                    _DueTag(label: 'Overdue', color: Colors.red)
                  else if (girvi.isDueSoon)
                    _DueTag(label: 'Due Soon', color: Colors.orange),
                ],
              ),
            ],

            const Divider(height: 18),

            // Actions row
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Edit
                _ActionBtn(
                  icon: Icons.edit_outlined,
                  tooltip: 'Edit',
                  color: Colors.orange,
                  onTap: () {
                    controller.populateForm(girvi);
                    Get.toNamed(AppRoutes.girviForm, arguments: girvi);
                  },
                ),
                const SizedBox(width: 6),

                // Close (only if active)
                if (girvi.isActive) ...[
                  _ActionBtn(
                    icon: Icons.verified_user_outlined,
                    tooltip: 'Close Girvi',
                    color: Colors.green,
                    onTap: () =>
                        controller.closeGirvi(girvi.id!, girvi.girviNo),
                  ),
                  const SizedBox(width: 6),
                ],

                // Delete
                _ActionBtn(
                  icon: Icons.delete_outline,
                  tooltip: 'Delete',
                  color: Colors.red,
                  onTap: () => controller.deleteGirvi(girvi.id!, girvi.girviNo),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _metalColor(String metalType) {
    switch (metalType) {
      case 'GOLD':
        return const Color(0xFFb7860d);
      case 'SILVER':
        return Colors.grey;
      case 'DIAMOND':
        return const Color(0xFF1a7a4a);
      default:
        return Colors.blueGrey;
    }
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.label,
    required this.value,
    required this.icon,
    this.highlight = false,
    this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final bool highlight;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final textColor = highlight
        ? AppColors.primary
        : color ?? const Color(0xFF555555);

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DueTag extends StatelessWidget {
  const _DueTag({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

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
  final VoidCallback onTap;

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
          child: Icon(icon, size: 18, color: color),
        ),
      ),
    );
  }
}
