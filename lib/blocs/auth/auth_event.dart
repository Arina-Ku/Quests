import '../../models/user_model.dart';

abstract class AuthEvent {}

class LoginEvent extends AuthEvent {
  final String email;
  final String password;
  LoginEvent({required this.email, required this.password});
}

class RegisterEvent extends AuthEvent {
  final UserModel user;
  RegisterEvent({required this.user});
}

class LogoutEvent extends AuthEvent {}

class CheckAuthEvent extends AuthEvent {}

class SwitchAuthModeEvent extends AuthEvent {}
