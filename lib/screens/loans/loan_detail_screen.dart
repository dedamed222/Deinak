import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../core/utils/format_utils.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/loans_provider.dart';
import '../../models/loan_model.dart';
import '../../services/notification_service.dart';
import '../../l10n/app_localizations.dart';
import 'add_loan_screen.dart';

class LoanDetailScreen extends StatelessWidget {
  final LoanModel loan;

  const LoanDetailScreen({super.key, required this.loan});

  @override
  Widget build(BuildContext context) {
    final status = loan.computedStatus;
    final statusColor = status == AppConstants.statusOverdue
        ? AppColors.loanOverdue
        : status == AppConstants.statusCompleted
            ? AppColors.loanCompleted
            : loan.isDueWithin24Hours
                ? AppColors.loanWarning
                : AppColors.loanActive;

    final l10n = AppLocalizations.of(context)!;
    final statusLabel = status == AppConstants.statusOverdue
        ? l10n.overdue
        : status == AppConstants.statusCompleted
            ? l10n.completed
            : loan.isDueWithin24Hours
                ? l10n.endsSoon
                : l10n.active;

    return Scaffold(
      appBar: AppBar(
        title: Text(loan.borrowerName),
        actions: [
          if (loan.status != AppConstants.statusCompleted)
            PopupMenuButton<String>(
              onSelected: (v) async {
                if (v == 'edit') {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (_) => AddLoanScreen(existingLoan: loan)),
                  );
                } else if (v == 'delete') {
                  _confirmDelete(context);
                }
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      const Icon(Icons.edit_outlined),
                      const SizedBox(width: 8),
                      Text(l10n.editLoan),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      const Icon(Icons.delete_outline, color: AppColors.error),
                      const SizedBox(width: 8),
                      Text(l10n.delete,
                          style: const TextStyle(color: AppColors.error)),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            // Header Card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [statusColor, statusColor.withValues(alpha: 0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 36.r,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    child: Text(
                      loan.borrowerName.isNotEmpty ? loan.borrowerName[0] : '?',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    loan.borrowerName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Clipboard.setData(
                        ClipboardData(text: loan.phoneNumber)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.phone, color: Colors.white70, size: 16.sp),
                        SizedBox(width: 4.w),
                        Text(
                          loan.phoneNumber,
                          style:
                              TextStyle(color: Colors.white70, fontSize: 15.sp),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      statusLabel,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Financial Summary
            _DetailCard(
              title: l10n.amounts,
              children: [
                _DetailRow(
                  icon: Icons.credit_card_rounded,
                  label: l10n.totalCardsAmount,
                  value: '${loan.totalAmount.toStringAsFixed(0)} MRU',
                ),
                _DetailRow(
                  icon: Icons.trending_up_rounded,
                  label: l10n.profit,
                  value: '${loan.profitAmount.toStringAsFixed(0)} MRU',
                  valueColor: AppColors.success,
                ),
                const Divider(),
                _DetailRow(
                  icon: Icons.account_balance_wallet_rounded,
                  label: l10n.finalAmount,
                  value: '${loan.amountWithProfit.toStringAsFixed(0)} MRU',
                  bold: true,
                  large: true,
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Loan Details
            _DetailCard(
              title: l10n.loanDetails,
              children: [
                _DetailRow(
                  icon: Icons.business_rounded,
                  label: l10n.company,
                  value: FormatUtils.getCompanyLabel(loan.cardCompany, l10n),
                ),
                _DetailRow(
                  icon: Icons.style_rounded,
                  label: l10n.categoryAndCount,
                  value:
                      '${loan.cardValue.toStringAsFixed(0)} MRU × ${loan.cardCount}',
                ),
                _DetailRow(
                  icon: Icons.percent,
                  label: l10n.profit,
                  value: loan.profitType == AppConstants.profitTypePercentage
                      ? '${loan.profitValue}%'
                      : '${loan.profitValue.toStringAsFixed(0)} MRU ${l10n.fixed}',
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Dates
            _DetailCard(
              title: l10n.dates,
              children: [
                _DetailRow(
                  icon: Icons.calendar_today_rounded,
                  label: l10n.loanDate,
                  value: FormatUtils.formatDate(loan.loanDate, 'EEEE d MMMM y',
                      locale: Localizations.localeOf(context).languageCode),
                ),
                _DetailRow(
                  icon: Icons.event_rounded,
                  label: l10n.loanDuration,
                  value: FormatUtils.getDurationLabel(loan.durationLabel, l10n),
                ),
                _DetailRow(
                  icon: Icons.alarm_rounded,
                  label: l10n.repaymentDate,
                  value: FormatUtils.formatDate(loan.dueDate, 'EEEE d MMMM y',
                      locale: Localizations.localeOf(context).languageCode),
                  valueColor: statusColor,
                ),
                if (loan.paidAt != null)
                  _DetailRow(
                    icon: Icons.check_circle_rounded,
                    label: l10n.paidAt,
                    value: FormatUtils.formatDate(loan.paidAt!, 'EEEE d MMMM y',
                        locale: Localizations.localeOf(context).languageCode),
                    valueColor: AppColors.success,
                  ),
              ],
            ),

            if (loan.notes != null && loan.notes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              _DetailCard(
                title: l10n.notes,
                children: [
                  Text(loan.notes!,
                      style: TextStyle(fontSize: 14.sp, height: 1.5)),
                ],
              ),
            ],

            const SizedBox(height: 24),

            // Action Buttons
            if (loan.status != AppConstants.statusCompleted) ...[
              SizedBox(
                width: double.infinity,
                height: 52.h,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => _markAsPaid(context),
                  icon: Icon(Icons.check_circle_rounded, size: 24.sp),
                  label:
                      Text(l10n.markAsPaid, style: TextStyle(fontSize: 17.sp)),
                ),
              ),
              SizedBox(height: 32.h),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _markAsPaid(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.confirmPaidTitle),
        content: Text(l10n.confirmPaidMessage(loan.borrowerName)),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.no),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
            child: Text(l10n.yesPaid),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      final userId = context.read<AuthProvider>().effectiveUserId;
      await context.read<LoansProvider>().markAsPaid(loan.id!, userId);
      await NotificationService().cancelLoanNotifications(loan.id!);
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.paidSuccess),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.confirmDeleteTitle),
        content: Text(l10n.confirmDeleteMessage(loan.borrowerName)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      final userId = context.read<AuthProvider>().effectiveUserId;
      await context.read<LoansProvider>().deleteLoan(loan.id!, userId);
      await NotificationService().cancelLoanNotifications(loan.id!);
      if (context.mounted) {
        Navigator.pop(context);
      }
    }
  }
}

class _DetailCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _DetailCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF1E293B)
            : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10.r,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final bool bold;
  final bool large;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    this.bold = false,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        children: [
          Icon(icon,
              size: 18.sp, color: AppColors.primary.withValues(alpha: 0.7)),
          SizedBox(width: 10.w),
          Text(
            label,
            style: TextStyle(
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              fontSize: 13.sp,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.w600,
              fontSize: large ? 17.sp : 14.sp,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
