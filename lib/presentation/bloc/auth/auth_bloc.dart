import 'package:clean_architecture/domain/usecases/get_current_user.dart';
import 'package:clean_architecture/domain/usecases/reset_password.dart';
import 'package:clean_architecture/domain/usecases/sign_in.dart';
import 'package:clean_architecture/domain/usecases/sign_out.dart';
import 'package:clean_architecture/domain/usecases/sign_up.dart';
import 'package:clean_architecture/presentation/bloc/auth/auth_event.dart';
import 'package:clean_architecture/presentation/bloc/auth/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignIn _signIn;
  final SignUp _signUp;
  final SignOut _signOut;
  final GetCurrentUser _getCurrentUser;
  final ResetPassword _resetPassword;

  AuthBloc({
    required SignIn signIn,
    required SignUp signUp,
    required SignOut signOut,
    required GetCurrentUser getCurrentUser,
    required ResetPassword resetPassword,
  })  : _signIn = signIn,
        _signUp = signUp,
        _signOut = signOut,
        _getCurrentUser = getCurrentUser,
        _resetPassword = resetPassword,
        super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthSignInRequested>(_onAuthSignInRequested);
    on<AuthSignUpRequested>(_onAuthSignUpRequested);
    on<AuthSignOutRequested>(_onAuthSignOutRequested);
    on<AuthPasswordResetRequested>(_onAuthPasswordResetRequested);
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    final result = await _getCurrentUser();
    result.fold(
      (error) => emit(AuthError(error)),
      (user) {
        if (user != null) {
          emit(AuthAuthenticated(user));
        } else {
          emit(AuthUnauthenticated());
        }
      },
    );
  }

  Future<void> _onAuthSignInRequested(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    final result = await _signIn(
      email: event.email,
      password: event.password,
    );
    
    result.fold(
      (error) => emit(AuthError(error)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onAuthSignUpRequested(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    final result = await _signUp(
      email: event.email,
      password: event.password,
      fullName: event.fullName,
      phone: event.phone,
      roleId: event.roleId,
    );
    
    result.fold(
      (error) => emit(AuthError(error)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onAuthSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    final result = await _signOut();
    result.fold(
      (error) => emit(AuthError(error)),
      (_) => emit(AuthUnauthenticated()),
    );
  }

  Future<void> _onAuthPasswordResetRequested(
    AuthPasswordResetRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    final result = await _resetPassword(event.email);
    result.fold(
      (error) => emit(AuthError(error)),
      (_) => emit(AuthPasswordResetSent(event.email)),
    );
  }
}
