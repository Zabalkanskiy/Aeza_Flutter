import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../auth/bloc/auth_bloc.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});
  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _isLogin = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isLogin ? 'Вход' : 'Регистрация')),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          }
          if (state.user != null) {
            Navigator.of(context).pushReplacementNamed('/gallery');
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _email,
                    decoration: const InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) => v != null && v.contains('@')
                        ? null
                        : 'Некорректный email',
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _password,
                    decoration: const InputDecoration(labelText: 'Пароль'),
                    obscureText: true,
                    validator: (v) => v != null && v.length >= 6
                        ? null
                        : 'Минимум 6 символов',
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: state.isLoading
                          ? null
                          : () {
                              if (_formKey.currentState?.validate() != true)
                                return;
                              final email = _email.text.trim();
                              final pass = _password.text.trim();
                              if (_isLogin) {
                                context.read<AuthBloc>().add(
                                  AuthSignIn(email, pass),
                                );
                              } else {
                                context.read<AuthBloc>().add(
                                  AuthSignUp(email, pass),
                                );
                              }
                            },
                      child: Text(_isLogin ? 'Войти' : 'Зарегистрироваться'),
                    ),
                  ),
                  TextButton(
                    onPressed: () => setState(() => _isLogin = !_isLogin),
                    child: Text(
                      _isLogin
                          ? 'Нет аккаунта? Регистрация'
                          : 'Есть аккаунт? Вход',
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

