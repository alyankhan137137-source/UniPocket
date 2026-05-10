import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_provider.g.dart';

/// Defines the possible authentication states of a user.
enum AuthStatus { 
  /// The user is successfully signed in.
  authenticated, 
  /// The user is signed out or the session is invalid.
  unauthenticated, 
  /// The initial state before any auth check has completed.
  initial 
}

/// Represents the state of the user's authentication session.
class AuthState {
  /// The current status of the authentication.
  final AuthStatus status;
  
  /// The unique identifier of the authenticated user, if applicable.
  final String? userId;

  AuthState({required this.status, this.userId});
}

/// A notifier that manages the authentication state of the application.
/// 
/// This provider tracks whether a user is logged in and provides methods 
/// to update the auth status accordingly.
@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  AuthState build() {
    return AuthState(status: AuthStatus.initial);
  }

  /// Sets the state to authenticated with the provided [userId].
  void login(String userId) {
    state = AuthState(status: AuthStatus.authenticated, userId: userId);
  }

  /// Sets the state to unauthenticated, effectively logging the user out.
  void logout() {
    state = AuthState(status: AuthStatus.unauthenticated);
  }
}
