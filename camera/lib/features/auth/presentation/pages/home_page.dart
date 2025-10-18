import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../shared/widgets/buttons/secondary_button.dart';
import '../../../../shared/widgets/cards/custom_card.dart';
import '../../../../shared/services/navigation_service.dart';
import 'login_page.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/repositories/auth_repository.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/user_profile_widget.dart';

/// Page d'accueil
class HomePage extends StatelessWidget {
  const HomePage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc(
        loginUseCase: sl<LoginUseCase>(),
        registerUseCase: sl<RegisterUseCase>(),
        authRepository: sl<AuthRepository>(),
      )..add(const CheckAuthStatusEvent()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Accueil'),
          actions: [
            BlocConsumer<AuthBloc, AuthState>(
              listener: (context, state) {
                if (state is AuthUnauthenticated) {
                  NavigationService.pushAndRemoveUntil(const LoginPage());
                } else if (state is AuthError) {
                  NavigationService.showErrorSnackBar(state.message);
                }
              },
              builder: (context, state) {
                return IconButton(
                  onPressed: () {
                    context.read<AuthBloc>().add(const LogoutEvent());
                  },
                  icon: const Icon(Icons.logout),
                );
              },
            ),
          ],
        ),
        body: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (state is AuthAuthenticated) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Profil utilisateur
                    UserProfileWidget(user: state.user),
                    const SizedBox(height: 24),
                    
                    // Contenu principal
                    CustomCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bienvenue !',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Vous êtes maintenant connecté à l\'application. '
                            'Cette page d\'accueil peut être personnalisée selon vos besoins.',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 24),
                          
                          // Boutons d'action
                          Row(
                            children: [
                              Expanded(
                                child: SecondaryButton(
                                  text: 'Paramètres',
                                  icon: Icons.settings,
                                  onPressed: () {
                                    NavigationService.showInfoSnackBar('Fonctionnalité à venir');
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: SecondaryButton(
                                  text: 'Aide',
                                  icon: Icons.help_outline,
                                  onPressed: () {
                                    NavigationService.showInfoSnackBar('Fonctionnalité à venir');
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Informations de l'utilisateur
                    CustomCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Informations du compte',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildInfoRow('Email', state.user.email),
                          _buildInfoRow('Nom complet', state.user.fullName),
                          if (state.user.phone != null)
                            _buildInfoRow('Téléphone', state.user.phone!),
                          _buildInfoRow('Membre depuis', _formatDate(state.user.createdAt)),
                          _buildInfoRow('Email vérifié', state.user.isEmailVerified ? 'Oui' : 'Non'),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            } else if (state is AuthError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Erreur',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    SecondaryButton(
                      text: 'Réessayer',
                      onPressed: () {
                        context.read<AuthBloc>().add(const CheckAuthStatusEvent());
                      },
                    ),
                  ],
                ),
              );
            } else {
              return const Center(
                child: Text('État inconnu'),
              );
            }
          },
        ),
      ),
    );
  }
  
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
