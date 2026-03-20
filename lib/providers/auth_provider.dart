import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:suwater_mobile/models/user.dart';
import 'package:suwater_mobile/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

enum AuthStatus { initial, authenticated, unauthenticated, loading }

class AuthState {
  final AuthStatus status;
  final User? user;
  final String? error;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.error,
  });

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? error,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: error,
    );
  }

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isLoading => status == AuthStatus.loading;
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repo;

  AuthNotifier(this._repo) : super(const AuthState()) {
    _tryRestoreSession();
  }

  Future<void> _tryRestoreSession() async {
    final user = await _repo.tryRestoreSession();
    if (user != null) {
      state = AuthState(status: AuthStatus.authenticated, user: user);
    } else {
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    try {
      final user = await _repo.login(email: email, password: password);
      state = AuthState(status: AuthStatus.authenticated, user: user);
    } catch (e) {
      String message = 'Login failed';
      if (e.toString().contains('Mobile access not enabled')) {
        message = 'Mobile access not enabled for this account';
      } else if (e.toString().contains('401')) {
        message = 'Invalid email or password';
      }
      state = AuthState(status: AuthStatus.unauthenticated, error: message);
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    try {
      final user = await _repo.register(
        name: name,
        email: email,
        password: password,
        phone: phone,
      );
      state = AuthState(status: AuthStatus.authenticated, user: user);
      return true;
    } catch (e) {
      String message = 'Registration failed';
      final errStr = e.toString();
      if (errStr.contains('409') || errStr.contains('already exists')) {
        message = 'Email already registered';
      } else if (errStr.contains('400')) {
        message = 'Invalid registration data';
      }
      state = AuthState(
        status: AuthStatus.unauthenticated,
        error: message,
      );
      return false;
    }
  }

  Future<void> logout() async {
    await _repo.logout();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(authRepositoryProvider));
});
