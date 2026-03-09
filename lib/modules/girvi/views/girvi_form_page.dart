import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_constants.dart';
import '../../../data/models/girvi_model.dart';

// ─── Colors ───────────────────────────────────────────────────────────────────
const _kRed = Color(0xFFc0392b);
const _kRedLight = Color(0xFFfff5f5);
const _kRedBorder = Color(0xFFf5c6c6);
const _kGreen = Color(0xFF1a7a4a);
const _kGreenLight = Color(0xFFe8f8ef);
const _kGreenBorder = Color(0xFFb2dfdb);
const _kBg = Color(0xFFfafafa);
const _kBorder = Color(0xFFe8e8e8);
const _kText = Color(0xFF2d2d2d);
const _kSub = Color(0xFF888888);
const _kLabel = Color(0xFF444444);

// ─── Hardcoded metal prices — replace with your loaded data ──────────────────
const Map<String, double> _kMetalPrices = {
  'GOLD': 14620,
  'SILVER': 355,
  'PLATINUM': 7804,
  'DIAMOND': 0,
  'OTHER': 0,
};

class GirviFormPage extends StatefulWidget {
  const GirviFormPage({super.key});

  @override
  State<GirviFormPage> createState() => _GirviFormPageState();
}

class _GirviFormPageState extends State<GirviFormPage> {
  late final GirviModel? existing;
  late final bool isEdit;

  // Text controllers
  final _girviNoCtrl = TextEditingController();
  final _customerSearchCtrl = TextEditingController();
  final _grossWeightCtrl = TextEditingController();
  final _deductionCtrl = TextEditingController();
  final _netWeightCtrl = TextEditingController();
  final _loanAmountCtrl = TextEditingController();
  final _interestPctCtrl = TextEditingController(text: '2');
  final _notesCtrl = TextEditingController();

  // Local state
  String _selectedMetal = 'GOLD';
  String _selectedStatus = 'ACTIVE';
  DateTime? _dueDate;

  double _metalPricePerGram = _kMetalPrices['GOLD']!;
  double _totalMetalValue = 0;
  double _monthlyInterest = 0;

  String _selectedCustomerId = '';
  String _selectedCustomerName = '';
  String _selectedCustomerPhone = '';
  bool _showNoCustomerWarning = false;

  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;
  String _formError = '';

  @override
  void initState() {
    super.initState();
    existing = Get.arguments as GirviModel?;
    isEdit = existing != null;
    if (isEdit) {
      _populateFromExisting();
    } else {
      _girviNoCtrl.text = 'GV-001'; // TODO: replace with API call
    }
  }

  void _populateFromExisting() {
    final g = existing!;
    _girviNoCtrl.text = g.girviNo;
    _grossWeightCtrl.text = g.grossWeight.toString();
    _netWeightCtrl.text = g.netWeight.toString();
    _loanAmountCtrl.text = g.loanAmount.toString();
    _notesCtrl.text = g.notes ?? '';
    _selectedMetal = g.metalType;
    _selectedStatus = g.status ?? 'ACTIVE';
    _dueDate = g.dueDate;
    _selectedCustomerId = g.customerId;
    _selectedCustomerName = g.customerName;
    _selectedCustomerPhone = g.customerPhone;
    _customerSearchCtrl.text = g.customerName;
    _metalPricePerGram = _kMetalPrices[g.metalType] ?? 0;
    if (g.loanAmount > 0 && g.interestAmount > 0) {
      _interestPctCtrl.text = ((g.interestAmount / g.loanAmount) * 100)
          .toStringAsFixed(2);
    }
    _recalculate();
  }

  @override
  void dispose() {
    _girviNoCtrl.dispose();
    _customerSearchCtrl.dispose();
    _grossWeightCtrl.dispose();
    _deductionCtrl.dispose();
    _netWeightCtrl.dispose();
    _loanAmountCtrl.dispose();
    _interestPctCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  // ── Calculations ─────────────────────────────────────────────────────────────

  void _recalculate() {
    final gw = double.tryParse(_grossWeightCtrl.text) ?? 0;
    final ded = double.tryParse(_deductionCtrl.text) ?? 0;
    final loan = double.tryParse(_loanAmountCtrl.text) ?? 0;
    final intP = double.tryParse(_interestPctCtrl.text) ?? 0;
    final net = (gw - ded).clamp(0.0, double.infinity);
    setState(() {
      _netWeightCtrl.text = net.toStringAsFixed(3);
      _totalMetalValue = net * _metalPricePerGram;
      _monthlyInterest = (loan * intP) / 100;
    });
  }

  void _selectMetal(String type) {
    setState(() {
      _selectedMetal = type;
      _metalPricePerGram = _kMetalPrices[type] ?? 0;
    });
    _recalculate();
  }

  // ── Customer search ───────────────────────────────────────────────────────────
  // Replace the mock block below with your real API call when ready

  void _onCustomerSearch(String query) {
    if (query.length < 2) {
      setState(() => _searchResults = []);
      return;
    }
    setState(() => _isSearching = true);
    Future.delayed(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      // ── TODO: swap this mock with real API ──────────────────────────────────
      // Example:
      //   final result = await yourRepository.searchCustomers(query);
      //   setState(() { _isSearching = false; _searchResults = ...; });
      // ────────────────────────────────────────────────────────────────────────
      const mockData = [
        {
          'id': '1',
          'name': 'Ravi Kumar',
          'mobile': '9876543210',
          'city': 'Chennai',
          'customer_code': 'CU-001',
        },
        {
          'id': '2',
          'name': 'Priya Devi',
          'mobile': '9123456789',
          'city': 'Puducherry',
          'customer_code': 'CU-002',
        },
        {
          'id': '3',
          'name': 'Suresh Babu',
          'mobile': '9000012345',
          'city': 'Madurai',
          'customer_code': 'CU-003',
        },
      ];
      setState(() {
        _isSearching = false;
        _searchResults = mockData
            .where(
              (c) =>
                  c['name']!.toLowerCase().contains(query.toLowerCase()) ||
                  c['mobile']!.contains(query) ||
                  c['customer_code']!.toLowerCase().contains(
                    query.toLowerCase(),
                  ),
            )
            .cast<Map<String, dynamic>>()
            .toList();
      });
    });
  }

  void _selectCustomer(Map<String, dynamic> cust) {
    setState(() {
      _selectedCustomerId = cust['id']?.toString() ?? '';
      _selectedCustomerName = cust['name'] ?? '';
      _selectedCustomerPhone = cust['mobile'] ?? '';
      _customerSearchCtrl.text = cust['name'] ?? '';
      _searchResults = [];
      _showNoCustomerWarning = false;
    });
  }

  void _clearCustomer() {
    setState(() {
      _selectedCustomerId = '';
      _selectedCustomerName = '';
      _selectedCustomerPhone = '';
      _customerSearchCtrl.clear();
      _searchResults = [];
    });
  }

  // ── Validate & Save ───────────────────────────────────────────────────────────

  bool _validate() {
    if (_selectedCustomerId.isEmpty) {
      setState(() {
        _showNoCustomerWarning = true;
        _formError = 'Please select a customer before saving.';
      });
      return false;
    }
    final net = double.tryParse(_netWeightCtrl.text);
    final loan = double.tryParse(_loanAmountCtrl.text);
    if (net == null || net <= 0) {
      setState(() => _formError = 'Please enter a valid net weight.');
      return false;
    }
    if (loan == null || loan <= 0) {
      setState(() => _formError = 'Please enter a valid loan amount.');
      return false;
    }
    setState(() => _formError = '');
    return true;
  }

  void _onSave() {
    if (!_validate()) return;

    final girvi = GirviModel(
      girviNo: _girviNoCtrl.text.trim(),
      customerId: _selectedCustomerId,
      customerName: _selectedCustomerName,
      customerPhone: _selectedCustomerPhone,
      metalType: _selectedMetal,
      grossWeight: double.tryParse(_grossWeightCtrl.text) ?? 0,
      netWeight: double.tryParse(_netWeightCtrl.text) ?? 0,
      loanAmount: double.tryParse(_loanAmountCtrl.text) ?? 0,
      interestAmount: _monthlyInterest,
      dueDate: _dueDate,
      status: _selectedStatus,
      notes: _notesCtrl.text.isEmpty ? null : _notesCtrl.text,
      createdAt: DateTime.now(),
    );

    // ── TODO: wire to your controller / repository here ──────────────────────
    // final ctrl = Get.find<GirviController>();
    // isEdit ? ctrl.updateGirvi(girvi) : ctrl.createGirvi(girvi);
    // ─────────────────────────────────────────────────────────────────────────
    debugPrint('Saving girvi: ${girvi.toJson()}');
    Get.back();
  }

  void _resetForm() {
    setState(() {
      _girviNoCtrl.clear();
      _customerSearchCtrl.clear();
      _grossWeightCtrl.clear();
      _deductionCtrl.clear();
      _netWeightCtrl.clear();
      _loanAmountCtrl.clear();
      _interestPctCtrl.text = '2';
      _notesCtrl.clear();
      _selectedMetal = 'GOLD';
      _selectedStatus = 'ACTIVE';
      _dueDate = null;
      _selectedCustomerId = '';
      _selectedCustomerName = '';
      _selectedCustomerPhone = '';
      _searchResults = [];
      _showNoCustomerWarning = false;
      _formError = '';
      _metalPricePerGram = _kMetalPrices['GOLD']!;
      _totalMetalValue = 0;
      _monthlyInterest = 0;
    });
  }

  // ── Build ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_formError.isNotEmpty) _ErrorBanner(_formError),

            _SectionCard(
              icon: Icons.diamond_outlined,
              title: 'Girvi Details',
              child: _buildGirviSection(),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              icon: Icons.person_outline,
              title: 'Customer',
              child: _buildCustomerSection(),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              icon: Icons.scale_outlined,
              title: 'Weight & Loan Details',
              child: _buildWeightLoanSection(),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              icon: Icons.notes_outlined,
              title: 'Status & Notes',
              child: _buildStatusNotesSection(),
            ),
            const SizedBox(height: 28),
            _buildActionButtons(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primary,

      elevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: _kText),
        onPressed: () => Get.back(),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isEdit ? 'Edit Girvi' : 'New Girvi',
            style: const TextStyle(
              color: _kText,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            isEdit
                ? 'Update pledge record'
                : 'Create a new pledge / loan record',
            style: const TextStyle(color: _kSub, fontSize: 11),
          ),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 12),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: _kRedLight,
            border: Border.all(color: _kRedBorder),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            _girviNoCtrl.text.isEmpty ? 'GV-—' : _girviNoCtrl.text,
            style: const TextStyle(
              color: _kRed,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(color: const Color(0xFFf1f1f1), height: 1),
      ),
    );
  }

  // Section 1
  Widget _buildGirviSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _FieldGroup(
                label: 'Girvi Number',
                child: _StyledTextField(
                  controller: _girviNoCtrl,
                  readOnly: isEdit,
                  hint: 'e.g. GV-001',
                  prefixIcon: Icons.tag,
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _FieldGroup(
                label: 'Metal Type *',
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: ['GOLD', 'SILVER', 'DIAMOND', 'PLATINUM', 'OTHER']
                      .map((type) {
                        final sel = _selectedMetal == type;
                        final color = _metalColor(type);
                        return GestureDetector(
                          onTap: () => _selectMetal(type),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: sel
                                  ? color.withOpacity(0.12)
                                  : Colors.grey[100],
                              border: Border.all(
                                color: sel ? color : Colors.grey.shade300,
                                width: sel ? 1.5 : 1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              type,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: sel ? color : Colors.grey,
                              ),
                            ),
                          ),
                        );
                      })
                      .toList(),
                ),
              ),
            ),
          ],
        ),
        if (_metalPricePerGram > 0) ...[
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: _kRedLight,
              border: Border.all(color: _kRedBorder),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.show_chart, size: 16, color: _kRed),
                const SizedBox(width: 8),
                const Text(
                  'Market Rate: ',
                  style: TextStyle(fontSize: 12, color: _kSub),
                ),
                Text(
                  '₹ ${_fmt(_metalPricePerGram)} / gram',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: _kRed,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // Section 2
  Widget _buildCustomerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _StyledTextField(
                controller: _customerSearchCtrl,
                hint: 'Search by name, mobile or customer code...',
                prefixIcon: Icons.search,
                onChanged: _onCustomerSearch,
              ),
            ),
            if (_isSearching) ...[
              const SizedBox(width: 8),
              const SizedBox(
                width: 36,
                height: 36,
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: _kRed,
                  ),
                ),
              ),
            ],
          ],
        ),

        if (_searchResults.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: _kBorder),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: _searchResults
                  .map(
                    (cust) => InkWell(
                      onTap: () => _selectCustomer(cust),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Colors.grey.shade100),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    cust['name'] ?? '',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      color: _kText,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '📞 ${cust['mobile'] ?? '—'}${cust['city'] != null ? ' · ${cust['city']}' : ''}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: _kSub,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: _kRedLight,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                cust['customer_code'] ?? '',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: _kRed,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),

        if (_selectedCustomerName.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _kRedLight,
              border: Border.all(color: _kRedBorder, width: 1.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _kRed,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFe8a09a),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _selectedCustomerName.characters.first.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            _selectedCustomerName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: _kText,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _kGreenLight,
                              border: Border.all(color: _kGreenBorder),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              '✓ Selected',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: _kGreen,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '📞 ${_selectedCustomerPhone.isEmpty ? '—' : _selectedCustomerPhone}',
                        style: const TextStyle(fontSize: 13, color: _kSub),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: _clearCustomer,
                  child: const Text(
                    'Change',
                    style: TextStyle(fontSize: 12, color: _kRed),
                  ),
                ),
              ],
            ),
          ),

        if (_showNoCustomerWarning)
          Container(
            margin: const EdgeInsets.only(top: 10),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: _kRedLight,
              border: Border.all(color: _kRedBorder),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.warning_amber_rounded, size: 16, color: _kRed),
                SizedBox(width: 8),
                Text(
                  'Please select a customer before saving.',
                  style: TextStyle(fontSize: 13, color: _kRed),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // Section 3
  Widget _buildWeightLoanSection() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _FieldGroup(
                label: 'Gross Weight (g)',
                child: _StyledTextField(
                  controller: _grossWeightCtrl,
                  hint: '0.000',
                  prefixIcon: Icons.balance,
                  suffixText: 'g',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onChanged: (_) => _recalculate(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _FieldGroup(
                label: 'Deduction (g)',
                child: _StyledTextField(
                  controller: _deductionCtrl,
                  hint: '0.000',
                  prefixIcon: Icons.remove_circle_outline,
                  suffixText: 'g',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onChanged: (_) => _recalculate(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _FieldGroup(
                label: 'Net Weight (g) *',
                child: _StyledTextField(
                  controller: _netWeightCtrl,
                  hint: '0.000',
                  prefixIcon: Icons.scale,
                  suffixText: 'g',
                  readOnly: true,
                  fillColor: const Color(0xFFF5F5F5),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        if (_totalMetalValue > 0) ...[
          _ComputedBox(
            label: 'Total Metal Value',
            value: '₹ ${_fmt(_totalMetalValue)}',
            isBig: true,
          ),
          const SizedBox(height: 14),
        ],

        const Divider(color: Color(0xFFf0f0f0), height: 1),
        const SizedBox(height: 14),

        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: _FieldGroup(
                label: 'Loan Amount (₹) *',
                child: _StyledTextField(
                  controller: _loanAmountCtrl,
                  hint: '0',
                  prefixIcon: Icons.currency_rupee,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => _recalculate(),
                  boldText: true,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _FieldGroup(
                label: 'Interest % (Monthly)',
                child: _StyledTextField(
                  controller: _interestPctCtrl,
                  hint: 'e.g. 2',
                  prefixIcon: Icons.percent,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onChanged: (_) => _recalculate(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ComputedBox(
                label: 'Monthly Interest',
                value: '₹ ${_fmt(_monthlyInterest)}',
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        _FieldGroup(
          label: 'Due Date',
          child: InkWell(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate:
                    _dueDate ?? DateTime.now().add(const Duration(days: 180)),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 3650)),
                builder: (ctx, child) => Theme(
                  data: Theme.of(ctx).copyWith(
                    colorScheme: const ColorScheme.light(primary: _kRed),
                  ),
                  child: child!,
                ),
              );
              if (date != null) setState(() => _dueDate = date);
            },
            child: InputDecorator(
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 11,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
                ),
                prefixIcon: const Icon(
                  Icons.calendar_today,
                  size: 18,
                  color: _kSub,
                ),
                suffixIcon: const Icon(Icons.arrow_drop_down, color: _kSub),
              ),
              child: Text(
                _dueDate != null
                    ? DateFormat('dd MMM yyyy').format(_dueDate!)
                    : 'Select due date (optional)',
                style: TextStyle(
                  color: _dueDate != null ? _kText : _kSub,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
        if (_dueDate != null)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () => setState(() => _dueDate = null),
              style: TextButton.styleFrom(foregroundColor: _kRed),
              child: const Text('Clear date', style: TextStyle(fontSize: 12)),
            ),
          ),
      ],
    );
  }

  // Section 4
  Widget _buildStatusNotesSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: _FieldGroup(
            label: 'Status',
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedStatus = 'ACTIVE'),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: _selectedStatus == 'ACTIVE'
                            ? _kGreenLight
                            : Colors.white,
                        border: Border.all(
                          color: _selectedStatus == 'ACTIVE'
                              ? _kGreen
                              : const Color(0xFFDDDDDD),
                        ),
                        borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(8),
                        ),
                      ),
                      child: Text(
                        '✓ ACTIVE',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _selectedStatus == 'ACTIVE'
                              ? _kGreen
                              : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedStatus = 'CLOSED'),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: _selectedStatus == 'CLOSED'
                            ? _kRedLight
                            : Colors.white,
                        border: Border.all(
                          color: _selectedStatus == 'CLOSED'
                              ? _kRed
                              : const Color(0xFFDDDDDD),
                        ),
                        borderRadius: const BorderRadius.horizontal(
                          right: Radius.circular(8),
                        ),
                      ),
                      child: Text(
                        '✗ CLOSED',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _selectedStatus == 'CLOSED'
                              ? _kRed
                              : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          flex: 2,
          child: _FieldGroup(
            label: 'Remarks / Notes',
            child: _StyledTextField(
              controller: _notesCtrl,
              hint: 'Any additional notes...',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        OutlinedButton(
          onPressed: () => Get.back(),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 22),
            side: const BorderSide(color: Color(0xFFDDDDDD)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('Cancel', style: TextStyle(color: _kSub)),
        ),
        const SizedBox(width: 10),
        if (!isEdit)
          OutlinedButton.icon(
            onPressed: _resetForm,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              side: const BorderSide(color: Color(0xFFDDDDDD)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: const Icon(Icons.refresh, size: 16, color: _kSub),
            label: const Text('Reset', style: TextStyle(color: _kSub)),
          ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _onSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: _kRed,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            icon: Icon(
              isEdit ? Icons.save_outlined : Icons.diamond_outlined,
              size: 18,
            ),
            label: Text(
              isEdit ? 'Update Girvi' : 'Save Girvi',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Reusable widgets ─────────────────────────────────────────────────────────

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
        border: Border.all(color: _kBorder),
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
              color: _kBg,
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, size: 16, color: _kRed),
                const SizedBox(width: 8),
                Text(
                  title.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
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

class _FieldGroup extends StatelessWidget {
  const _FieldGroup({required this.label, required this.child});
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: _kLabel,
          ),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}

class _StyledTextField extends StatelessWidget {
  const _StyledTextField({
    required this.controller,
    this.hint = '',
    this.prefixIcon,
    this.suffixText,
    this.keyboardType,
    this.readOnly = false,
    this.fillColor,
    this.maxLines = 1,
    this.onChanged,
    this.boldText = false,
  });
  final TextEditingController controller;
  final String hint;
  final IconData? prefixIcon;
  final String? suffixText;
  final TextInputType? keyboardType;
  final bool readOnly;
  final Color? fillColor;
  final int maxLines;
  final ValueChanged<String>? onChanged;
  final bool boldText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: keyboardType,
      maxLines: maxLines,
      onChanged: onChanged,
      style: TextStyle(
        fontSize: 14,
        fontWeight: boldText ? FontWeight.w700 : FontWeight.normal,
        color: _kText,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFBBBBBB), fontSize: 14),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, size: 18, color: _kSub)
            : null,
        suffixText: suffixText,
        suffixStyle: const TextStyle(color: _kSub, fontSize: 13),
        filled: readOnly || fillColor != null,
        fillColor: fillColor ?? (readOnly ? const Color(0xFFF5F5F5) : null),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 11,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _kRed, width: 1.5),
        ),
      ),
    );
  }
}

class _ComputedBox extends StatelessWidget {
  const _ComputedBox({
    required this.label,
    required this.value,
    this.isBig = false,
  });
  final String label, value;
  final bool isBig;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFfff5f5), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: _kRedBorder, width: 1.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Color(0xFFAAAAAA),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: isBig ? 22 : 18,
              fontWeight: FontWeight.w800,
              color: _kRed,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner(this.message);
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _kRedLight,
        border: Border.all(color: _kRedBorder),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, size: 16, color: _kRed),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(fontSize: 13, color: _kRed),
            ),
          ),
        ],
      ),
    );
  }
}

String _fmt(double n) => n
    .toStringAsFixed(2)
    .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+\.)'), (m) => '${m[1]},');

Color _metalColor(String type) {
  switch (type) {
    case 'GOLD':
      return const Color(0xFFb7860d);
    case 'SILVER':
      return Colors.grey;
    case 'DIAMOND':
      return const Color(0xFF1a7a4a);
    case 'PLATINUM':
      return const Color(0xFF7c5cbf);
    default:
      return Colors.blueGrey;
  }
}
