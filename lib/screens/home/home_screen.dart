import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../core/utils/format_utils.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/loans_provider.dart';
import '../../models/loan_model.dart';
import '../auth/login_screen.dart';
import '../loans/add_loan_screen.dart';
import '../loans/loan_detail_screen.dart';
import '../../l10n/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double _todayProfit = 0;
  double _monthProfit = 0;

  @override
  void initState() {
    super.initState();
    _loadProfits();
  }

  Future<void> _loadProfits() async {
    final auth = context.read<AuthProvider>();
    final userId =
        auth.isGuest ? AppConstants.guestUserId : auth.currentUser?.id;
    if (userId == null) return;
    final loans = context.read<LoansProvider>();
    final now = DateTime.now();
    final today = await loans.getDailyProfit(userId, now);
    final month = await loans.getMonthlyProfit(userId, now.year, now.month);
    if (mounted) {
      setState(() {
        _todayProfit = today;
        _monthProfit = month;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final loansProvider = context.watch<LoansProvider>();

    final stats = loansProvider.statistics;
    final overdueLoans = loansProvider.overdueLoans;
    final l10n = AppLocalizations.of(context)!;
    final displayName = auth.isGuest
        ? l10n.guestUser
        : (auth.currentUser?.fullName ?? auth.currentUser?.username ?? 'U');
    final userInitial = displayName.substring(0, 1).toUpperCase();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appName),
        actions: [
          Padding(
            padding: EdgeInsets.only(left: 16.w, right: 8.w),
            child: CircleAvatar(
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              child: Text(
                userInitial,
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp),
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          final userId =
              auth.isGuest ? AppConstants.guestUserId : auth.currentUser?.id;
          if (userId != null) {
            await loansProvider.loadLoans(userId);
            await _loadProfits();
          }
        },
        child: CustomScrollView(
          slivers: [
            // Guest banner
            if (auth.isGuest)
              SliverToBoxAdapter(
                child: _GuestBanner(
                  onLogin: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  ),
                ),
              ),

            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dashboard Card
                    _DashboardCard(
                      todayProfit: _todayProfit,
                      monthProfit: _monthProfit,
                      totalLent: (stats['totalLent'] as num? ?? 0.0).toDouble(),
                      expectedProfit:
                          (stats['totalExpectedProfit'] as num? ?? 0.0)
                              .toDouble(),
                      activeCount: stats['activeCount'] ?? 0,
                    ),
                    SizedBox(height: 24.h),

                    if (overdueLoans.isNotEmpty) ...[
                      Row(
                        children: [
                          Icon(Icons.warning_amber_rounded,
                              color: AppColors.error, size: 20.sp),
                          SizedBox(width: 8.w),
                          Text(
                            l10n.overdueLoansTitle(overdueLoans.length),
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.error,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      ...overdueLoans
                          .take(3)
                          .map((loan) => _OverdueLoanCard(loan: loan)),
                      const SizedBox(height: 16),
                    ],

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.recentLoans,
                          style: TextStyle(
                              fontSize: 18.sp, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Recent Loans
            if (loansProvider.activeLoans.isEmpty)
              SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(40.w),
                    child: Column(
                      children: [
                        Icon(Icons.credit_card_off_rounded,
                            size: 64.sp, color: Colors.grey.shade400),
                        SizedBox(height: 16.h),
                        Text(
                          l10n.noActiveLoans,
                          style: TextStyle(
                              fontSize: 16.sp, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) {
                    final loan = loansProvider.activeLoans[i];
                    return _LoanMiniCard(loan: loan);
                  },
                  childCount: loansProvider.activeLoans.take(5).length,
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'home_add_loan_fab',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddLoanScreen()),
          );
        },
        icon: const Icon(Icons.add_rounded),
        label: Text(l10n.newLoan),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }
}

// ─── Guest Banner ────────────────────────────────────────────────────────────

class _GuestBanner extends StatelessWidget {
  final VoidCallback onLogin;
  const _GuestBanner({required this.onLogin});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3CD),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFFFD966), width: 1),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded,
              color: const Color(0xFF856404), size: 22.sp),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              l10n.guestBannerText,
              style: TextStyle(
                color: const Color(0xFF856404),
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: onLogin,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(l10n.login,
                style: const TextStyle(
                    color: Color(0xFF0D6EFD), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

// ─── Dashboard Card ───────────────────────────────────────────────────────────

class _DashboardCard extends StatelessWidget {
  final double todayProfit;
  final double monthProfit;
  final double totalLent;
  final double expectedProfit;
  final int activeCount;

  const _DashboardCard({
    required this.todayProfit,
    required this.monthProfit,
    required this.totalLent,
    required this.expectedProfit,
    required this.activeCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFF1E40AF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!.totalLentAmount,
                style: TextStyle(color: Colors.white70, fontSize: 13.sp),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  AppLocalizations.of(context)!.activeLoansCount(activeCount),
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          Text(
            '${totalLent.toStringAsFixed(0)} MRU',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32.sp,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          SizedBox(height: 24.h),
          Row(
            children: [
              _DashboardItem(
                label: AppLocalizations.of(context)!.todayProfitLabel,
                value: '${todayProfit.toStringAsFixed(0)} MRU',
                icon: Icons.trending_up_rounded,
              ),
              const Spacer(),
              _DashboardItem(
                label: AppLocalizations.of(context)!.expectedProfitLabel,
                value: '${expectedProfit.toStringAsFixed(0)} MRU',
                icon: Icons.account_balance_wallet_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DashboardItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _DashboardItem(
      {required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.white60, size: 14.sp),
            SizedBox(width: 4.w),
            Text(label,
                style: TextStyle(color: Colors.white60, fontSize: 11.sp)),
          ],
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

// ─── Overdue Loan Card ────────────────────────────────────────────────────────

class _OverdueLoanCard extends StatelessWidget {
  final LoanModel loan;

  const _OverdueLoanCard({required this.loan});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.error.withValues(alpha: 0.05),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        side:
            BorderSide(color: AppColors.error.withValues(alpha: 0.2), width: 1),
      ),
      margin: EdgeInsets.only(bottom: 8.h),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: AppColors.error.withValues(alpha: 0.1),
          child:
              const Icon(Icons.warning_amber_rounded, color: AppColors.error),
        ),
        title: Text(loan.borrowerName,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${loan.amountWithProfit.toStringAsFixed(0)} MRU'),
        trailing: Icon(Icons.arrow_forward_ios_rounded,
            size: 14.sp, color: AppColors.error),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => LoanDetailScreen(loan: loan)),
        ),
      ),
    );
  }
}

// ─── Loan Mini Card ───────────────────────────────────────────────────────────

class _LoanMiniCard extends StatelessWidget {
  final LoanModel loan;

  const _LoanMiniCard({required this.loan});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final statusColor = loan.computedStatus == AppConstants.statusOverdue
        ? AppColors.loanOverdue
        : loan.status == AppConstants.statusCompleted
            ? AppColors.loanCompleted
            : AppColors.loanActive;

    final hoursLeft = loan.hoursUntilDue;
    String dueText;
    if (loan.status == AppConstants.statusCompleted) {
      dueText = l10n.completed;
    } else if (loan.computedStatus == AppConstants.statusOverdue) {
      dueText = l10n.overdue;
    } else if (hoursLeft <= 24) {
      dueText = FormatUtils.formatDate(loan.dueDate, 'HH:mm');
    } else {
      dueText = FormatUtils.formatDate(loan.dueDate, 'd/M/y',
          locale: Localizations.localeOf(context).languageCode);
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.person_rounded, color: statusColor),
        ),
        title: Text(
          loan.borrowerName,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
        ),
        subtitle: Text(
          '${loan.cardCompany} • ${loan.cardCount} ${l10n.cardCount}',
          style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${loan.amountWithProfit.toStringAsFixed(0)} MRU',
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.primary),
            ),
            SizedBox(height: 4.h),
            Text(
              dueText,
              style: TextStyle(
                  color: statusColor,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => LoanDetailScreen(loan: loan)),
        ),
      ),
    );
  }
}
