import '../core/constants/app_constants.dart';

class LoanModel {
  final int? id;
  final int userId;
  final String borrowerName;
  final String phoneNumber;
  final DateTime loanDate;
  final DateTime dueDate;
  final String durationLabel;
  final int durationDays;
  final String cardCompany;
  final String cardCategory;
  final double cardValue;
  final int cardCount;
  final String profitType; // 'fixed' or 'percentage'
  final double profitValue;
  final double totalAmount;
  final double amountWithProfit;
  final String status; // 'active', 'overdue', 'completed'
  final String? notes;
  final DateTime? paidAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  LoanModel({
    this.id,
    required this.userId,
    required this.borrowerName,
    required this.phoneNumber,
    required this.loanDate,
    required this.dueDate,
    required this.durationLabel,
    required this.durationDays,
    required this.cardCompany,
    required this.cardCategory,
    required this.cardValue,
    required this.cardCount,
    required this.profitType,
    required this.profitValue,
    required this.totalAmount,
    required this.amountWithProfit,
    this.status = AppConstants.statusActive,
    this.notes,
    this.paidAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // Calculate total amount from card count and value
  static double calcTotal(double cardValue, int cardCount) {
    return cardValue * cardCount;
  }

  // Calculate profit
  static double calcProfit(
      double total, String profitType, double profitValue) {
    if (profitType == AppConstants.profitTypePercentage) {
      return total * profitValue / 100;
    }
    return profitValue;
  }

  // Calculate final amount with profit
  static double calcAmountWithProfit(
      double total, String profitType, double profitValue) {
    return total + calcProfit(total, profitType, profitValue);
  }

  // Determine status based on dates
  String get computedStatus {
    if (status == AppConstants.statusCompleted) return status;
    final now = DateTime.now();
    if (now.isAfter(dueDate)) return AppConstants.statusOverdue;
    return AppConstants.statusActive;
  }

  // Hours until due
  int get hoursUntilDue {
    return dueDate.difference(DateTime.now()).inHours;
  }

  // Is due within 24 hours
  bool get isDueWithin24Hours {
    final hours = hoursUntilDue;
    return hours >= 0 && hours <= 24;
  }

  // Profit amount
  double get profitAmount {
    return amountWithProfit - totalAmount;
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'borrower_name': borrowerName,
      'phone_number': phoneNumber,
      'loan_date': loanDate.toIso8601String(),
      'due_date': dueDate.toIso8601String(),
      'duration_label': durationLabel,
      'duration_days': durationDays,
      'card_company': cardCompany,
      'card_category': cardCategory,
      'card_value': cardValue,
      'card_count': cardCount,
      'profit_type': profitType,
      'profit_value': profitValue,
      'total_amount': totalAmount,
      'amount_with_profit': amountWithProfit,
      'status': status,
      'notes': notes,
      'paid_at': paidAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory LoanModel.fromMap(Map<String, dynamic> map) {
    return LoanModel(
      id: map['id'],
      userId: map['user_id'],
      borrowerName: map['borrower_name'],
      phoneNumber: map['phone_number'],
      loanDate: DateTime.parse(map['loan_date']),
      dueDate: DateTime.parse(map['due_date']),
      durationLabel: map['duration_label'],
      durationDays: map['duration_days'],
      cardCompany: map['card_company'],
      cardCategory: map['card_category'],
      cardValue: (map['card_value'] as num).toDouble(),
      cardCount: map['card_count'],
      profitType: map['profit_type'],
      profitValue: (map['profit_value'] as num).toDouble(),
      totalAmount: (map['total_amount'] as num).toDouble(),
      amountWithProfit: (map['amount_with_profit'] as num).toDouble(),
      status: map['status'],
      notes: map['notes'],
      paidAt: map['paid_at'] != null ? DateTime.parse(map['paid_at']) : null,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  LoanModel copyWith({
    int? id,
    int? userId,
    String? borrowerName,
    String? phoneNumber,
    DateTime? loanDate,
    DateTime? dueDate,
    String? durationLabel,
    int? durationDays,
    String? cardCompany,
    String? cardCategory,
    double? cardValue,
    int? cardCount,
    String? profitType,
    double? profitValue,
    double? totalAmount,
    double? amountWithProfit,
    String? status,
    String? notes,
    DateTime? paidAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LoanModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      borrowerName: borrowerName ?? this.borrowerName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      loanDate: loanDate ?? this.loanDate,
      dueDate: dueDate ?? this.dueDate,
      durationLabel: durationLabel ?? this.durationLabel,
      durationDays: durationDays ?? this.durationDays,
      cardCompany: cardCompany ?? this.cardCompany,
      cardCategory: cardCategory ?? this.cardCategory,
      cardValue: cardValue ?? this.cardValue,
      cardCount: cardCount ?? this.cardCount,
      profitType: profitType ?? this.profitType,
      profitValue: profitValue ?? this.profitValue,
      totalAmount: totalAmount ?? this.totalAmount,
      amountWithProfit: amountWithProfit ?? this.amountWithProfit,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      paidAt: paidAt ?? this.paidAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
