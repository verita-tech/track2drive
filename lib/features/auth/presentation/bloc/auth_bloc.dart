import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:track2drive/features/auth/domain/entities/user_entity.dart';
import 'package:track2drive/features/auth/domain/usecases/login_usecase.dart';
import 'package:track2drive/features/auth/domain/usecases/logout_usecase.dart';
import 'package:track2drive/features/auth/domain/usecases/register_usecase.dart';
import 'package:track2drive/features/auth/domain/usecases/send_reset_email_usecase.dart';

sealed class AuthEvent {}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;
  AuthLoginRequested(this.email, this.password);
}

class AuthRegisterRequested extends AuthEvent {
  final String email;
  final String password;
  AuthRegisterRequested(this.email, this.password);
}

class AuthSendResetEmailRequested extends AuthEvent {
  final String email;
  AuthSendResetEmailRequested(this.email);
}

class AuthLogoutRequested extends AuthEvent {}

class AuthUserChanged extends AuthEvent {
  final UserEntity? user;
  AuthUserChanged(this.user);
}

class AuthState {
  final UserEntity? user;
  final bool loading;
  final String? error;
  final String? info;

  const AuthState({this.user, this.loading = false, this.error, this.info});

  AuthState copyWith({
    UserEntity? user,
    bool? loading,
    String? error,
    String? info,
  }) {
    return AuthState(
      user: user ?? this.user,
      loading: loading ?? this.loading,
      error: error,
      info: info,
    );
  }

  factory AuthState.initial() => const AuthState();
}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase _login;
  final RegisterUseCase _register;
  final SendResetEmailUseCase _sendReset;
  final LogoutUseCase _logout;

  AuthBloc({
    required LoginUseCase login,
    required RegisterUseCase register,
    required SendResetEmailUseCase sendReset,
    required LogoutUseCase logout,
    required Stream<UserEntity?> authStateStream,
  }) : _login = login,
       _register = register,
       _sendReset = sendReset,
       _logout = logout,
       super(AuthState.initial()) {
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthSendResetEmailRequested>(_onSendResetRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthUserChanged>(_onUserChanged);

    authStateStream.listen((user) => add(AuthUserChanged(user)));
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(loading: true, error: null, info: null));
    try {
      final user = await _login(
        LoginParams(email: event.email, password: event.password),
      );
      emit(state.copyWith(user: user, loading: false));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(loading: true, error: null, info: null));
    try {
      final user = await _register(
        RegisterParams(email: event.email, password: event.password),
      );
      emit(state.copyWith(user: user, loading: false));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<void> _onSendResetRequested(
    AuthSendResetEmailRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(loading: true, error: null, info: null));
    try {
      await _sendReset(event.email);
      emit(
        state.copyWith(
          loading: false,
          info: 'E-Mail zum Zurücksetzen wurde gesendet.',
        ),
      );
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(loading: true, error: null, info: null));
    try {
      await _logout();
      emit(AuthState.initial());
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  void _onUserChanged(AuthUserChanged event, Emitter<AuthState> emit) {
    emit(state.copyWith(user: event.user));
  }
}
