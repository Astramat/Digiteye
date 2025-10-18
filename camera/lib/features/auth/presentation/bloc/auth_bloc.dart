import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// Bloc de gestion de l'authentification
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final AuthRepository authRepository;
  
  AuthBloc({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.authRepository,
  }) : super(const AuthInitial()) {
    on<LoginEvent>(_onLogin);
    on<RegisterEvent>(_onRegister);
    on<LogoutEvent>(_onLogout);
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<GetCurrentUserEvent>(_onGetCurrentUser);
    on<ForgotPasswordEvent>(_onForgotPassword);
    on<ResetPasswordEvent>(_onResetPassword);
    on<ChangePasswordEvent>(_onChangePassword);
    on<UpdateProfileEvent>(_onUpdateProfile);
    on<DeleteAccountEvent>(_onDeleteAccount);
  }
  
  /// Gestion de l'événement de connexion
  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    
    final result = await loginUseCase(LoginParams(
      email: event.email,
      password: event.password,
    ));
    
    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (user) => emit(AuthAuthenticated(user: user)),
    );
  }
  
  /// Gestion de l'événement d'inscription
  Future<void> _onRegister(RegisterEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    
    final result = await registerUseCase(RegisterParams(
      email: event.email,
      password: event.password,
      firstName: event.firstName,
      lastName: event.lastName,
      phone: event.phone,
    ));
    
    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (user) => emit(AuthAuthenticated(user: user)),
    );
  }
  
  /// Gestion de l'événement de déconnexion
  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    
    final result = await authRepository.logout();
    
    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (_) => emit(const AuthUnauthenticated()),
    );
  }
  
  /// Gestion de l'événement de vérification du statut d'authentification
  Future<void> _onCheckAuthStatus(CheckAuthStatusEvent event, Emitter<AuthState> emit) async {
    final result = await authRepository.isLoggedIn();
    
    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (isLoggedIn) {
        if (isLoggedIn) {
          add(const GetCurrentUserEvent());
        } else {
          emit(const AuthUnauthenticated());
        }
      },
    );
  }
  
  /// Gestion de l'événement de récupération de l'utilisateur actuel
  Future<void> _onGetCurrentUser(GetCurrentUserEvent event, Emitter<AuthState> emit) async {
    final result = await authRepository.getCurrentUser();
    
    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (user) {
        if (user != null) {
          emit(AuthAuthenticated(user: user));
        } else {
          emit(const AuthUnauthenticated());
        }
      },
    );
  }
  
  /// Gestion de l'événement de récupération du mot de passe
  Future<void> _onForgotPassword(ForgotPasswordEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    
    final result = await authRepository.forgotPassword(event.email);
    
    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (_) => emit(const AuthSuccess(message: 'Email de récupération envoyé')),
    );
  }
  
  /// Gestion de l'événement de réinitialisation du mot de passe
  Future<void> _onResetPassword(ResetPasswordEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    
    final result = await authRepository.resetPassword(
      token: event.token,
      newPassword: event.newPassword,
    );
    
    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (_) => emit(const AuthSuccess(message: 'Mot de passe réinitialisé avec succès')),
    );
  }
  
  /// Gestion de l'événement de changement de mot de passe
  Future<void> _onChangePassword(ChangePasswordEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    
    final result = await authRepository.changePassword(
      currentPassword: event.currentPassword,
      newPassword: event.newPassword,
    );
    
    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (_) => emit(const AuthSuccess(message: 'Mot de passe changé avec succès')),
    );
  }
  
  /// Gestion de l'événement de mise à jour du profil
  Future<void> _onUpdateProfile(UpdateProfileEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    
    // Créer un objet User à partir des données
    final currentState = state;
    if (currentState is AuthAuthenticated) {
      final updatedUser = currentState.user.copyWith(
        firstName: event.userData['firstName'] as String?,
        lastName: event.userData['lastName'] as String?,
        phone: event.userData['phone'] as String?,
        avatar: event.userData['avatar'] as String?,
      );
      
      final result = await authRepository.updateProfile(updatedUser);
      
      result.fold(
        (failure) => emit(AuthError(message: failure.message)),
        (user) => emit(ProfileUpdated(user: user)),
      );
    } else {
      emit(const AuthError(message: 'Utilisateur non authentifié'));
    }
  }
  
  /// Gestion de l'événement de suppression du compte
  Future<void> _onDeleteAccount(DeleteAccountEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    
    final result = await authRepository.deleteAccount();
    
    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (_) => emit(const AccountDeleted()),
    );
  }
}
