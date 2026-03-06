import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_constants.dart';
import '../../../data/models/customer_model.dart';
import '../controllers/customer_controller.dart';

class CustomerFormPage extends StatelessWidget {
  const CustomerFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    final CustomerController controller = Get.find<CustomerController>();
    final CustomerModel? existing = Get.arguments as CustomerModel?;
    final bool isEdit = existing != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Customer' : 'Add New Customer'),
        actions: [
          if (!isEdit)
            Obx(
              () => Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Chip(
                  label: Text(
                    controller.nextCustomerCode.value,
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                  backgroundColor: AppColors.primary.withOpacity(0.08),
                  side: BorderSide(color: AppColors.primary.withOpacity(0.3)),
                ),
              ),
            ),
        ],
      ),
      body: Obx(
        () => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ══════════════════════════════════════════════════════════
              // SECTION 1 — BASIC INFORMATION
              // ══════════════════════════════════════════════════════════
              _SectionCard(
                icon: Icons.badge_outlined,
                title: 'Basic Information',
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Photo Zone ─────────────────────────────────
                        Column(
                          children: [
                            _FieldLabel('Customer Photo'),
                            const SizedBox(height: 6),
                            GestureDetector(
                              onTap: () =>
                                  _showPhotoOptions(context, controller),
                              child: Container(
                                width: 100,
                                height: 110,
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                    width: 1.5,
                                    style: BorderStyle.solid,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: controller.selectedPhoto.value != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(9),
                                        child: Image.file(
                                          controller.selectedPhoto.value!,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : (isEdit && existing.photoUrl != null)
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(9),
                                        child: Image.network(
                                          existing.photoUrl!,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              _photoPlaceholder(),
                                        ),
                                      )
                                    : _photoPlaceholder(),
                              ),
                            ),
                            const SizedBox(height: 6),
                            // Photo action buttons
                            SizedBox(
                              width: 100,
                              child: OutlinedButton.icon(
                                onPressed: () =>
                                    _showPhotoOptions(context, controller),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 6,
                                    horizontal: 8,
                                  ),
                                  side: BorderSide(color: Colors.grey.shade300),
                                ),
                                icon: const Icon(Icons.camera_alt, size: 14),
                                label: const Text(
                                  'Photo',
                                  style: TextStyle(fontSize: 11),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),

                        // ── Fields ─────────────────────────────────────
                        Expanded(
                          child: Column(
                            children: [
                              // Full Name
                              _buildField(
                                label: 'Full Name *',
                                child: TextField(
                                  controller: controller.nameController,
                                  decoration: const InputDecoration(
                                    hintText: 'Enter full name',
                                    prefixIcon: Icon(Icons.person_outline),
                                  ),
                                  textCapitalization: TextCapitalization.words,
                                ),
                              ),
                              const SizedBox(height: 12),

                              Row(
                                children: [
                                  // Date of Birth
                                  Expanded(
                                    child: _buildField(
                                      label: 'Date of Birth',
                                      child: InkWell(
                                        onTap: () async {
                                          final date = await showDatePicker(
                                            context: context,
                                            initialDate:
                                                controller
                                                    .selectedDateOfBirth
                                                    .value ??
                                                DateTime(1990),
                                            firstDate: DateTime(1900),
                                            lastDate: DateTime.now(),
                                          );
                                          if (date != null) {
                                            controller
                                                    .selectedDateOfBirth
                                                    .value =
                                                date;
                                            controller
                                                .dateOfBirthController
                                                .text = DateFormat(
                                              'yyyy-MM-dd',
                                            ).format(date);
                                          }
                                        },
                                        child: InputDecorator(
                                          decoration: const InputDecoration(
                                            prefixIcon: Icon(
                                              Icons.calendar_today,
                                            ),
                                            suffixIcon: Icon(
                                              Icons.arrow_drop_down,
                                            ),
                                          ),
                                          child: Text(
                                            controller
                                                        .selectedDateOfBirth
                                                        .value !=
                                                    null
                                                ? DateFormat(
                                                    'dd MMM yyyy',
                                                  ).format(
                                                    controller
                                                        .selectedDateOfBirth
                                                        .value!,
                                                  )
                                                : 'Select DOB',
                                            style: TextStyle(
                                              color:
                                                  controller
                                                          .selectedDateOfBirth
                                                          .value !=
                                                      null
                                                  ? Colors.black87
                                                  : Colors.grey,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Relation row (type + name side by side like blade)
                    _buildField(
                      label: 'Relation',
                      child: Row(
                        children: [
                          // Relation Type dropdown
                          Container(
                            width: 110,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(8),
                                bottomLeft: Radius.circular(8),
                              ),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value:
                                    controller
                                        .selectedRelationType
                                        .value
                                        .isEmpty
                                    ? null
                                    : controller.selectedRelationType.value,
                                hint: const Padding(
                                  padding: EdgeInsets.only(left: 10),
                                  child: Text(
                                    '—',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ),
                                isExpanded: true,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                items: controller.relationTypes.map((t) {
                                  return DropdownMenuItem(
                                    value: t.isEmpty ? null : t,
                                    child: Text(t.isEmpty ? '—' : t),
                                  );
                                }).toList(),
                                onChanged: (v) =>
                                    controller.selectRelationType(v ?? ''),
                              ),
                            ),
                          ),
                          // Relation Name
                          Expanded(
                            child: TextField(
                              controller: controller.relationNameController,
                              decoration: InputDecoration(
                                hintText: 'Relation name',
                                border: OutlineInputBorder(
                                  borderRadius: const BorderRadius.only(
                                    topRight: Radius.circular(8),
                                    bottomRight: Radius.circular(8),
                                  ),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: const BorderRadius.only(
                                    topRight: Radius.circular(8),
                                    bottomRight: Radius.circular(8),
                                  ),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: const BorderRadius.only(
                                    topRight: Radius.circular(8),
                                    bottomRight: Radius.circular(8),
                                  ),
                                  borderSide: BorderSide(
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Gender toggle (like blade: ♂ Male | ♀ Female | ◈ Other)
                    _buildField(
                      label: 'Gender *',
                      child: Row(
                        children: [
                          _GenderBtn(
                            label: '♂  Male',
                            activeClass: 'male',
                            isActive: controller.selectedSex.value == 'MALE',
                            onTap: () => controller.selectSex('MALE'),
                          ),
                          const SizedBox(width: 8),
                          _GenderBtn(
                            label: '♀  Female',
                            activeClass: 'female',
                            isActive: controller.selectedSex.value == 'FEMALE',
                            onTap: () => controller.selectSex('FEMALE'),
                          ),
                          const SizedBox(width: 8),
                          _GenderBtn(
                            label: '◈  Other',
                            activeClass: 'other',
                            isActive: controller.selectedSex.value == 'OTHER',
                            onTap: () => controller.selectSex('OTHER'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ══════════════════════════════════════════════════════════
              // SECTION 2 — CONTACT DETAILS
              // ══════════════════════════════════════════════════════════
              _SectionCard(
                icon: Icons.phone_outlined,
                title: 'Contact Details',
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Mobile (primary)
                        Expanded(
                          child: _buildField(
                            label: 'Mobile Number *',
                            child: TextField(
                              controller: controller.mobileController,
                              decoration: const InputDecoration(
                                hintText: 'Primary mobile',
                                prefixIcon: Icon(Icons.phone),
                              ),
                              keyboardType: TextInputType.phone,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(15),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),

                        // Alt mobile
                        Expanded(
                          child: _buildField(
                            label: 'Alternate Number',
                            child: TextField(
                              controller: controller.altMobileController,
                              decoration: const InputDecoration(
                                hintText: 'Alt mobile',
                                prefixIcon: Icon(Icons.phone_outlined),
                              ),
                              keyboardType: TextInputType.phone,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(15),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Email
                    _buildField(
                      label: 'Email ID',
                      child: TextField(
                        controller: controller.emailController,
                        decoration: const InputDecoration(
                          hintText: 'email@example.com',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Address Line 1
                    _buildField(
                      label: 'Address Line 1',
                      child: TextField(
                        controller: controller.address1Controller,
                        decoration: const InputDecoration(
                          hintText: 'House / Flat No., Street Name',
                          prefixIcon: Icon(Icons.home_outlined),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Address Line 2
                    _buildField(
                      label: 'Address Line 2',
                      child: TextField(
                        controller: controller.address2Controller,
                        decoration: const InputDecoration(
                          hintText: 'Area / Landmark',
                          prefixIcon: Icon(Icons.location_on_outlined),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        // Location / Area
                        Expanded(
                          child: _buildField(
                            label: 'Location / Area',
                            child: TextField(
                              controller: controller.locationController,
                              decoration: const InputDecoration(
                                hintText: 'e.g. Anna Nagar',
                                prefixIcon: Icon(Icons.place_outlined),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),

                        // City
                        Expanded(
                          child: _buildField(
                            label: 'City',
                            child: TextField(
                              controller: controller.cityController,
                              decoration: const InputDecoration(
                                hintText: 'City',
                                prefixIcon: Icon(Icons.location_city_outlined),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),

                        // Pincode
                        Expanded(
                          child: _buildField(
                            label: 'Pincode',
                            child: TextField(
                              controller: controller.pincodeController,
                              decoration: const InputDecoration(
                                hintText: '6-digit PIN',
                                prefixIcon: Icon(Icons.pin_outlined),
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(10),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ══════════════════════════════════════════════════════════
              // SECTION 3 — KYC & IDENTITY DOCUMENTS
              // ══════════════════════════════════════════════════════════
              _SectionCard(
                icon: Icons.shield_outlined,
                title: 'KYC & Identity Documents',
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Aadhar Number
                        Expanded(
                          child: _buildField(
                            label: 'Aadhar Number',
                            child: TextField(
                              controller: controller.aadharNumberController,
                              decoration: const InputDecoration(
                                hintText: 'XXXX XXXX XXXX',
                                prefixIcon: Icon(Icons.credit_card_outlined),
                              ),
                              keyboardType: TextInputType.number,
                              maxLength: 14,
                              buildCounter:
                                  (
                                    _, {
                                    required currentLength,
                                    required isFocused,
                                    required maxLength,
                                  }) => null,
                              onChanged: controller.formatAadhar,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),

                        // PAN Number
                        Expanded(
                          child: _buildField(
                            label: 'PAN Number',
                            child: TextField(
                              controller: controller.panNumberController,
                              decoration: const InputDecoration(
                                hintText: 'ABCDE1234F',
                                prefixIcon: Icon(Icons.article_outlined),
                              ),
                              textCapitalization: TextCapitalization.characters,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(10),
                                UpperCaseTextFormatter(),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),

                        // Ration Card
                        Expanded(
                          child: _buildField(
                            label: 'Ration Card No.',
                            child: TextField(
                              controller: controller.rationCardController,
                              decoration: const InputDecoration(
                                hintText: 'Ration card number',
                                prefixIcon: Icon(Icons.receipt_outlined),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        // Other Proof Type
                        Expanded(
                          child: _buildField(
                            label: 'Other Proof Type',
                            child: TextField(
                              controller: controller.otherProofController,
                              decoration: const InputDecoration(
                                hintText: 'e.g. Passport, Voter ID',
                                prefixIcon: Icon(Icons.description_outlined),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    Row(
                      children: [
                        // Aadhar Photo Upload
                        Expanded(
                          child: _buildField(
                            label: 'Aadhar Photo / PDF',
                            child: _ProofUploadBox(
                              icon: Icons.credit_card,
                              label: 'UPLOAD AADHAR PROOF',
                              file: controller.aadharPhotoFile.value,
                              onTap: controller.pickAadharPhoto,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),

                        // Other Proof Photo Upload
                        Expanded(
                          child: _buildField(
                            label: 'Other Proof Photo',
                            child: _ProofUploadBox(
                              icon: Icons.insert_drive_file_outlined,
                              label: 'UPLOAD OTHER PROOF',
                              file: controller.otherProofPhotoFile.value,
                              onTap: controller.pickOtherProofPhoto,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Notes
                    _buildField(
                      label: 'Notes',
                      child: TextField(
                        controller: controller.notesController,
                        decoration: const InputDecoration(
                          hintText: 'Any additional notes...',
                        ),
                        maxLines: 3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // ── Action Buttons ─────────────────────────────────────────
              Row(
                children: [
                  // Cancel
                  OutlinedButton.icon(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 20,
                      ),
                      side: const BorderSide(color: Colors.grey),
                    ),
                    icon: const Icon(Icons.close, size: 16),
                    label: const Text('Cancel'),
                  ),
                  const SizedBox(width: 10),

                  // Reset (only for new)
                  if (!isEdit) ...[
                    OutlinedButton.icon(
                      onPressed: () {
                        // controller._clearForm();
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 20,
                        ),
                        side: const BorderSide(color: Colors.grey),
                      ),
                      icon: const Icon(Icons.refresh, size: 16),
                      label: const Text('Reset'),
                    ),
                    const SizedBox(width: 10),
                  ],

                  // Save
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: controller.isLoading.value
                          ? null
                          : (isEdit
                                ? () => controller.updateCustomer(existing)
                                : controller.createCustomer),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      icon: controller.isLoading.value
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.person_add),
                      label: Text(
                        isEdit ? 'Update Customer' : 'Save Customer',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // ── Photo Options Sheet ───────────────────────────────────────────────────

  void _showPhotoOptions(BuildContext context, CustomerController controller) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(ctx);
                controller.pickPhoto(fromCamera: false);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Take a Photo'),
              onTap: () {
                Navigator.pop(ctx);
                controller.pickPhoto(fromCamera: true);
              },
            ),
            if (controller.selectedPhoto.value != null)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text(
                  'Remove Photo',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  controller.removePhoto();
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _photoPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(Icons.camera_alt_outlined, size: 32, color: Colors.grey),
        SizedBox(height: 6),
        Text(
          'CLICK TO\nUPLOAD',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 10, color: Colors.grey),
        ),
        SizedBox(height: 3),
        Text(
          'JPG / PNG · Max 3MB',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 9, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildField({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [_FieldLabel(label), child],
    );
  }
}

// ─── Section Card ─────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.icon,
    required this.title,
    required this.child,
  });

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, size: 16, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  title.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                    color: Color(0xFF333333),
                  ),
                ),
              ],
            ),
          ),
          Padding(padding: const EdgeInsets.all(16), child: child),
        ],
      ),
    );
  }
}

// ─── Gender Button ────────────────────────────────────────────────────────────

class _GenderBtn extends StatelessWidget {
  const _GenderBtn({
    required this.label,
    required this.activeClass,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final String activeClass; // 'male', 'female', 'other'
  final bool isActive;
  final VoidCallback onTap;

  Color get _activeColor {
    switch (activeClass) {
      case 'male':
        return const Color(0xFF2980b9);
      case 'female':
        return const Color(0xFFe91e8c);
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? _activeColor.withOpacity(0.1) : Colors.white,
            border: Border.all(
              color: isActive ? _activeColor : Colors.grey.shade300,
              width: isActive ? 1.5 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isActive ? _activeColor : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Proof Upload Box ─────────────────────────────────────────────────────────

class _ProofUploadBox extends StatelessWidget {
  const _ProofUploadBox({
    required this.icon,
    required this.label,
    required this.file,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final dynamic file; // File?
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          border: Border.all(
            color: file != null ? Colors.green.shade400 : Colors.grey.shade300,
            style: BorderStyle.solid,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              file != null ? Icons.check_circle_outline : icon,
              size: 28,
              color: file != null ? Colors.green : Colors.grey,
            ),
            const SizedBox(height: 5),
            Text(
              file != null ? '✓ File Selected' : label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: file != null ? Colors.green : Colors.grey,
                letterSpacing: 0.5,
              ),
            ),
            if (file != null)
              Text(
                file.path.split('/').last,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Field Label ──────────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFF444444),
        ),
      ),
    );
  }
}

// ─── Upper Case Formatter ─────────────────────────────────────────────────────

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}
