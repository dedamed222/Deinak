import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/app_constants.dart';
import '../../models/loan_model.dart';

class LoanRepository {
  final _supabase = Supabase.instance.client;

  Future<int> addLoan(LoanModel loan) async {
    try {
      final response =
          await _supabase.from('loans').insert(loan.toMap()).select();
      if (response.isNotEmpty) {
        return response.first['id'] as int;
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  Future<bool> updateLoan(LoanModel loan) async {
    try {
      final updated = loan.copyWith(updatedAt: DateTime.now());
      await _supabase.from('loans').update(updated.toMap()).eq('id', loan.id!);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteLoan(int id) async {
    try {
      await _supabase.from('loans').delete().eq('id', id);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<LoanModel?> getLoanById(int id) async {
    try {
      final response =
          await _supabase.from('loans').select().eq('id', id).maybeSingle();
      if (response == null) return null;
      return LoanModel.fromMap(response);
    } catch (e) {
      return null;
    }
  }

  Future<List<LoanModel>> getAllLoans(int userId) async {
    try {
      final response = await _supabase
          .from('loans')
          .select()
          .eq('user_id', userId)
          .order('due_date', ascending: true);
      return _updateStatuses(List<Map<String, dynamic>>.from(response)
          .map(LoanModel.fromMap)
          .toList());
    } catch (e) {
      return [];
    }
  }

  Future<List<LoanModel>> getActiveLoans(int userId) async {
    try {
      final response = await _supabase
          .from('loans')
          .select()
          .eq('user_id', userId)
          .neq('status', AppConstants.statusCompleted)
          .order('due_date', ascending: true);
      return _updateStatuses(List<Map<String, dynamic>>.from(response)
          .map(LoanModel.fromMap)
          .toList());
    } catch (e) {
      return [];
    }
  }

  Future<List<LoanModel>> getOverdueLoans(int userId) async {
    final all = await getAllLoans(userId);
    return all
        .where((l) => l.computedStatus == AppConstants.statusOverdue)
        .toList();
  }

  Future<List<LoanModel>> getCompletedLoans(int userId) async {
    try {
      final response = await _supabase
          .from('loans')
          .select()
          .eq('user_id', userId)
          .eq('status', AppConstants.statusCompleted)
          .order('paid_at', ascending: false);
      return List<Map<String, dynamic>>.from(response)
          .map(LoanModel.fromMap)
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<LoanModel>> searchLoans(int userId, String query) async {
    try {
      final response = await _supabase
          .from('loans')
          .select()
          .eq('user_id', userId)
          .or('borrower_name.ilike.%$query%,phone_number.ilike.%$query%')
          .order('due_date', ascending: true);
      return _updateStatuses(List<Map<String, dynamic>>.from(response)
          .map(LoanModel.fromMap)
          .toList());
    } catch (e) {
      return [];
    }
  }

  Future<bool> markAsPaid(int loanId) async {
    try {
      final now = DateTime.now().toUtc();
      await _supabase.from('loans').update({
        'status': AppConstants.statusCompleted,
        'paid_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      }).eq('id', loanId);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Get loans due within 24 hours (for notifications)
  Future<List<LoanModel>> getLoansDueSoon(int userId) async {
    final all = await getActiveLoans(userId);
    return all.where((l) => l.isDueWithin24Hours).toList();
  }

  // Daily profit for a specific date
  Future<double> getDailyProfit(int userId, DateTime date) async {
    try {
      final dayStart =
          DateTime(date.year, date.month, date.day).toUtc().toIso8601String();
      final dayEnd = DateTime(date.year, date.month, date.day, 23, 59, 59)
          .toUtc()
          .toIso8601String();

      final response = await _supabase
          .from('loans')
          .select('amount_with_profit, total_amount')
          .eq('user_id', userId)
          .eq('status', AppConstants.statusCompleted)
          .gte('paid_at', dayStart)
          .lte('paid_at', dayEnd);

      double profit = 0;
      for (var row in response) {
        profit +=
            (row['amount_with_profit'] as num) - (row['total_amount'] as num);
      }
      return profit;
    } catch (e) {
      return 0.0;
    }
  }

  // Monthly profit
  Future<double> getMonthlyProfit(int userId, int year, int month) async {
    try {
      final monthStart = DateTime(year, month, 1).toUtc().toIso8601String();
      final monthEnd =
          DateTime(year, month + 1, 0, 23, 59, 59).toUtc().toIso8601String();

      final response = await _supabase
          .from('loans')
          .select('amount_with_profit, total_amount')
          .eq('user_id', userId)
          .eq('status', AppConstants.statusCompleted)
          .gte('paid_at', monthStart)
          .lte('paid_at', monthEnd);

      double profit = 0;
      for (var row in response) {
        profit +=
            (row['amount_with_profit'] as num) - (row['total_amount'] as num);
      }
      return profit;
    } catch (e) {
      return 0.0;
    }
  }

  // Total statistics
  Future<Map<String, dynamic>> getStatistics(int userId) async {
    final all = await getAllLoans(userId);
    final active = all
        .where((l) => l.computedStatus == AppConstants.statusActive)
        .toList();
    final overdue = all
        .where((l) => l.computedStatus == AppConstants.statusOverdue)
        .toList();
    final completed =
        all.where((l) => l.status == AppConstants.statusCompleted).toList();

    final double totalLent = active.fold(0.0, (s, l) => s + l.totalAmount) +
        overdue.fold(0.0, (s, l) => s + l.totalAmount);
    final double totalExpectedProfit =
        active.fold(0.0, (s, l) => s + l.profitAmount) +
            overdue.fold(0.0, (s, l) => s + l.profitAmount);
    final double totalEarned =
        completed.fold(0.0, (s, l) => s + l.profitAmount);

    return {
      'activeCount': active.length,
      'overdueCount': overdue.length,
      'completedCount': completed.length,
      'totalLent': totalLent,
      'totalExpectedProfit': totalExpectedProfit,
      'totalEarned': totalEarned,
    };
  }

  // Update statuses in DB for overdue loans
  List<LoanModel> _updateStatuses(List<LoanModel> loans) {
    return loans.map((loan) {
      final computed = loan.computedStatus;
      if (computed != loan.status &&
          loan.status != AppConstants.statusCompleted) {
        // Update in DB asynchronously
        _updateStatusInDB(loan.id!, computed);
        return loan.copyWith(status: computed);
      }
      return loan;
    }).toList();
  }

  Future<void> _updateStatusInDB(int id, String status) async {
    try {
      await _supabase.from('loans').update({
        'status': status,
        'updated_at': DateTime.now().toUtc().toIso8601String()
      }).eq('id', id);
    } catch (_) {}
  }
}
