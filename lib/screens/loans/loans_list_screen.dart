import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../core/utils/format_utils.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/loans_provider.dart';
import '../../models/loan_model.dart';
import 'loan_detail_screen.dart';
import 'add_loan_screen.dart';
import '../../services/notification_service.dart';
import '../../providers/auth_provider.dart';
import '../../l10n/app_localizations.dart';

class LoansListScreen extends StatefulWidget {
  const LoansListScreen({super.key});

  @override
  State<LoansListScreen> createState() => _LoansListScreenState();
}

class _LoansListScreenState extends State<LoansListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _searchCtrl.addListener(() {
      context.read<LoansProvider>().setSearchQuery(_searchCtrl.text);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final loans = context.watch<LoansProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.loans),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(110),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: TextField(
                  controller: _searchCtrl,
                  decoration: InputDecoration(
                    hintText: l10n.searchHint,
                    prefixIcon: Icon(Icons.search, size: 20.sp),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF334155) : Colors.white,
                    contentPadding: EdgeInsets.symmetric(vertical: 0.h),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.r),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                indicatorWeight: 3.h,
                labelStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                    fontSize: 13.sp),
                unselectedLabelStyle:
                    TextStyle(fontFamily: 'Cairo', fontSize: 13.sp),
                tabs: [
                  Tab(text: l10n.activeTab(loans.activeLoans.length)),
                  Tab(text: l10n.overdueTab(loans.overdueLoans.length)),
                  Tab(text: l10n.completedTab(loans.completedLoans.length)),
                ],
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _LoanList(loans: loans.activeLoans),
          _LoanList(loans: loans.overdueLoans),
          _LoanList(loans: loans.completedLoans),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'loans_list_add_loan_fab',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddLoanScreen()),
          );
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class _LoanList extends StatelessWidget {
  final List<LoanModel> loans;
  const _LoanList({required this.loans});

  @override
  Widget build(BuildContext context) {
    if (loans.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined,
                size: 64.sp, color: Colors.grey.shade400),
            SizedBox(height: 16.h),
            Text(
              AppLocalizations.of(context)!.noLoansList,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16.sp),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(8.w),
      itemCount: loans.length,
      itemBuilder: (context, index) {
        return _LoanCard(loan: loans[index]);
      },
    );
  }
}

class _LoanCard extends StatelessWidget {
  final LoanModel loan;
  const _LoanCard({required this.loan});

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

    return Card(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => LoanDetailScreen(loan: loan)),
          );
        },
        borderRadius: BorderRadius.circular(16.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: statusColor.withValues(alpha: 0.1),
                    child: Text(
                      loan.borrowerName.isNotEmpty ? loan.borrowerName[0] : '?',
                      style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16.sp),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loan.borrowerName,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16.sp),
                        ),
                        Text(
                          loan.phoneNumber,
                          style: TextStyle(
                              color: Colors.grey.shade600, fontSize: 13.sp),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 12.w),
                  _buildActionsMenu(context),
                ],
              ),
              Divider(height: 24.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _InfoItem(
                    label: AppLocalizations.of(context)!.company,
                    value: FormatUtils.getCompanyLabel(
                        loan.cardCompany, AppLocalizations.of(context)!),
                    icon: Icons.business_rounded,
                  ),
                  _InfoItem(
                    label: AppLocalizations.of(context)!.repaymentDate,
                    value: FormatUtils.formatDate(loan.dueDate, 'd/M/y',
                        locale: Localizations.localeOf(context).languageCode),
                    icon: Icons.calendar_today_rounded,
                    color: status == AppConstants.statusOverdue
                        ? AppColors.loanOverdue
                        : null,
                  ),
                  _InfoItem(
                    label: AppLocalizations.of(context)!.profit,
                    value: '${loan.profitAmount.toStringAsFixed(0)} MRU',
                    icon: Icons.trending_up,
                    color: AppColors.success,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionsMenu(BuildContext context) {
    final status = loan.computedStatus;
    final statusColor = status == AppConstants.statusOverdue
        ? AppColors.loanOverdue
        : status == AppConstants.statusCompleted
            ? AppColors.loanCompleted
            : loan.isDueWithin24Hours
                ? AppColors.loanWarning
                : AppColors.loanActive;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: statusColor.withValues(alpha: 0.2)),
          ),
          child: Text(
            '${loan.amountWithProfit.toStringAsFixed(0)} MRU',
            style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.bold,
                fontSize: 13.sp),
          ),
        ),
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: Colors.grey.shade600, size: 20.sp),
          padding: EdgeInsets.zero,
          constraints: BoxConstraints(minWidth: 120.w),
          onSelected: (v) {
            if (v == 'edit') {
              Navigator.push(
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
                  Icon(Icons.edit_outlined, size: 18.sp),
                  SizedBox(width: 8.w),
                  Text(AppLocalizations.of(context)!.editLoan,
                      style: TextStyle(fontSize: 14.sp, fontFamily: 'Cairo')),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete_outline,
                      color: AppColors.error, size: 18.sp),
                  SizedBox(width: 8.w),
                  Text(AppLocalizations.of(context)!.delete,
                      style: TextStyle(
                          color: AppColors.error,
                          fontSize: 14.sp,
                          fontFamily: 'Cairo')),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) {
        final l10n = AppLocalizations.of(context)!;
        return AlertDialog(
          title: Text(l10n.confirmDeleteTitle),
          content: Text(l10n.confirmDeleteMessage(loan.borrowerName)),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
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
        );
      },
    );

    if (confirm == true && context.mounted) {
      final userId = context.read<AuthProvider>().effectiveUserId;
      await context.read<LoansProvider>().deleteLoan(loan.id!, userId);
      await NotificationService().cancelLoanNotifications(loan.id!);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.deleteSuccess),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}

class _InfoItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? color;

  const _InfoItem({
    required this.label,
    required this.value,
    required this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14.sp, color: Colors.grey.shade500),
            SizedBox(width: 4.w),
            Text(label,
                style: TextStyle(color: Colors.grey.shade500, fontSize: 11.sp)),
          ],
        ),
        SizedBox(height: 2.h),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12.sp,
            color: color,
          ),
        ),
      ],
    );
  }
}
