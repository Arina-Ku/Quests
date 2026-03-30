import 'dart:async';
import '../../repositories/auth_repository.dart';
import '../../models/user_model.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc {
  final AuthRepository _repository = AuthRepository();
  final _stateController = StreamController<AuthState>.broadcast();

  AuthState _currentState = AuthInitial();

  Stream<AuthState> get stateStream => _stateController.stream;
  AuthState get currentState => _currentState;

  AuthBloc() {
    _stateController.add(_currentState);
  }

  Future<void> handleEvent(AuthEvent event) async {
    if (event is LoginEvent) {
      await _handleLogin(event);
    } else if (event is RegisterEvent) {
      await _handleRegister(event);
    } else if (event is LogoutEvent) {
      await _handleLogout();
    } else if (event is CheckAuthEvent) {
      await _handleCheckAuth();
    } else if (event is SwitchAuthModeEvent) {
      _switchAuthMode();
    }
  }

  Future<void> _handleLogin(LoginEvent event) async {
    _updateState(AuthLoading());

    final user = await _repository.login(event.email, event.password);

    if (user != null) {
      _updateState(Authenticated(user));
    } else {
      _updateState(AuthError('Неверный email или пароль'));
    }
  }

  Future<void> _handleRegister(RegisterEvent event) async {
    _updateState(AuthLoading());

    final user = await _repository.register(event.user);

    if (user != null) {
      _updateState(Authenticated(user));
    } else {
      _updateState(AuthError('Email уже зарегистрирован'));
    }
  }

  Future<void> _handleLogout() async {
    await _repository.logout();
    _updateState(Unauthenticated());
  }

  Future<void> _handleCheckAuth() async {
    final user = await _repository.getCurrentUser();
    if (user != null) {
      _updateState(Authenticated(user));
    } else {
      _updateState(Unauthenticated());
    }
  }

  void _switchAuthMode() {
    if (_currentState is AuthInitial) {
      final current = _currentState as AuthInitial;
      _updateState(AuthInitial(isLogin: !current.isLogin));
    }
  }

  void _updateState(AuthState state) {
    _currentState = state;
    _stateController.add(state);
  }

  void dispose() {
    _stateController.close();
  }
}
