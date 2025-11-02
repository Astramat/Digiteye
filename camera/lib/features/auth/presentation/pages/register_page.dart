import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/inputs/custom_text_field.dart';
import '../../../../shared/services/navigation_service.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/repositories/auth_repository.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import 'home_page.dart';

/// Page d'inscription
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inscription'),
      ),
      body: BlocProvider(
        create: (context) => AuthBloc(
          loginUseCase: sl<LoginUseCase>(),
          registerUseCase: sl<RegisterUseCase>(),
          authRepository: sl<AuthRepository>(),
        ),
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthAuthenticated) {
              NavigationService.pushAndRemoveUntil(const HomePage());
            } else if (state is AuthError) {
              NavigationService.showErrorSnackBar(state.message);
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Créer un compte',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    
                    // Champ prénom
                    CustomTextField(
                      controller: _firstNameController,
                      label: 'Prénom',
                      hint: 'Entrez votre prénom',
                      textCapitalization: TextCapitalization.words,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Le prénom est requis';
                        }
                        if (value.length < 2) {
                          return 'Le prénom doit contenir au moins 2 caractères';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Champ nom
                    CustomTextField(
                      controller: _lastNameController,
                      label: 'Nom',
                      hint: 'Entrez votre nom',
                      textCapitalization: TextCapitalization.words,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Le nom est requis';
                        }
                        if (value.length < 2) {
                          return 'Le nom doit contenir au moins 2 caractères';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Champ email
                    EmailTextField(
                      controller: _emailController,
                      label: 'Email',
                      hint: 'Entrez votre email',
                    ),
                    const SizedBox(height: 16),
                    
                    // Champ téléphone
                    CustomTextField(
                      controller: _phoneController,
                      label: 'Téléphone',
                      hint: 'Entrez votre numéro de téléphone',
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          if (!RegExp(r'^(\+33|0)[1-9](\d{8})$').hasMatch(value.replaceAll(' ', '').replaceAll('-', ''))) {
                            return 'Format de téléphone invalide';
                          }
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Champ mot de passe
                    PasswordTextField(
                      controller: _passwordController,
                      label: 'Mot de passe',
                      hint: 'Entrez votre mot de passe',
                    ),
                    const SizedBox(height: 16),
                    
                    // Champ confirmation mot de passe
                    PasswordTextField(
                      controller: _confirmPasswordController,
                      label: 'Confirmer le mot de passe',
                      hint: 'Confirmez votre mot de passe',
                      isConfirm: true,
                      originalPassword: _passwordController.text,
                      validator: (value) {
                        if (value != _passwordController.text) {
                          return 'Les mots de passe ne correspondent pas';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    
                    // Bouton d'inscription
                    PrimaryButton(
                      text: 'S\'inscrire',
                      isLoading: state is AuthLoading,
                      onPressed: _register,
                      isFullWidth: true,
                    ),
                    const SizedBox(height: 16),
                    
                    // Lien de connexion
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Déjà un compte ? Se connecter'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
  
  void _register() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(RegisterEvent(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phone: _phoneController.text.trim().isNotEmpty ? _phoneController.text.trim() : null,
      ));
    }
  }
}
