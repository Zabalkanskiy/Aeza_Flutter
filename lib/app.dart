import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'data/auth_repository.dart';
import 'feature/auth/bloc/auth_bloc.dart';
import 'feature/auth/view/auth_page.dart';
import 'feature/gallery/view/gallery_page.dart';
import 'feature/editor/view/editor_page.dart';

class AezaApp extends StatelessWidget {
  const AezaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) =>
              AuthBloc(AuthRepository(FirebaseAuth.instance))
                ..add(const AuthStarted()),
        ),
      ],
      child: MaterialApp(
        title: 'AezaFlutter',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/auth':
              return MaterialPageRoute(builder: (_) => const AuthPage());
            case '/gallery':
              return MaterialPageRoute(builder: (_) => const GalleryPage());
            case '/editor':
              return MaterialPageRoute(builder: (_) => const EditorPage());
            default:
              return MaterialPageRoute(
                builder: (_) {
                  final user = FirebaseAuth.instance.currentUser;
                  if (user == null) return const AuthPage();
                  return const GalleryPage();
                },
              );
          }
        },
      ),
    );
  }
}
