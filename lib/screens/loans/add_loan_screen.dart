import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../core/utils/format_utils.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/loans_provider.dart';
import '../../core/utils/validation_utils.dart';
import '../../providers/settings_provider.dart';
import '../../models/loan_model.dart';
import '../../services/notification_service.dart';
import '../../l10n/app_localizations.dart';

class AddLoanScreen extends StatefulWidget {
  final LoanModel? existingLoan;
  const AddLoanScreen({super.key, this.existingLoan});

  @override
  State<AddLoanScreen> createState() => _AddLoanScreenState();
}

class _AddLoanScreenState extends State<AddLoanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _profitCtrl = TextEditingController();
  final _cardValueCtrl = TextEditingController();
  final _cardCountCtrl = TextEditingController();

  DateTime _loanDate = DateTime.now();
  String _durationLabel = '30 يوم'; // Stable key
  String _cardCompany = 'موريتل'; // Stable key
  String _cardCategory = '10'; // Stable key or category
  String _profitType = AppConstants.profitTypePercentage;
  bool _isLoading = false;
  bool _customCardValue = false;

  double get _cardValue {
    if (_customCardValue) {
      return double.tryParse(_cardValueCtrl.text) ?? 0;
    }
    return double.tryParse(_cardCategory) ?? 0;
  }

  double get _cardCount => double.tryParse(_cardCountCtrl.text) ?? 0;

  double get _totalAmount => _cardValue * _cardCount;

  double get _profitAmount {
    final pv = double.tryParse(_profitCtrl.text) ?? 0;
    if (_profitType == AppConstants.profitTypePercentage) {
      return _totalAmount * pv / 100;
    }
    return pv;
  }

  double get _finalAmount => _totalAmount + _profitAmount;

  DateTime get _dueDate {
    final days = AppConstants.loanDurations[_durationLabel] ?? 7;
    return _loanDate.add(Duration(days: days));
  }

  @override
  void initState() {
    super.initState();
    final loan = widget.existingLoan;
    final settings = context.read<SettingsProvider>();

    if (loan != null) {
      _nameCtrl.text = loan.borrowerName;
      _phoneCtrl.text = loan.phoneNumber;
      _notesCtrl.text = loan.notes ?? '';
      _profitCtrl.text = loan.profitValue.toString();
      _durationLabel = loan.durationLabel;
      _cardCompany = loan.cardCompany;
      _loanDate = loan.loanDate;
      _profitType = loan.profitType;
      _cardCountCtrl.text = loan.cardCount.toString();
      _customCardValue =
          !AppConstants.cardCategories.contains(loan.cardCategory);
      if (_customCardValue) {
        _cardValueCtrl.text = loan.cardValue.toString();
        _cardCategory = 'أخرى';
      } else {
        _cardCategory = loan.cardCategory;
      }
    } else {
      _profitCtrl.text = settings.defaultProfitValue.toString();
      _profitType = settings.defaultProfitType;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _notesCtrl.dispose();
    _profitCtrl.dispose();
    _cardValueCtrl.dispose();
    _cardCountCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_cardValue <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.invalidCardValue)),
      );
      return;
    }

    setState(() => _isLoading = true);
    final l10n = AppLocalizations.of(context)!;
    final userId = context.read<AuthProvider>().effectiveUserId;
    final profitValue = double.tryParse(_profitCtrl.text) ?? 0;
    final cardValue = _cardValue;
    final cardCount = int.tryParse(_cardCountCtrl.text) ?? 1;

    final loan = LoanModel(
      id: widget.existingLoan?.id,
      userId: userId,
      borrowerName: _nameCtrl.text.trim(),
      phoneNumber: _phoneCtrl.text.trim(),
      loanDate: _loanDate,
      dueDate: _dueDate,
      durationLabel: _durationLabel,
      durationDays: AppConstants.loanDurations[_durationLabel] ?? 7,
      cardCompany: _cardCompany,
      cardCategory: _customCardValue ? _cardValueCtrl.text : _cardCategory,
      cardValue: cardValue,
      cardCount: cardCount,
      profitType: _profitType,
      profitValue: profitValue,
      totalAmount: _totalAmount,
      amountWithProfit: _finalAmount,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      status: widget.existingLoan?.status ?? AppConstants.statusActive,
    );

    // bool success; // This variable is removed

    final messenger = ScaffoldMessenger.of(context);

    if (widget.existingLoan != null) {
      final success = await context.read<LoansProvider>().updateLoan(loan);
      if (!mounted) return;
      if (success) {
        // Reschedule notifications
        await NotificationService().scheduleLoanNotifications(
          loan: loan,
          warningTitle: l10n.loanWarningTitle,
          warningBody: l10n.loanWarningBody(
              loan.borrowerName, loan.amountWithProfit.toStringAsFixed(0)),
          dueTitle: l10n.loanDueTitle,
          dueBody: l10n.loanDueBody(
              loan.borrowerName, loan.amountWithProfit.toStringAsFixed(0)),
        );
        if (!mounted) return;
        Navigator.pop(context);
        messenger.showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.loanUpdated),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } else {
      final newId = await context.read<LoansProvider>().addLoan(loan);
      if (!mounted) return;
      if (newId != null) {
        // Schedule notifications with the corrected ID from DB
        final createdLoan = loan.copyWith(id: newId);
        await NotificationService().scheduleLoanNotifications(
          loan: createdLoan,
          warningTitle: l10n.loanWarningTitle,
          warningBody: l10n.loanWarningBody(createdLoan.borrowerName,
              createdLoan.amountWithProfit.toStringAsFixed(0)),
          dueTitle: l10n.loanDueTitle,
          dueBody: l10n.loanDueBody(createdLoan.borrowerName,
              createdLoan.amountWithProfit.toStringAsFixed(0)),
        );
        if (!mounted) return;
        Navigator.pop(context);
        messenger.showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.loanAdded),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingLoan == null ? l10n.addLoan : l10n.editLoan),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16.w),
          children: [
            _SectionHeader(
                title: l10n.borrowerInfo, icon: Icons.person_rounded),
            _buildCard(children: [
              _buildField(
                controller: _nameCtrl,
                label: l10n.borrowerName,
                icon: Icons.person_outline,
                validator: (v) => v!.isEmpty ? l10n.nameRequired : null,
              ),
              const SizedBox(height: 12),
              _buildField(
                controller: _phoneCtrl,
                label: l10n.phoneNumber,
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (v) => ValidationUtils.validatePhone(
                  v,
                  l10n.phoneRequired,
                  l10n.invalidPhoneNumber,
                ),
              ),
            ]),
            const SizedBox(height: 16),
            _SectionHeader(
                title: l10n.loanDetails, icon: Icons.credit_card_rounded),
            _buildCard(children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today_rounded,
                    color: AppColors.primary),
                title: Text(l10n.loanDate),
                trailing: Text(
                  FormatUtils.formatDate(_loanDate, 'd/M/y',
                      locale: Localizations.localeOf(context).languageCode),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _loanDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  if (date != null) setState(() => _loanDate = date);
                },
              ),
              const Divider(),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading:
                    const Icon(Icons.timer_outlined, color: AppColors.primary),
                title: Text(l10n.loanDuration),
                trailing: DropdownButton<String>(
                  value: _durationLabel,
                  underline: const SizedBox(),
                  items: (() {
                    final keys = AppConstants.loanDurations.keys.toList();
                    if (!keys.contains(_durationLabel)) {
                      keys.insert(0, _durationLabel);
                    }
                    return keys
                        .map((key) => DropdownMenuItem(
                              value: key,
                              child:
                                  Text(FormatUtils.getDurationLabel(key, l10n)),
                            ))
                        .toList();
                  })(),
                  onChanged: (v) => setState(() => _durationLabel = v!),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.event_rounded,
                        size: 16, color: AppColors.secondary),
                    const SizedBox(width: 8),
                    Text(
                      '${l10n.repaymentDate}: ${FormatUtils.formatDate(_dueDate, 'd/M/y', locale: Localizations.localeOf(context).languageCode)}',
                      style: const TextStyle(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ]),
            const SizedBox(height: 16),
            _SectionHeader(title: l10n.loans, icon: Icons.style_rounded),
            _buildCard(children: [
              DropdownButtonFormField<String>(
                initialValue: _cardCompany,
                decoration: InputDecoration(
                  labelText: l10n.cardCompany,
                  prefixIcon: const Icon(Icons.business_rounded),
                ),
                items: AppConstants.cardCompanies
                    .map((c) => DropdownMenuItem(
                          value: c,
                          child: Text(FormatUtils.getCompanyLabel(c, l10n)),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _cardCompany = v!),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _cardCategory,
                decoration: InputDecoration(
                  labelText: l10n.cardCategory,
                  prefixIcon: const Icon(Icons.attach_money_rounded),
                ),
                items: AppConstants.cardCategories
                    .map((c) => DropdownMenuItem(
                          value: c,
                          child: Text(c == 'أخرى'
                              ? l10n.other
                              : '$c ${AppConstants.currencyLabel}'),
                        ))
                    .toList(),
                onChanged: (v) {
                  setState(() {
                    _cardCategory = v!;
                    _customCardValue = v == 'أخرى';
                    if (!_customCardValue) _cardValueCtrl.clear();
                  });
                },
              ),
              if (_customCardValue) ...[
                const SizedBox(height: 12),
                _buildField(
                  controller: _cardValueCtrl,
                  label: l10n.cardValueLabel,
                  icon: Icons.monetization_on_outlined,
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (_customCardValue && (v == null || v.isEmpty)) {
                      return 'يرجى إدخال قيمة البطاقة';
                    }
                    return null;
                  },
                  onChanged: (_) => setState(() {}),
                ),
              ],
              const SizedBox(height: 12),
              _buildField(
                controller: _cardCountCtrl,
                label: l10n.cardCount,
                icon: Icons.content_copy_rounded,
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? l10n.cardCountRequired : null,
                onChanged: (_) => setState(() {}),
              ),
            ]),
            const SizedBox(height: 16),
            _SectionHeader(title: l10n.profit, icon: Icons.trending_up_rounded),
            _buildCard(children: [
              Row(
                children: [
                  Text('${l10n.profitType}: ',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: Text(l10n.profitPercentage),
                    selected: _profitType == AppConstants.profitTypePercentage,
                    onSelected: (_) => setState(
                        () => _profitType = AppConstants.profitTypePercentage),
                    selectedColor: AppColors.primary.withValues(alpha: 0.2),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: Text(l10n.fixedAmount),
                    selected: _profitType == AppConstants.profitTypeFixed,
                    onSelected: (_) => setState(
                        () => _profitType = AppConstants.profitTypeFixed),
                    selectedColor: AppColors.primary.withValues(alpha: 0.2),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildField(
                controller: _profitCtrl,
                label: _profitType == AppConstants.profitTypePercentage
                    ? l10n.profitRate
                    : l10n.profitAmount,
                icon: Icons.percent_rounded,
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? l10n.profitValueRequired : null,
                onChanged: (_) => setState(() {}),
              ),
            ]),
            const SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Column(
                children: [
                  Text(
                    l10n.loanSummary,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _SummaryItem(
                          label: l10n.totalCardsAmount,
                          value: '${_totalAmount.toStringAsFixed(0)} MRU'),
                      _SummaryItem(
                          label: l10n.profit,
                          value: '${_profitAmount.toStringAsFixed(0)} MRU'),
                      _SummaryItem(
                          label: l10n.finalAmount,
                          value: '${_finalAmount.toStringAsFixed(0)} MRU',
                          large: true),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),
            SizedBox(
              height: 54.h,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                    ? SizedBox(
                        height: 24.h,
                        width: 24.w,
                        child: const CircularProgressIndicator(
                            color: Colors.white),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                              widget.existingLoan == null
                                  ? Icons.add_circle_rounded
                                  : Icons.save_rounded,
                              size: 22.sp),
                          SizedBox(width: 8.w),
                          Text(
                            widget.existingLoan == null
                                ? l10n.addLoan
                                : l10n.save,
                            style: TextStyle(fontSize: 17.sp),
                          ),
                        ],
                      ),
              ),
            ),
            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({required List<Widget> children}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
      ),
      validator: validator,
      onChanged: onChanged,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20.sp),
          SizedBox(width: 8.w),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15.sp,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final bool large;

  const _SummaryItem(
      {required this.label, required this.value, this.large = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: large ? 20.sp : 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.white70, fontSize: 11.sp),
        ),
      ],
    );
  }
}
