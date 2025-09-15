import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import '../../auth/bloc/auth_bloc.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});
  @override
  State<RegistrationPage> createState() => _RegistrationPage();
}

class _RegistrationPage extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _name = TextEditingController();
  final _passwordRepeat = TextEditingController();
  bool _isFormValid = false; // Добавьте эту переменную

  void _validateForm() {
    setState(() {
      _isFormValid = _formKey.currentState?.validate() ?? false;
    });
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _name.dispose();
    _passwordRepeat.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;
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
          resizeToAvoidBottomInset: true, // ВАЖНО: позволяет экрану подниматься при клавиатуре
          appBar: AppBar(
              backgroundColor: Colors.transparent,
              //title: Text(_isLogin ? 'Вход' : 'Регистрация')
           ),
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
              return Stack(
                children: [
                  /// Скроллируемая форма
                  Center(
                    child: SingleChildScrollView(
                      //keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                      child: Form(
                        key: _formKey,
                        onChanged: _validateForm, // <- триггерим валидацию на каждом изменении
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Регистрация',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Press Start 2P',
                                  fontSize: 20,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            _buildTextField(
                              controller: _name,
                              label: 'Введите ваше имя',
                              validator: (v) =>
                              v != null && v.isNotEmpty ? null : 'Имя не может быть пустым',
                            ),
                            const SizedBox(height: 12),

                            _buildTextField(
                              controller: _email,
                              label: 'Ваша электронная почта',
                              keyboardType: TextInputType.emailAddress,
                              validator: (v) =>
                              v != null && v.contains('@') ? null : 'Некорректная почта',
                            ),
                            const SizedBox(height: 12),

                            _buildTextField(
                              controller: _password,
                              label: 'Пароль',
                              obscure: true,
                              validator: (v) {
                                if (v != _passwordRepeat.text) {
                                  return "Пароли не совпадают";
                                }
                                if (v != null && v.length >= 8) {
                                  return null;
                                }
                                return 'Минимум 8 символов';
                              },
                            ),
                            const SizedBox(height: 12),

                            _buildTextField(
                              controller: _passwordRepeat,
                              label: 'Подтверждение пароля',
                              obscure: true,
                              validator: (v) {
                                if (v != _password.text) {
                                  return "Пароли не совпадают";
                                }
                                if (v != null && v.length >= 8) {
                                  return null;
                                }
                                return 'Минимум 8 символов';
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  /// Кнопка фиксирована снизу


                      isKeyboardVisible ? const SizedBox.shrink() :

                   Align(
                        alignment: Alignment.bottomCenter,
                        child: SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _isFormValid ? Colors.white : Colors.grey.shade700,
                                  foregroundColor: _isFormValid ? Colors.black : Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                                onPressed: !_isFormValid
                                    ? () {}
                                    : () {
                                  if (_formKey.currentState?.validate() != true) return;
                                  context.read<AuthBloc>().add(
                                    AuthSignUp(
                                      _email.text.trim(),
                                      _password.text.trim(),
                                      _name.text.trim(),
                                    ),
                                  );
                                },
                                child: const Text('Зарегистрироваться'),
                              ),
                            ),
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

  /// Метод для отрисовки TextFormField
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    bool obscure = false,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFF87858F), width: 1.0),
      ),
      padding: const EdgeInsets.all(16),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white),
          border: InputBorder.none,
          filled: true,
          fillColor: Colors.transparent,
        ),
        validator: validator,
      ),
    );
  }
}
