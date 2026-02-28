import 'package:flutter/foundation.dart';
import '../core/constants/app_constants.dart';
import '../core/database/loan_repository.dart';
import '../models/loan_model.dart';

enum LoansStatus { initial, loading, loaded, error }

class LoansProvider extends ChangeNotifier {
  final LoanRepository _repo = LoanRepository();

  LoansStatus _status = LoansStatus.initial;
  List<LoanModel> _loans = [];
  List<LoanModel> _filtered = [];
  String _searchQuery = '';
  String _filterStatus = 'all'; // all, active, overdue, completed
  String? _error;
  Map<String, dynamic> _statistics = {};

  LoansStatus get status => _status;
  List<LoanModel> get loans =>
      _filtered.isEmpty && _searchQuery.isEmpty ? _loans : _filtered;
  String get searchQuery => _searchQuery;
  String get filterStatus => _filterStatus;
  String? get error => _error;
  Map<String, dynamic> get statistics => _statistics;

  Future<void> loadLoans(int userId) async {
    _status = LoansStatus.loading;
    notifyListeners();

    try {
      _loans = await _repo.getAllLoans(userId);
      _statistics = await _repo.getStatistics(userId);
      _applyFilters();
      _status = LoansStatus.loaded;
    } catch (e) {
      _error = 'فشل تحميل السلف';
      _status = LoansStatus.error;
    }

    notifyListeners();
  }

  Future<int?> addLoan(LoanModel loan) async {
    try {
      final id = await _repo.addLoan(loan);
      if (id > 0) {
        await loadLoans(loan.userId);
        return id;
      }
      return null;
    } catch (e) {
      _error = 'فشل إضافة السلف';
      notifyListeners();
      return null;
    }
  }

  Future<bool> updateLoan(LoanModel loan) async {
    try {
      final result = await _repo.updateLoan(loan);
      if (result) {
        await loadLoans(loan.userId);
      }
      return result;
    } catch (e) {
      _error = 'فشل تحديث السلف';
      notifyListeners();
      return false;
    }
  }

  Future<bool> markAsPaid(int loanId, int userId) async {
    try {
      final result = await _repo.markAsPaid(loanId);
      if (result) {
        await loadLoans(userId);
      }
      return result;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteLoan(int loanId, int userId) async {
    try {
      final result = await _repo.deleteLoan(loanId);
      if (result) {
        await loadLoans(userId);
      }
      return result;
    } catch (e) {
      return false;
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void setFilter(String status) {
    _filterStatus = status;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    var result = List<LoanModel>.from(_loans);

    // Apply search
    if (_searchQuery.isNotEmpty) {
      result = result
          .where((l) =>
              l.borrowerName.contains(_searchQuery) ||
              l.phoneNumber.contains(_searchQuery))
          .toList();
    }

    // Apply status filter
    if (_filterStatus != 'all') {
      result = result.where((l) {
        final cs = l.computedStatus;
        return cs == _filterStatus;
      }).toList();
    }

    _filtered = result;
  }

  Future<double> getDailyProfit(int userId, DateTime date) async {
    return await _repo.getDailyProfit(userId, date);
  }

  Future<double> getMonthlyProfit(int userId, int year, int month) async {
    return await _repo.getMonthlyProfit(userId, year, month);
  }

  Future<List<LoanModel>> getLoansDueSoon(int userId) async {
    return await _repo.getLoansDueSoon(userId);
  }

  List<LoanModel> get activeLoans => _loans
      .where((l) => l.computedStatus == AppConstants.statusActive)
      .toList();

  List<LoanModel> get overdueLoans => _loans
      .where((l) => l.computedStatus == AppConstants.statusOverdue)
      .toList();

  List<LoanModel> get completedLoans =>
      _loans.where((l) => l.status == AppConstants.statusCompleted).toList();

  void clearData() {
    _loans = [];
    _filtered = [];
    _searchQuery = '';
    _filterStatus = 'all';
    _error = null;
    _statistics = {};
    _status = LoansStatus.initial;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
