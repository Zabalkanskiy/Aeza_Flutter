import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class GalleryPage extends StatelessWidget {
  const GalleryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    final images = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('images')
        .orderBy('createdAt', descending: true)
        .snapshots();

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
            //leading: const Icon(Icons.exit_to_app),
            // leading: Transform.scale(
            //   scale: 0.5, // коэффициент масштабирования
            //   child: SvgPicture.asset("assets/icon/ic_login.svg"),
            // ),
            leading: GestureDetector(
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                if (context.mounted) {
                  Navigator.of(context).pushReplacementNamed('/auth');
                }
              },
              child: SvgPicture.asset(
                "assets/icon/ic_login.svg",
                width: 10,
                height: 10,
                fit: BoxFit.scaleDown, // или BoxFit.contain
              ),
            ),
            centerTitle: true,
            title: const Text('Галерея', style: TextStyle(color: Color(0xFFEEEEEE),),  textAlign: TextAlign.center, ),
            backgroundColor: Color(0x10C4C4C4).withOpacity(0.2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.horizontal(
                left: Radius.circular(15),
                right: Radius.circular(15),
              ),
            ),
          ),
          // floatingActionButton: FloatingActionButton(
          //   onPressed: () => Navigator.of(context).pushNamed('/editor'),
          //   child: const Icon(Icons.add),
          // ),
          body: Column(
            children: [
              Expanded(
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: images,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text('Нет изображений'));
                    }
                    final docs = snapshot.data!.docs;
                    return GridView.builder(
                      padding: const EdgeInsets.all(8),
                      gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 4,
                        mainAxisSpacing: 4,
                      ),
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final data = docs[index].data();
                        final base64String = data['base64'] as String?;
                        if (base64String == null) {
                          return const SizedBox.shrink();
                        }
                        try {
                          final bytes = base64Decode(base64String);
                          return GestureDetector(
                            onTap: () => Navigator.of(context).pushNamed(
                              '/editor',
                              arguments: bytes,
                            ),
                            child: Image.memory(
                              bytes,
                              fit: BoxFit.cover,
                            ),
                          );
                        } catch (e) {
                          return const Icon(Icons.error);
                        }
                      },
                    );
                  },
                ),
              ),
              // Кнопка "Создать" внизу экрана
              Container(
                width: double.infinity,
                height: 48,
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8924E7), Color(0xFF6A46F9)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: TextButton(
                  onPressed: () => Navigator.of(context).pushNamed('/editor'),
                  child: const Text(
                    "Создать",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 40,)
            ],
          ),
        ),
      ],
    );
  }
}

