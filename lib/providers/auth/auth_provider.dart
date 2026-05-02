import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_provider.g.dart';

enum AuthStatus { authenticated, unauthenticated, initial }

class AuthState {
  final AuthStatus status;
  final String? userId;

  AuthState({required this.status, this.userId});
}

@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  AuthState build() {
    return AuthState(status: AuthStatus.initial);
  }

  void login(String userId) {
    state = AuthState(status: AuthStatus.authenticated, userId: userId);
  }

  void logout() {
    state = AuthState(status: AuthStatus.unauthenticated);
  }
}
