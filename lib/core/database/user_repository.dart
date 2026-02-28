import 'package:supabase_flutter/supabase_flutter.dart';
import 'database_helper.dart';
import '../../models/user_model.dart';

class UserRepository {
  final _supabase = Supabase.instance.client;

  Future<UserModel?> getUserByUsername(String username) async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .ilike('username', username)
          .maybeSingle();
      if (response == null) return null;
      return UserModel.fromMap(response);
    } on PostgrestException catch (e) {
      throw _mapSupabaseError(e);
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel?> getUserById(int id) async {
    try {
      final response =
          await _supabase.from('users').select().eq('id', id).maybeSingle();
      if (response == null) return null;
      return UserModel.fromMap(response);
    } on PostgrestException catch (e) {
      throw _mapSupabaseError(e);
    } catch (e) {
      return null;
    }
  }

  /// Finds the user, verifies password, and checks verification status
  Future<UserModel?> authenticate(String username, String password) async {
    try {
      final userRow = await _supabase
          .from('users')
          .select()
          .ilike('username', username)
          .maybeSingle();

      if (userRow == null) return null;

      final passwordHash = DatabaseHelper.hashPassword(password);
      if (userRow['password_hash'] != passwordHash) {
        throw Exception('wrong_password');
      }

      if (userRow['is_verified'] == false) {
        throw Exception('not_verified');
      }

      return UserModel.fromMap(userRow);
    } on PostgrestException catch (e) {
      throw _mapSupabaseError(e);
    }
  }

  Future<int> createUser(
      String username, String password, String fullName, String country) async {
    try {
      final now = DateTime.now().toUtc().toIso8601String();
      final response = await _supabase.from('users').insert({
        'username': username,
        'password_hash': DatabaseHelper.hashPassword(password),
        'full_name': fullName,
        'country': country,
        'created_at': now,
        'updated_at': now,
        'is_verified': false,
      }).select();

      if (response.isNotEmpty) {
        return response.first['id'] as int;
      }
      return 0;
    } on PostgrestException catch (e) {
      throw _mapSupabaseError(e);
    }
  }

  Future<void> updateOTP(String username, String code) async {
    await _supabase.from('users').update({
      'otp_code': code,
      'updated_at': DateTime.now().toUtc().toIso8601String()
    }).ilike('username', username);
  }

  Future<bool> verifyOTP(String username, String code) async {
    final response = await _supabase
        .from('users')
        .select('otp_code')
        .ilike('username', username)
        .maybeSingle();

    if (response != null && response['otp_code'] == code) {
      await _supabase.from('users').update(
          {'is_verified': true, 'otp_code': null}).ilike('username', username);
      return true;
    }
    return false;
  }

  Future<bool> updatePassword(int userId, String newPassword) async {
    try {
      await _supabase.from('users').update({
        'password_hash': DatabaseHelper.hashPassword(newPassword),
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      }).eq('id', userId);
      return true;
    } on PostgrestException catch (e) {
      throw _mapSupabaseError(e);
    } catch (e) {
      return false;
    }
  }

  Future<bool> usernameExists(String username) async {
    final user = await getUserByUsername(username);
    return user != null;
  }

  /// Maps a Supabase PostgrestException to a user-readable Exception
  Exception _mapSupabaseError(PostgrestException e) {
    final code = e.code ?? '';
    final msg = e.message.toLowerCase();

    if (code == '42P01' || msg.contains('relation') && msg.contains('exist')) {
      return Exception('db_table_missing');
    }
    if (code == '42501' ||
        msg.contains('permission denied') ||
        msg.contains('policy')) {
      return Exception('db_rls_error');
    }
    if (msg.contains('duplicate') ||
        msg.contains('unique') ||
        msg.contains('already exists')) {
      return Exception('db_duplicate');
    }
    if (msg.contains('network') ||
        msg.contains('socket') ||
        msg.contains('connection')) {
      return Exception('db_network');
    }
    return Exception('db_error:${e.message}');
  }
}
