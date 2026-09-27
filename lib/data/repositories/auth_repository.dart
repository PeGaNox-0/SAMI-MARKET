import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile_model.dart';

/// Authentication repository — wraps Supabase Auth
class AuthRepository {
  final SupabaseClient _supabase;

  AuthRepository(this._supabase);

  /// Current user
  User? get currentUser => _supabase.auth.currentUser;

  /// Auth state stream
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  /// Sign in with email + password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Register new user
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    String marketName = '',
  }) async {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
        'market_name': marketName,
      },
    );

    // Update profile if signup successful
    if (response.user != null) {
      await _supabase.from('profiles').upsert({
        'id': response.user!.id,
        'full_name': fullName,
        'market_name': marketName,
      });
    }

    return response;
  }

  /// Sign out
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  /// Reset password
  Future<void> resetPassword(String email) async {
    await _supabase.auth.resetPasswordForEmail(email);
  }

  /// Get user profile
  Future<ProfileModel?> getProfile() async {
    final user = currentUser;
    if (user == null) return null;

    final data = await _supabase
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    if (data == null) return null;
    return ProfileModel.fromJson(data);
  }

  /// Update profile
  Future<void> updateProfile(ProfileModel profile) async {
    await _supabase.from('profiles').update(profile.toJson()).eq('id', profile.id);
  }
}

/// Provider for auth repository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(Supabase.instance.client);
});

/// Stream provider for auth state
final authStateProvider = StreamProvider<AuthState>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

/// Provider for current user
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.asData?.value.session?.user ??
      ref.watch(authRepositoryProvider).currentUser;
});

