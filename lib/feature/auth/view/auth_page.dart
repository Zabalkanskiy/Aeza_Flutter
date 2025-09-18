import 'package:aeza_flutter/core/custom_input_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
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
  final bool _isLogin = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Общий фон для всего экрана
        Positioned.fill(
          child: Stack(
            children: [
              // Фоновое изображение
              Image.asset(
                'assets/image/background.png',
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,

              ),
              // SVG поверх изображения
              Positioned.fill(
                child: SvgPicture.asset(
                  'assets/icon/ic_background.svg',
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
        ),

        Scaffold(
          backgroundColor: Colors.transparent,
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
              backgroundColor: Colors.transparent,
              title: Text(_isLogin ? 'Вход' : 'Регистрация')),
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
              return Column(
                children: [
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: constraints.maxHeight, // заполняем экран
                            ),
                            child: IntrinsicHeight(
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center, // центр по вертикали
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        'Вход',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'Press Start 2P',
                                          fontSize: 20,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                
                                    CustomInputField(
                                      label: 'e-mail',
                                      hintText: 'Введите электронную почту',
                                      controller: _email,
                                      keyboardType: TextInputType.emailAddress,
                                      validator: (v) =>
                                      v != null && v.contains('@') ? null : 'Некорректный email',
                                    ),
                                    const SizedBox(height: 12),
                                
                                    CustomInputField(
                                      label: 'Пароль',
                                      hintText: 'Введите пароль',
                                      controller: _password,
                                      obscureText: true,
                                      validator: (v) =>
                                      v != null && v.length >= 8 ? null : 'Минимум 8 символов',
                                    ),
                                
                                    const SizedBox(height: 100), // запас под кнопки
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // ====== Кнопки прижаты к низу ======
                  SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: double.infinity,
                            height: 48,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF8924E7), Color(0xFF6A46F9)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: TextButton(
                              onPressed: state.isLoading
                                  ? null
                                  : () {
                                if (_formKey.currentState?.validate() !=
                                    true) return;

                                final email = _email.text.trim();
                                final pass = _password.text.trim();
                                context.read<AuthBloc>().add(
                                  AuthSignIn(email, pass),
                                );
                              },
                              child: const Text(
                                "Войти",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                              onPressed: state.isLoading
                                  ? null
                                  : () {
                                Navigator.of(context)
                                    .pushNamed('/registration');
                              },
                              child: const Text("Регистрация"),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }


}



