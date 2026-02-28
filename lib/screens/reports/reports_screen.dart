import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../core/utils/format_utils.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/loans_provider.dart';
import '../../models/loan_model.dart';
import '../../l10n/app_localizations.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  DateTime _selectedMonth = DateTime.now();
  double _monthProfit = 0;
  bool _loadingProfit = false;

  @override
  void initState() {
    super.initState();
    _loadMonthProfit();
  }

  Future<void> _loadMonthProfit() async {
    setState(() => _loadingProfit = true);
    final userId = context.read<AuthProvider>().effectiveUserId;
    final profit = await context
        .read<LoansProvider>()
        .getMonthlyProfit(userId, _selectedMonth.year, _selectedMonth.month);
    if (mounted) {
      setState(() {
        _monthProfit = profit;
        _loadingProfit = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final loans = context.watch<LoansProvider>();
    final stats = loans.statistics;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.reports)),
      body: RefreshIndicator(
        onRefresh: () async {
          final userId = context.read<AuthProvider>().effectiveUserId;
          await loans.loadLoans(userId);
          await _loadMonthProfit();
        },
        child: ListView(
          padding: EdgeInsets.all(16.w),
          children: [
            // Overview Stats
            Text(
              l10n.overview,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold, fontSize: 16.sp),
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                _ReportStatCard(
                  label: l10n.totalLoansCount,
                  value:
                      '${(stats['activeCount'] ?? 0) + (stats['overdueCount'] ?? 0) + (stats['completedCount'] ?? 0)}',
                  icon: Icons.receipt_long_rounded,
                  color: AppColors.primary,
                ),
                SizedBox(width: 12.w),
                _ReportStatCard(
                  label: l10n.totalLent,
                  value:
                      '${((stats['totalLent'] ?? 0) as num).toStringAsFixed(0)} MRU',
                  icon: Icons.account_balance_wallet_rounded,
                  color: AppColors.secondary,
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                _ReportStatCard(
                  label: l10n.earnedProfit,
                  value:
                      '${((stats['totalEarned'] ?? 0) as num).toStringAsFixed(0)} MRU',
                  icon: Icons.savings_rounded,
                  color: AppColors.success,
                ),
                SizedBox(width: 12.w),
                _ReportStatCard(
                  label: l10n.expectedProfitLabel,
                  value:
                      '${((stats['totalExpectedProfit'] ?? 0) as num).toStringAsFixed(0)} MRU',
                  icon: Icons.trending_up_rounded,
                  color: AppColors.accent,
                ),
              ],
            ),

            SizedBox(height: 24.h),
            // Monthly Profit
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_forward_ios,
                            color: Colors.white, size: 18.sp),
                        onPressed: () {
                          setState(() {
                            _selectedMonth = DateTime(
                                _selectedMonth.year, _selectedMonth.month - 1);
                          });
                          _loadMonthProfit();
                        },
                      ),
                      Text(
                        FormatUtils.formatDate(_selectedMonth, 'MMMM y',
                            locale:
                                Localizations.localeOf(context).languageCode),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.arrow_back_ios,
                            color: Colors.white, size: 18.sp),
                        onPressed: _selectedMonth.year == DateTime.now().year &&
                                _selectedMonth.month == DateTime.now().month
                            ? null
                            : () {
                                setState(() {
                                  _selectedMonth = DateTime(_selectedMonth.year,
                                      _selectedMonth.month + 1);
                                });
                                _loadMonthProfit();
                              },
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  _loadingProfit
                      ? SizedBox(
                          height: 24.h,
                          width: 24.w,
                          child: const CircularProgressIndicator(
                              color: Colors.white),
                        )
                      : Text(
                          '${_monthProfit.toStringAsFixed(0)} MRU',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                  Text(
                    l10n.monthProfitLabel,
                    style: TextStyle(color: Colors.white70, fontSize: 13.sp),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.h),
            Text(
              l10n.loanDistribution,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold, fontSize: 16.sp),
            ),
            SizedBox(height: 12.h),

            // Status pie chart (manual)
            _StatusDistribution(
              active: stats['activeCount'] ?? 0,
              overdue: stats['overdueCount'] ?? 0,
              completed: stats['completedCount'] ?? 0,
              l10n: l10n,
            ),

            SizedBox(height: 24.h),
            Text(
              l10n.recentCompletedLoansTitle,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold, fontSize: 16.sp),
            ),
            SizedBox(height: 8.h),

            if (loans.completedLoans.isEmpty)
              Center(
                child: Padding(
                  padding: EdgeInsets.all(32.w),
                  child: Text(
                    l10n.noCompletedLoans,
                    style:
                        TextStyle(color: Colors.grey.shade600, fontSize: 14.sp),
                  ),
                ),
              )
            else
              ...loans.completedLoans
                  .take(5)
                  .map((loan) => _CompletedLoanTile(loan: loan)),

            SizedBox(height: 80.h),
          ],
        ),
      ),
    );
  }
}

class _ReportStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _ReportStatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 22.sp),
            SizedBox(height: 8.h),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                fontSize: 11.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusDistribution extends StatelessWidget {
  final int active;
  final int overdue;
  final int completed;
  final AppLocalizations l10n;

  const _StatusDistribution({
    required this.active,
    required this.overdue,
    required this.completed,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final total = (active + overdue + completed).toDouble();
    if (total == 0) {
      return Center(child: Text(l10n.noData));
    }

    return Row(
      children: [
        Expanded(
          child: _DistributionBar(
            label: l10n.active,
            count: active,
            total: total,
            color: AppColors.loanActive,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _DistributionBar(
            label: l10n.overdue,
            count: overdue,
            total: total,
            color: AppColors.loanOverdue,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _DistributionBar(
            label: l10n.completed,
            count: completed,
            total: total,
            color: AppColors.loanCompleted,
          ),
        ),
      ],
    );
  }
}

class _DistributionBar extends StatelessWidget {
  final String label;
  final int count;
  final double total;
  final Color color;

  const _DistributionBar({
    required this.label,
    required this.count,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pct = total > 0 ? (count / total * 100) : 0.0;
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          Text(
            '$count',
            style: TextStyle(
              color: color,
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(label, style: TextStyle(fontSize: 12.sp)),
          SizedBox(height: 6.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: LinearProgressIndicator(
              value: pct / 100,
              backgroundColor: color.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 6.h,
            ),
          ),
          Text(
            '${pct.toStringAsFixed(0)}%',
            style: TextStyle(fontSize: 10.sp, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}

class _CompletedLoanTile extends StatelessWidget {
  final LoanModel loan;

  const _CompletedLoanTile({required this.loan});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 8.h),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: AppColors.loanCompleted,
          child: Icon(Icons.check, color: Colors.white),
        ),
        title: Text(loan.borrowerName,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)),
        subtitle: loan.paidAt != null
            ? Text(
                FormatUtils.formatDate(loan.paidAt!, 'd/M/y',
                    locale: Localizations.localeOf(context).languageCode),
                style: TextStyle(fontSize: 13.sp),
              )
            : null,
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${loan.amountWithProfit.toStringAsFixed(0)} MRU',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
            ),
            Text(
              '+${loan.profitAmount.toStringAsFixed(0)} ${AppLocalizations.of(context)!.profitSuffix}',
              style: TextStyle(color: AppColors.success, fontSize: 11.sp),
            ),
          ],
        ),
      ),
    );
  }
}
