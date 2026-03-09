import 'package:billing/core/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../data/models/girvi_model.dart';

// ─── Colors ────────────────────────────────────────────────────────────────────
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

class GirviRedemptionPage extends StatefulWidget {
  const GirviRedemptionPage({super.key});

  @override
  State<GirviRedemptionPage> createState() => _GirviRedemptionPageState();
}

class _GirviRedemptionPageState extends State<GirviRedemptionPage> {
  GirviModel? _sourceGirvi;

  // ── Controllers ───────────────────────────────────────────────────────────────
  final _redemptionNoCtrl = TextEditingController();
  final _pledgeNoCtrl = TextEditingController();
  final _pledgedByCtrl = TextEditingController();
  final _releasedByCtrl = TextEditingController();
  final _customerNameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _articleDescCtrl = TextEditingController();
  final _loanAmountCtrl = TextEditingController(text: '0');
  final _interestRateCtrl = TextEditingController(text: '2');
  final _noOfMonthsCtrl = TextEditingController(text: '0');
  final _paymentReceivedCtrl = TextEditingController(text: '0');
  final _interestLessCtrl = TextEditingController(text: '0');
  final _noticeChargeCtrl = TextEditingController(text: '0');
  final _otherChargeCtrl = TextEditingController(text: '0');
  final _deductionCtrl = TextEditingController(text: '0');

  // ── State ─────────────────────────────────────────────────────────────────────
  DateTime _redemptionDate = DateTime.now();
  DateTime? _pledgeDate;
  String _selectedLicensee = 'AP';
  final List<String> _licensees = ['AP', 'TS', 'KA', 'MH', 'TN', 'DL'];
  double _interest = 0;
  double _finalInterest = 0;
  double _total = 0;
  double _receive = 0;
  String _formError = '';

  @override
  void initState() {
    super.initState();
    _sourceGirvi = Get.arguments as GirviModel?;
    _redemptionNoCtrl.text = 'A00414';
    if (_sourceGirvi != null) _prefill(_sourceGirvi!);
    _recalculate();
  }

  void _prefill(GirviModel g) {
    _pledgeNoCtrl.text = g.girviNo;
    _customerNameCtrl.text = g.customerName;
    _loanAmountCtrl.text = g.loanAmount.toString();
    _pledgeDate = g.createdAt;
    if (g.loanAmount > 0 && g.interestAmount > 0) {
      _interestRateCtrl.text = ((g.interestAmount / g.loanAmount) * 100)
          .toStringAsFixed(2);
    }
  }

  @override
  void dispose() {
    for (final c in [
      _redemptionNoCtrl,
      _pledgeNoCtrl,
      _pledgedByCtrl,
      _releasedByCtrl,
      _customerNameCtrl,
      _addressCtrl,
      _articleDescCtrl,
      _loanAmountCtrl,
      _interestRateCtrl,
      _noOfMonthsCtrl,
      _paymentReceivedCtrl,
      _interestLessCtrl,
      _noticeChargeCtrl,
      _otherChargeCtrl,
      _deductionCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _recalculate() {
    final loan = double.tryParse(_loanAmountCtrl.text) ?? 0;
    final rate = double.tryParse(_interestRateCtrl.text) ?? 0;
    final months = double.tryParse(_noOfMonthsCtrl.text) ?? 0;
    final paid = double.tryParse(_paymentReceivedCtrl.text) ?? 0;
    final less = double.tryParse(_interestLessCtrl.text) ?? 0;
    final notice = double.tryParse(_noticeChargeCtrl.text) ?? 0;
    final other = double.tryParse(_otherChargeCtrl.text) ?? 0;
    final ded = double.tryParse(_deductionCtrl.text) ?? 0;
    final interest = (loan * rate * months) / 100;
    final finalInterest = (interest - less + notice + other - ded).clamp(
      0.0,
      double.infinity,
    );
    setState(() {
      _interest = interest;
      _finalInterest = finalInterest;
      _total = loan + finalInterest;
      _receive = (loan + finalInterest) - paid;
    });
  }

  bool _validate() {
    if (_pledgeNoCtrl.text.trim().isEmpty) {
      setState(() => _formError = 'Please enter the Pledge (Girvi) Number.');
      return false;
    }
    if (_customerNameCtrl.text.trim().isEmpty) {
      setState(() => _formError = 'Please enter the customer name.');
      return false;
    }
    setState(() => _formError = '');
    return true;
  }

  void _onSave() {
    if (!_validate()) return;
    debugPrint('Saving redemption: ${_pledgeNoCtrl.text}');
    Get.back();
  }

  void _resetForm() {
    _pledgeNoCtrl.clear();
    _pledgedByCtrl.clear();
    _releasedByCtrl.clear();
    _customerNameCtrl.clear();
    _addressCtrl.clear();
    _articleDescCtrl.clear();
    _loanAmountCtrl.text = '0';
    _interestRateCtrl.text = '2';
    _noOfMonthsCtrl.text = '0';
    _paymentReceivedCtrl.text = '0';
    _interestLessCtrl.text = '0';
    _noticeChargeCtrl.text = '0';
    _otherChargeCtrl.text = '0';
    _deductionCtrl.text = '0';
    setState(() {
      _pledgeDate = null;
      _redemptionDate = DateTime.now();
      _formError = '';
    });
    _recalculate();
  }

  Future<DateTime?> _pickDate({
    DateTime? initial,
    DateTime? first,
    DateTime? last,
  }) => showDatePicker(
    context: context,
    initialDate: initial ?? DateTime.now(),
    firstDate: first ?? DateTime(2000),
    lastDate: last ?? DateTime.now().add(const Duration(days: 1825)),
    builder: (ctx, child) => Theme(
      data: Theme.of(
        ctx,
      ).copyWith(colorScheme: const ColorScheme.light(primary: _kRed)),
      child: child!,
    ),
  );

  // ── BUILD ─────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F5),
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_formError.isNotEmpty) ...[
              _ErrorBanner(_formError),
              const SizedBox(height: 12),
            ],

            // ── 1. Redemption Details ─────────────────────────────────────────
            _Card(
              icon: Icons.receipt_long_outlined,
              title: 'Redemption Details',
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _Field(
                          label: 'Bill Number',
                          child: _InputBox(
                            controller: _redemptionNoCtrl,
                            hint: 'A00414',
                            icon: Icons.tag,
                            readOnly: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _Field(
                          label: 'Redemption Date *',
                          child: _DateBox(
                            date: _redemptionDate,
                            onTap: () async {
                              final d = await _pickDate(
                                initial: _redemptionDate,
                              );
                              if (d != null)
                                setState(() => _redemptionDate = d);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _Field(
                          label: 'Pledge / Girvi No. *',
                          child: _InputBox(
                            controller: _pledgeNoCtrl,
                            hint: 'e.g. A01431',
                            icon: Icons.diamond_outlined,
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _Field(
                          label: 'Licensee',
                          child: _DropBox(
                            value: _selectedLicensee,
                            items: _licensees,
                            onChanged: (v) =>
                                setState(() => _selectedLicensee = v!),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _Field(
                          label: 'Pledged By',
                          child: _InputBox(
                            controller: _pledgedByCtrl,
                            hint: 'Staff name',
                            icon: Icons.person_pin_outlined,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _Field(
                          label: 'Released By',
                          child: _InputBox(
                            controller: _releasedByCtrl,
                            hint: 'Staff name',
                            icon: Icons.how_to_reg_outlined,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── 2. Pledged By / Customer ──────────────────────────────────────
            _Card(
              icon: Icons.person_outline,
              title: 'Pledged By',
              child: Column(
                children: [
                  _Field(
                    label: 'Customer Name',
                    child: _InputBox(
                      controller: _customerNameCtrl,
                      hint: 'Full name of pledger',
                      icon: Icons.person_outline,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _Field(
                    label: 'Address',
                    child: _InputBox(
                      controller: _addressCtrl,
                      hint: 'Full address',
                      icon: Icons.location_on_outlined,
                      maxLines: 2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _Field(
                    label: 'Pledge Date',
                    child: _DateBox(
                      date: _pledgeDate,
                      placeholder: 'Select pledge date',
                      onTap: () async {
                        final d = await _pickDate(
                          initial: _pledgeDate ?? DateTime.now(),
                          last: DateTime.now(),
                        );
                        if (d != null) {
                          final diff = _redemptionDate.difference(d).inDays;
                          _noOfMonthsCtrl.text = (diff / 30)
                              .ceil()
                              .clamp(0, 999)
                              .toString();
                          setState(() => _pledgeDate = d);
                          _recalculate();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── 3. Interest Calculation ───────────────────────────────────────
            _Card(
              icon: Icons.calculate_outlined,
              title: 'Interest Calculation',
              child: Column(
                children: [
                  _IntRow(
                    label: 'Pledge Amount',
                    child: _InputBox(
                      controller: _loanAmountCtrl,
                      hint: '0',
                      icon: Icons.currency_rupee,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onChanged: (_) => _recalculate(),
                      bold: true,
                    ),
                  ),
                  _rowDivider(),
                  _IntRow(
                    label: 'Amount',
                    child: _InputBox(
                      controller: _loanAmountCtrl,
                      hint: '0',
                      icon: Icons.currency_rupee,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onChanged: (_) => _recalculate(),
                      bold: true,
                    ),
                  ),
                  _rowDivider(),

                  _IntRow(
                    label: 'Interest Rate (%)',
                    child: _InputBox(
                      controller: _interestRateCtrl,
                      hint: '2',
                      icon: Icons.percent,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onChanged: (_) => _recalculate(),
                    ),
                  ),
                  _rowDivider(),
                  _IntRow(
                    label: 'No. of Months',
                    child: _InputBox(
                      controller: _noOfMonthsCtrl,
                      hint: '0',
                      icon: Icons.calendar_month_outlined,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => _recalculate(),
                    ),
                  ),
                  _rowDivider(),
                  _IntRow(
                    label: 'Interest',
                    child: _ValueBox(value: '₹ ${_fmt(_interest)}'),
                  ),

                  _bandDivider(),

                  _IntRow(
                    label: 'Payment Received',
                    action: _Chip(label: 'Details', onTap: () {}),
                    child: _InputBox(
                      controller: _paymentReceivedCtrl,
                      hint: '0',
                      icon: Icons.payments_outlined,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onChanged: (_) => _recalculate(),
                    ),
                  ),
                  _rowDivider(),
                  _IntRow(
                    label: 'Interest Less',
                    action: _Chip(label: 'Update', onTap: () {}),
                    child: _InputBox(
                      controller: _interestLessCtrl,
                      hint: '0',
                      icon: Icons.remove_circle_outline,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onChanged: (_) => _recalculate(),
                    ),
                  ),
                  _rowDivider(),
                  _IntRow(
                    label: 'Notice Charge',
                    child: _InputBox(
                      controller: _noticeChargeCtrl,
                      hint: '0',
                      icon: Icons.notifications_outlined,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onChanged: (_) => _recalculate(),
                    ),
                  ),
                  _rowDivider(),
                  _IntRow(
                    label: 'Other Charge',
                    child: _InputBox(
                      controller: _otherChargeCtrl,
                      hint: '0',
                      icon: Icons.add_circle_outline,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onChanged: (_) => _recalculate(),
                    ),
                  ),
                  _rowDivider(),
                  _IntRow(
                    label: 'Deduction',
                    child: _InputBox(
                      controller: _deductionCtrl,
                      hint: '0',
                      icon: Icons.discount_outlined,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onChanged: (_) => _recalculate(),
                    ),
                  ),

                  _bandDivider(),

                  _IntRow(
                    label: 'Final Interest',
                    labelColor: _kRed,
                    child: _ValueBox(value: '₹ ${_fmt(_finalInterest)}'),
                  ),
                  const SizedBox(height: 10),
                  _TotalBanner(
                    label: 'TOTAL',
                    value: '₹ ${_fmt(_total)}',
                    isGreen: false,
                  ),
                  const SizedBox(height: 8),
                  _TotalBanner(
                    label: 'RECEIVE',
                    value: '₹ ${_fmt(_receive)}',
                    isGreen: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── 4. Articles ───────────────────────────────────────────────────
            _Card(
              icon: Icons.description_outlined,
              title: 'Detailed Description of Articles',
              child: _InputBox(
                controller: _articleDescCtrl,
                hint: 'Describe pledged articles (e.g. Gold chain 10g...)',
                maxLines: 4,
              ),
            ),

            const SizedBox(height: 20),

            // ── Buttons ───────────────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _onSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kRed,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                icon: const Icon(
                  Icons.lock_open_outlined,
                  size: 18,
                  color: Colors.white,
                ),
                label: const Text(
                  'Save Redemption',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 46,
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFDDDDDD)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: _kSub),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 46,
                    child: OutlinedButton.icon(
                      onPressed: _resetForm,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFDDDDDD)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(Icons.refresh, size: 16, color: _kSub),
                      label: const Text(
                        'Reset',
                        style: TextStyle(color: _kSub),
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
    );
  }

  // Thin line divider between interest rows
  Widget _rowDivider() =>
      const Divider(height: 14, thickness: 1, color: Color(0xFFF0F0F0));

  // Thick grey band between logical groups
  Widget _bandDivider() => Container(
    height: 8,
    margin: const EdgeInsets.symmetric(vertical: 8),
    decoration: BoxDecoration(
      color: const Color(0xFFF2F3F5),
      borderRadius: BorderRadius.circular(4),
    ),
  );

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
        children: const [
          Text(
            'Redemption',
            style: TextStyle(
              color: _kText,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            'Release pledged article & close loan',
            style: TextStyle(color: _kSub, fontSize: 11),
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
            _redemptionNoCtrl.text.isEmpty ? 'RD—' : _redemptionNoCtrl.text,
            style: const TextStyle(
              color: _kRed,
              fontWeight: FontWeight.w800,
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
}

// ══════════════════════════════════════════════════════════════════════════════
// REUSABLE WIDGETS
// ══════════════════════════════════════════════════════════════════════════════

// ─── _Card ─────────────────────────────────────────────────────────────────────
class _Card extends StatelessWidget {
  const _Card({required this.icon, required this.title, required this.child});
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
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              color: _kBg,
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, size: 15, color: _kRed),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    title.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: Color(0xFF333333),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(padding: const EdgeInsets.all(14), child: child),
        ],
      ),
    );
  }
}

// ─── _Field ────────────────────────────────────────────────────────────────────
class _Field extends StatelessWidget {
  const _Field({required this.label, required this.child});
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
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: _kLabel,
          ),
        ),
        const SizedBox(height: 5),
        child,
      ],
    );
  }
}

// ─── _IntRow ───────────────────────────────────────────────────────────────────
// Uses Expanded(flex) instead of fixed SizedBox widths → no overflow ever.
class _IntRow extends StatelessWidget {
  const _IntRow({
    required this.label,
    required this.child,
    this.action,
    this.labelColor,
  });
  final String label;
  final Widget child;
  final Widget? action;
  final Color? labelColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 5,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: labelColor ?? _kLabel,
              ),
            ),
          ),
          if (action != null) ...[const SizedBox(width: 6), action!],
          const SizedBox(width: 8),
          Expanded(flex: 6, child: child),
        ],
      ),
    );
  }
}

// ─── _TotalBanner ──────────────────────────────────────────────────────────────
class _TotalBanner extends StatelessWidget {
  const _TotalBanner({
    required this.label,
    required this.value,
    required this.isGreen,
  });
  final String label, value;
  final bool isGreen;

  @override
  Widget build(BuildContext context) {
    final color = isGreen ? _kGreen : _kRed;
    final bg = isGreen ? _kGreenLight : _kRedLight;
    final border = isGreen ? _kGreenBorder : _kRedBorder;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: border, width: 1.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.5,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── _InputBox ─────────────────────────────────────────────────────────────────
class _InputBox extends StatelessWidget {
  const _InputBox({
    required this.controller,
    this.hint = '',
    this.icon,
    this.keyboardType,
    this.readOnly = false,
    this.maxLines = 1,
    this.onChanged,
    this.bold = false,
  });
  final TextEditingController controller;
  final String hint;
  final IconData? icon;
  final TextInputType? keyboardType;
  final bool readOnly;
  final int maxLines;
  final ValueChanged<String>? onChanged;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: keyboardType,
      maxLines: maxLines,
      onChanged: onChanged,
      style: TextStyle(
        fontSize: 13,
        fontWeight: bold ? FontWeight.w700 : FontWeight.normal,
        color: _kText,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFBBBBBB), fontSize: 13),
        prefixIcon: icon != null ? Icon(icon, size: 16, color: _kSub) : null,
        filled: readOnly,
        fillColor: const Color(0xFFF5F5F5),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 10,
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

// ─── _DateBox ──────────────────────────────────────────────────────────────────
// Pure GestureDetector + Container: never causes InputDecorator overflow.
class _DateBox extends StatelessWidget {
  const _DateBox({
    required this.onTap,
    this.date,
    this.placeholder = 'Select date',
  });
  final DateTime? date;
  final String placeholder;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFDDDDDD)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, size: 15, color: _kSub),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                date != null
                    ? DateFormat('dd/MM/yyyy').format(date!)
                    : placeholder,
                style: TextStyle(
                  fontSize: 12,
                  color: date != null ? _kText : _kSub,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            const Icon(Icons.arrow_drop_down, size: 18, color: _kSub),
          ],
        ),
      ),
    );
  }
}

// ─── _DropBox ──────────────────────────────────────────────────────────────────
class _DropBox extends StatelessWidget {
  const _DropBox({
    required this.value,
    required this.items,
    required this.onChanged,
  });
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFDDDDDD)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          style: const TextStyle(fontSize: 13, color: _kText),
          icon: const Icon(Icons.arrow_drop_down, size: 18, color: _kSub),
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

// ─── _ValueBox ─────────────────────────────────────────────────────────────────
class _ValueBox extends StatelessWidget {
  const _ValueBox({required this.value, this.isGreen = false});
  final String value;
  final bool isGreen;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: isGreen ? _kGreenLight : _kRedLight,
        border: Border.all(color: isGreen ? _kGreenBorder : _kRedBorder),
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.centerRight,
      child: Text(
        value,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: isGreen ? _kGreen : _kRed,
        ),
      ),
    );
  }
}

// ─── _Chip ─────────────────────────────────────────────────────────────────────
class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: _kRedLight,
          border: Border.all(color: _kRedBorder),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: _kRed,
          ),
        ),
      ),
    );
  }
}

// ─── _ErrorBanner ──────────────────────────────────────────────────────────────
class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner(this.message);
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
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
