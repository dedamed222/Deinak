import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../constants/app_constants.dart';

class DatabaseHelper {
  static DatabaseHelper? _instance;
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() {
    _instance ??= DatabaseHelper._internal();
    return _instance!;
  }

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConstants.dbName);

    return await openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Users table
    await db.execute('''
      CREATE TABLE ${AppConstants.usersTable} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE COLLATE NOCASE,
        password_hash TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Loans table
    await db.execute('''
      CREATE TABLE ${AppConstants.loansTable} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        borrower_name TEXT NOT NULL,
        phone_number TEXT NOT NULL,
        loan_date TEXT NOT NULL,
        due_date TEXT NOT NULL,
        duration_label TEXT NOT NULL,
        duration_days INTEGER NOT NULL,
        card_company TEXT NOT NULL,
        card_category TEXT NOT NULL,
        card_value REAL NOT NULL,
        card_count INTEGER NOT NULL,
        profit_type TEXT NOT NULL,
        profit_value REAL NOT NULL,
        total_amount REAL NOT NULL,
        amount_with_profit REAL NOT NULL,
        status TEXT NOT NULL DEFAULT 'active',
        notes TEXT,
        paid_at TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES ${AppConstants.usersTable}(id)
      )
    ''');

    // Settings table
    await db.execute('''
      CREATE TABLE ${AppConstants.settingsTable} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL UNIQUE,
        default_profit_type TEXT NOT NULL DEFAULT 'percentage',
        default_profit_value REAL NOT NULL DEFAULT 10.0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES ${AppConstants.usersTable}(id)
      )
    ''');

    // Create default admin account
    final now = DateTime.now().toIso8601String();
    await db.insert(AppConstants.usersTable, {
      'username': 'admin',
      'password_hash': hashPassword('admin123'),
      'created_at': now,
      'updated_at': now,
    });
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Revert capital management migration logic was here
  }

  static String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
