import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_constants.dart';
import '../controllers/gold_rate_controller.dart';

class GoldRateFormPage extends StatelessWidget {
  const GoldRateFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    final GoldRateController controller = Get.find<GoldRateController>();

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.addGoldRate)),
      body: Obx(
        () => SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Purity Selection
              Text(
                AppStrings.purity,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),

              Wrap(
                spacing: 8,
                children: AppConstants.goldPurityTypes.map((purity) {
                  final isSelected = controller.selectedPurity.value == purity;
                  return ChoiceChip(
                    label: Text(purity),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        controller.selectPurity(purity);
                      }
                    },
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? AppColors.textPrimary : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Rate Field
              TextField(
                controller: controller.rateController,
                decoration: const InputDecoration(
                  labelText: '${AppStrings.rate} (per gram)',
                  prefixText: '₹ ',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              // Date Picker
              InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: controller.selectedDate.value,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );

                  if (date != null) {
                    controller.selectDate(date);
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    DateFormat(
                      'dd MMM yyyy',
                    ).format(controller.selectedDate.value),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Notes Field
              TextField(
                controller: controller.notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (Optional)',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : controller.createGoldRate,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: controller.isLoading.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(
                          AppStrings.save,
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
