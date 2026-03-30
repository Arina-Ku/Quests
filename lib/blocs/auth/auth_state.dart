import '../../models/user_model.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {
  final bool isLogin;
  AuthInitial({this.isLogin = true});
}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final UserModel user;
  Authenticated(this.user);
}

class Unauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}
