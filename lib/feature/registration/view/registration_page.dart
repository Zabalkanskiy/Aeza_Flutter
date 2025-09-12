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
  bool _isLogin = true;
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
              return SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    onChanged: _validateForm, // проверяем форму при каждом изменении
                    child: Column(
                      children: [
                        // Spacer для размещения формы по центру
                        Spacer(),

                        // Поля ввода с прозрачным фоном

                        Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 0),
                              child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text('Регистрация', style: TextStyle(color: Colors.white, fontFamily: 'Press Start 2P', fontSize: 20),)),
                            ),
                            SizedBox(height: 20,),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.2), // Полупрозрачный белый
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: Color(0xFF87858F), // Цвет #87858F
                                  width: 1.0, // Толщина 1 пиксель
                                ),

                              ),
                              padding: const EdgeInsets.all(16),
                              child: TextFormField(
                                controller: _name,
                                decoration: InputDecoration(
                                  labelText: 'Введите ваше имя',
                                  labelStyle: TextStyle(color: Colors.white),
                                  filled: true,
                                  fillColor: Colors.transparent,
                                  border: InputBorder.none,
                                ),
                                style: TextStyle(color: Colors.white),

                                validator: (v) => v != null
                                    ? null
                                    : 'Имя не может быть пустым',
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.2), // Полупрозрачный белый
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: Color(0xFF87858F), // Цвет #87858F
                                  width: 1.0, // Толщина 1 пиксель
                                ),
                              ),
                              padding: const EdgeInsets.all(16),
                              child: TextFormField(
                                controller: _email,
                                decoration: InputDecoration(
                                  labelText: 'Ваша электронная почта',
                                  labelStyle: TextStyle(color: Colors.white),
                                  filled: true,
                                  fillColor: Colors.transparent,
                                  border: InputBorder.none,
                                ),
                                style: TextStyle(color: Colors.white),
                                obscureText: false,
                                keyboardType: TextInputType.emailAddress,
                                validator: (v) => v != null && v.contains('@')
                                    ? null
                                    : 'Некорректная почта',
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.2), // Полупрозрачный белый
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: Color(0xFF87858F), // Цвет #87858F
                                  width: 1.0, // Толщина 1 пиксель
                                ),
                              ),
                              padding: const EdgeInsets.all(16),
                              child: TextFormField(
                                controller: _password,
                                decoration: InputDecoration(
                                  labelText: 'Пароль',
                                  labelStyle: TextStyle(color: Colors.white),
                                  filled: true,
                                  fillColor: Colors.transparent,
                                  border: InputBorder.none,
                                ),
                                style: TextStyle(color: Colors.white),
                                obscureText: true,
                                validator: (v) {
                                  if(v != _passwordRepeat.text) {
                                    return "Пароли не совпадают";
                                  }

                                  if(v != null && v.length >= 8) {
                                    return null;
                                  } else {
                                    return 'Минимум 8 символов';
                                  }

                                },
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.2), // Полупрозрачный белый
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: Color(0xFF87858F), // Цвет #87858F
                                  width: 1.0, // Толщина 1 пиксель
                                ),
                              ),
                              padding: const EdgeInsets.all(16),
                              child: TextFormField(
                                controller: _passwordRepeat,
                                decoration: InputDecoration(
                                  labelText: 'Подтверждение пароля',
                                  labelStyle: TextStyle(color: Colors.white),
                                  filled: true,
                                  fillColor: Colors.transparent,
                                  border: InputBorder.none,
                                ),
                                style: TextStyle(color: Colors.white),
                                obscureText: true,
                                validator: (v) {
                                  if(v != _password.text) {
                                    return "Пароли не совпадают";
                                  }

                                  if(v != null && v.length >= 8) {
                                    return null;
                                  } else {
                                    return 'Минимум 8 символов';
                                  }

                                },
                              ),
                            ),
                          ],

                        ),

                        // Spacer для размещения кнопок внизу
                        Spacer(),

                        // Кнопки привязанные к низу
                        Column(
                          children: [

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
                                onPressed: !_isFormValid
                                    ? () {}
                                    : () {
                                  final email = _email.text.trim();
                                  final pass = _password.text.trim();
                                  final name = _name.text.trim();
                                  context.read<AuthBloc>().add(
                                    AuthSignUp(email, pass, name),
                                  );
                                },
                                child: Text('Зарегистрироваться'),
                              ),
                            ),

                            SizedBox(height: 40,),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

