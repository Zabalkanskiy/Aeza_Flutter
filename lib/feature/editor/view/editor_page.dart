import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class EditorPage extends StatefulWidget {
  const EditorPage({super.key});

  @override
  State<EditorPage> createState() => _EditorPageState();
}

class _EditorPageState extends State<EditorPage> {
  final picker = ImagePicker();
  Color _color = Colors.black;
  double _thickness = 4;
  bool _isEraser = false;
  final GlobalKey _repaintKey = GlobalKey();
  ui.Image? _bgImage;
  final List<_Stroke> _strokes = [];
  _Stroke? _current;

  Future<void> _pickImage() async {
    final x = await picker.pickImage(source: ImageSource.gallery);
    if (x == null) return;
    final bytes = await x.readAsBytes();

    ui.decodeImageFromList(bytes, (img) {
      if (mounted) {
        setState(() {
          _bgImage = img;
        });
      }
    });
  }

  Future<Uint8List> _renderImageBytes() async {
    final boundary =
    _repaintKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 3);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  Future<void> _save() async {
    final status = await Permission.photosAddOnly.request();
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Нет разрешения на сохранение')),
      );
      return;
    }
    final bytes = await _renderImageBytes();
    await ImageGallerySaverPlus.saveImage(
      bytes,
      quality: 100,
      name: 'Aeza_${const Uuid().v4()}',
    );
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Сохранено в галерею')));

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final id = const Uuid().v4();
      final ref = FirebaseStorage.instance.ref(
        'users/${user.uid}/images/$id.png',
      );
      await ref.putData(bytes, SettableMetadata(contentType: 'image/png'));
      final url = await ref.getDownloadURL();
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('images')
          .doc(id)
          .set({
        'id': id,
        'url': url,
        'createdAt': FieldValue.serverTimestamp(),
      });
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Загружено в Firebase')));
    }
  }

  Future<void> _share() async {
    final bytes = await _renderImageBytes();
    final xFile = XFile.fromData(
      bytes,
      mimeType: 'image/png',
      name: 'Aeza.png',
    );
    await Share.shareXFiles([xFile]);
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
          backgroundColor: Colors.transparent, // Делаем Scaffold прозрачным
          appBar: AppBar(

           // backgroundColor: Colors.transparent.withOpacity(0.3),
            backgroundColor: Color(0x10C4C4C4).withOpacity(0.2),
            elevation: 0, // Убираем тень
            title: const Text('Редактор', style: TextStyle(color: Color(0xFFEEEEEE)),),
            leading: IconButton(onPressed: (){Navigator.of(context).pop();}, icon: const Icon(Icons.keyboard_arrow_left, color: Color(0xFFEEEEEE))),
            actions: [
              IconButton(onPressed: _share, icon: const Icon(Icons.ios_share, color: Color(0xFFEEEEEE),)),
              IconButton(onPressed: _save, icon: const Icon(Icons.save, color: Color(0xFFEEEEEE),)),
            ],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.horizontal(
                left: Radius.circular(15),
                right: Radius.circular(15),
              ),
            ),


          ),
          body: Stack(
            children: [

              Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  children: [
                    _Toolbar(
                      color: _color,
                      thickness: _thickness,
                      isEraser: _isEraser,
                      onColor: (c) {
                        setState(() => _color = c);
                      },
                      onThickness: (v) {
                        setState(() => _thickness = v);
                      },
                      onEraser: (e) {
                        setState(() => _isEraser = e);
                      },
                      onImport: _pickImage,
                    ),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(16),
                        // height: MediaQuery.of(context).size.height * 0.8, // 80% высоты экрана
                        width: double.infinity, // На всю ширину
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey, width: 1), // Для визуализации границ
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: GestureDetector(
                          onPanStart: (d) {
                            final paint = Paint()
                              ..color = _isEraser ? Colors.white : _color
                              ..strokeWidth = _thickness
                              ..style = PaintingStyle.stroke
                              ..strokeCap = StrokeCap.round
                              ..isAntiAlias = true;

                            final path = Path()
                              ..moveTo(d.localPosition.dx, d.localPosition.dy)
                              ..lineTo(d.localPosition.dx, d.localPosition.dy);

                            _current = _Stroke(path, paint);
                            _strokes.add(_current!);
                            setState(() {});
                          },
                          onPanUpdate: (d) {
                            _current?.path.lineTo(d.localPosition.dx, d.localPosition.dy);
                            setState(() {});
                          },
                          onPanEnd: (_) {
                            _current = null;
                          },
                          child: RepaintBoundary(
                            key: _repaintKey,
                            child: CustomPaint(
                              painter: _CanvasPainter(_strokes, _bgImage),
                              child: const SizedBox.expand(), // гарантированно растягиваем
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Stroke {
  final Path path;
  final Paint paint;
  _Stroke(this.path, this.paint);
}

class _CanvasPainter extends CustomPainter {
  final List<_Stroke> strokes;
  final ui.Image? bgImage;

  _CanvasPainter(this.strokes, this.bgImage);

  @override
  void paint(Canvas canvas, Size size) {
   // canvas.drawColor(Colors.white, BlendMode.srcOver);
   //  canvas.drawRect(
   //    Rect.fromLTWH(0, 0, size.width, size.height),
   //    Paint()..color = Colors.white,
   //  );

    if (bgImage != null) {
      final src = Rect.fromLTWH(
        0,
        0,
        bgImage!.width.toDouble(),
        bgImage!.height.toDouble(),
      );
      final dst = Rect.fromLTWH(0, 0, size.width, size.height);
      canvas.drawImageRect(bgImage!, src, dst, Paint());
    }

    for (final s in strokes) {
      canvas.drawPath(s.path, s.paint);
    }
  }

  @override
  bool shouldRepaint(covariant _CanvasPainter oldDelegate) => true;
}

class _Toolbar extends StatelessWidget {
  final Color color;
  final double thickness;
  final bool isEraser;
  final ValueChanged<Color> onColor;
  final ValueChanged<double> onThickness;
  final ValueChanged<bool> onEraser;
  final VoidCallback onImport;
  const _Toolbar({
    required this.color,
    required this.thickness,
    required this.isEraser,
    required this.onColor,
    required this.onThickness,
    required this.onEraser,
    required this.onImport,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          //IconButton(onPressed: onImport, icon: const Icon(Icons.image)),
          SvgPicture.asset("assets/icon/ic_download.svg"),
          SizedBox(width: 12,),
          SvgPicture.asset("assets/icon/ic_image.svg"),
          SizedBox(width: 12,),
          SvgPicture.asset("assets/icon/ic_pencil.svg"),
          SizedBox(width: 12,),
          GestureDetector(
              onTap: () => onEraser(!isEraser),
              child: SvgPicture.asset("assets/icon/ic_lastic.svg")),
          SizedBox(width: 12,),
          GestureDetector(
              onTap: () async {
                final c = await showDialog<Color?>(
                  context: context,
                  builder: (_) =>
                      AlertDialog(
                        content: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            Colors.black,
                            Colors.white,
                            Colors.red,
                            Colors.green,
                            Colors.blue,
                            Colors.purple,
                            Colors.orange,
                          ]
                              .map(
                                (c) =>
                                InkWell(
                                  onTap: () => Navigator.pop(context, c),
                                  child: CircleAvatar(backgroundColor: c),
                                ),
                          )
                              .toList(),
                        ),
                      ),
                );
                if (c != null) onColor(c);
              },
              child: SvgPicture.asset("assets/icon/ic_palette.svg")),
          // IconButton(
          //   onPressed: () => onEraser(!isEraser),
          //   icon: Icon(isEraser ? Icons.brush : Icons.cleaning_services),
          // ),
          // Expanded(
          //   child: Slider(
          //     value: thickness,
          //     min: 1,
          //     max: 24,
          //     onChanged: onThickness,
          //   ),
          // ),
          // GestureDetector(
          //   onTap: () async {
          //     final c = await showDialog<Color?>(
          //       context: context,
          //       builder: (_) => AlertDialog(
          //         content: Wrap(
          //           spacing: 8,
          //           runSpacing: 8,
          //           children: [
          //             Colors.black,
          //             Colors.white,
          //             Colors.red,
          //             Colors.green,
          //             Colors.blue,
          //             Colors.purple,
          //             Colors.orange,
          //           ]
          //               .map(
          //                 (c) => InkWell(
          //               onTap: () => Navigator.pop(context, c),
          //               child: CircleAvatar(backgroundColor: c),
          //             ),
          //           )
          //               .toList(),
          //         ),
          //       ),
          //     );
          //     if (c != null) onColor(c);
          //   },
          //   child: CircleAvatar(radius: 12, backgroundColor: color),
          // ),
        ],
      ),
    );
  }
}
