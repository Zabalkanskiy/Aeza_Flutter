import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Редактор'),
        actions: [
          IconButton(onPressed: _share, icon: const Icon(Icons.ios_share)),
          IconButton(onPressed: _save, icon: const Icon(Icons.save)),
        ],
      ),
      body: Column(
        children: [
          Expanded(
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
        ],
      ),
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
    canvas.drawColor(Colors.white, BlendMode.srcOver);

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
      color: Colors.grey.shade100,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          IconButton(onPressed: onImport, icon: const Icon(Icons.image)),
          IconButton(
            onPressed: () => onEraser(!isEraser),
            icon: Icon(isEraser ? Icons.brush : Icons.cleaning_services),
          ),
          Expanded(
            child: Slider(
              value: thickness,
              min: 1,
              max: 24,
              onChanged: onThickness,
            ),
          ),
          GestureDetector(
            onTap: () async {
              final c = await showDialog<Color?>(
                context: context,
                builder: (_) => AlertDialog(
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
                          (c) => InkWell(
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
            child: CircleAvatar(radius: 12, backgroundColor: color),
          ),
        ],
      ),
    );
  }
}
