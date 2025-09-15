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
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
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
                                  child: Text('Вход', style: TextStyle(color: Colors.white, fontFamily: 'Press Start 2P', fontSize: 20),)),
                            ),
                            SizedBox(height: 20,),
                            CustomInputField(
                              label: 'e-mail',
                              hintText: 'Введите электронную почту',
                              controller: _email,
                              keyboardType: TextInputType.emailAddress,
                              validator: (v) =>
                              v != null && v.contains('@') ? null : 'Некорректный email',
                            ),
                            // Container(
                            //   height: 78,
                            //   decoration: BoxDecoration(
                            //     color: Colors.black.withOpacity(0.2), // Полупрозрачный белый
                            //     borderRadius: BorderRadius.circular(15),
                            //     border: Border.all(
                            //       color: Color(0xFF87858F), // Цвет #87858F
                            //       width: 1.0, // Толщина 1 пиксель
                            //     ),
                            //
                            //   ),
                            //   padding: const EdgeInsets.all(8),
                            //   child: Column(
                            //     crossAxisAlignment: CrossAxisAlignment.start,
                            //     children: [
                            //       Padding(
                            //         padding: const EdgeInsets.only(left: 12, bottom: 4),
                            //         child: Text(
                            //           'E-mail',
                            //           style: TextStyle(
                            //             color: Colors.white,
                            //             fontSize: 14,
                            //             fontWeight: FontWeight.normal
                            //           ),
                            //         ),
                            //       ),
                            //       TextFormField(
                            //         controller: _email,
                            //         decoration: InputDecoration(
                            //           // labelText: 'Email',
                            //           // labelStyle: TextStyle(color: Colors.white,
                            //           //   height: 0.8, // уменьшаем межстрочный интервал
                            //           // ),
                            //          // contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                            //           hintText: 'Введите электронную почту',
                            //           hintStyle: TextStyle(color: Colors.white70,
                            //             decoration: TextDecoration.underline, // подчёркивание hint текста
                            //             ), // чтобы было видно на тёмном фоне
                            //           // enabledBorder: UnderlineInputBorder(
                            //           //   borderSide: BorderSide(color: Colors.white70),
                            //           // ),
                            //           // helperText: 'Введите электронную почту',
                            //           // helperStyle: TextStyle(color: Colors.white70,
                            //           //  // height: 0.2, // уменьшаем межстрочный интервал
                            //           //   ),
                            //           filled: true,
                            //           fillColor: Colors.transparent,
                            //           border: InputBorder.none,
                            //           isDense: true, // делает поле более "плотным"
                            //           contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 12), // убираем отступы
                            //         ),
                            //         style: TextStyle(color: Colors.white),
                            //         keyboardType: TextInputType.emailAddress,
                            //         validator: (v) => v != null && v.contains('@')
                            //             ? null
                            //             : 'Некорректный email',
                            //       ),
                            //       Padding(
                            //         padding: EdgeInsets.symmetric(horizontal: 12),
                            //         child: Divider(
                            //
                            //           height: 1, // высота разделителя
                            //           thickness: 1,
                            //           color: Colors.white70,
                            //         ),
                            //       )
                            //     ],
                            //   ),
                            // ),
                            const SizedBox(height: 12),
                            CustomInputField(
                              label: 'Подтверждение пароля',
                              hintText: 'Введите пароль',
                              controller: _password,
                              obscureText: true,
                                validator: (v) => v != null && v.length >= 8
                                      ? null
                                      : 'Минимум 8 символов',
                            ),
                            // Container(
                            //   decoration: BoxDecoration(
                            //     color: Colors.black.withOpacity(0.2), // Полупрозрачный белый
                            //     borderRadius: BorderRadius.circular(15),
                            //     border: Border.all(
                            //       color: Color(0xFF87858F), // Цвет #87858F
                            //       width: 1.0, // Толщина 1 пиксель
                            //     ),
                            //   ),
                            //   padding: const EdgeInsets.all(16),
                            //   child: TextFormField(
                            //     controller: _password,
                            //     decoration: InputDecoration(
                            //       labelText: 'Подтверждение пароля',
                            //       labelStyle: TextStyle(color: Colors.white),
                            //       // hintText: 'Введите пароль',
                            //       // hintStyle: TextStyle(color: Colors.white70),
                            //       helperText: 'Введите пароль',
                            //       helperStyle: TextStyle(color: Colors.white70),
                            //       filled: true,
                            //       fillColor: Colors.transparent,
                            //       border: InputBorder.none,
                            //     ),
                            //     style: TextStyle(color: Colors.white),
                            //     obscureText: true,
                            //     validator: (v) => v != null && v.length >= 8
                            //         ? null
                            //         : 'Минимум 8 символов',
                            //   ),
                            // ),
                          ],

                      ),

                      // Spacer для размещения кнопок внизу
                      Spacer(),

                      // Кнопки привязанные к низу
                      Column(
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
                              boxShadow: [
                                // BoxShadow(
                                //   color: Colors.grey.withOpacity(0.5),
                                //   spreadRadius: 1,
                                //   blurRadius: 5,
                                //   offset: const Offset(0, 3),
                                // ),
                              ],
                            ),
                            child: TextButton(
                              onPressed: state.isLoading
                                  ? null
                                  : () {
                                if (_formKey.currentState?.validate() != true) {
                                  return;
                                }
                                final email = _email.text.trim();
                                final pass = _password.text.trim();
                                  context.read<AuthBloc>().add(
                                    AuthSignIn(email, pass),
                                  );
                              },
                              child: Text(
                                "Войти",
                                style: const TextStyle(
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
                                  Navigator.of(context).pushNamed('/registration');
                              },
                              child: Text( "Регистрация"),
                            ),
                          ),

                          SizedBox(height: 40,),
                        ],
                      ),
                    ],
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



