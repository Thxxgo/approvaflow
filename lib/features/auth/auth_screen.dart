import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/app_colors.dart';
import 'auth_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _isRegisterMode = false;
  UserRole _selectedRole = UserRole.solicitante;

  void _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showError('Por favor completa todos los campos');
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_isRegisterMode) {
        await _authService.register(
          email: email,
          password: password,
          role: _selectedRole,
        );
      } else {
        await _authService.login(email, password);
      }

      final user = _authService.currentUser;
      if (user == null) return;

      final role = await _authService.getUserRole(user.uid);

      if (mounted) {
        role == UserRole.aprobador
            ? context.go('/approvals')
            : context.go('/requests');
      }
    } on Exception catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.rejected,
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.verified_user_rounded,
                size: 64,
                color: Colors.white,
              ),
              const SizedBox(height: 16),
              const Text(
                'ApprovaFlow',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Text(
                'Aprobaciones sin fricción',
                style: TextStyle(fontSize: 14, color: Colors.white60),
              ),
              const SizedBox(height: 48),
              Card(
                color: AppColors.background,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        _isRegisterMode ? 'Registrarse' : 'Iniciar sesión',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Email
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(color: AppColors.textPrimary),
                        decoration: InputDecoration(
                          labelText: 'Correo electrónico',
                          prefixIcon: const Icon(Icons.email_outlined,
                              color: AppColors.primary),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                                color: AppColors.primary, width: 2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Contraseña
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        style: const TextStyle(color: AppColors.textPrimary),
                        decoration: InputDecoration(
                          labelText: 'Contraseña',
                          prefixIcon: const Icon(Icons.lock_outlined,
                              color: AppColors.primary),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                                color: AppColors.primary, width: 2),
                          ),
                        ),
                      ),

                      // Selector de rol (solo en registro)
                      if (_isRegisterMode) ...[
                        const SizedBox(height: 16),
                        DropdownButtonFormField<UserRole>(
                          value: _selectedRole,
                          decoration: InputDecoration(
                            labelText: 'Rol',
                            prefixIcon: const Icon(Icons.badge_outlined,
                                color: AppColors.primary),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                  color: AppColors.primary, width: 2),
                            ),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: UserRole.solicitante,
                              child: Text('Solicitante'),
                            ),
                            DropdownMenuItem(
                              value: UserRole.aprobador,
                              child: Text('Aprobador'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _selectedRole = value);
                            }
                          },
                        ),
                      ],

                      const SizedBox(height: 24),

                      // Botón principal
                      ElevatedButton(
                        onPressed: _isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                _isRegisterMode
                                    ? 'Crear cuenta'
                                    : 'Iniciar sesión',
                                style: const TextStyle(fontSize: 16),
                              ),
                      ),

                      const SizedBox(height: 12),

                      // Cambiar entre login y registro
                      TextButton(
                        onPressed: () {
                          setState(() => _isRegisterMode = !_isRegisterMode);
                        },
                        child: Text(
                          _isRegisterMode
                              ? '¿Ya tienes cuenta? Inicia sesión'
                              : '¿No tienes cuenta? Regístrate',
                          style: const TextStyle(color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
