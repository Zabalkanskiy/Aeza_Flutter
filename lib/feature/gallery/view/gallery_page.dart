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
            leading: SvgPicture.asset(
              "assets/icon/ic_login.svg",
              width: 10,
              height: 10,
              fit: BoxFit.scaleDown, // или BoxFit.contain
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
            actions: [
              IconButton(
                icon: const Icon(Icons.exit_to_app),
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  if (context.mounted) {
                    Navigator.of(context).pushReplacementNamed('/auth');
                  }
                },
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => Navigator.of(context).pushNamed('/editor'),
            child: const Icon(Icons.add),
          ),
          body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: images,
            builder: (context, snapshot) {
              if (!snapshot.hasData)
                return const Center(child: CircularProgressIndicator());
              final docs = snapshot.data!.docs;
              if (docs.isEmpty) return const Center(child: Text('Нет изображений'));
              return GridView.builder(
                padding: const EdgeInsets.all(8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                ),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final data = docs[index].data();
                  final url = data['url'] as String?;
                  if (url == null) return const SizedBox.shrink();
                  return GestureDetector(
                    onTap: () =>
                        Navigator.of(context).pushNamed('/editor', arguments: url),
                    child: Image.network(url, fit: BoxFit.cover),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

