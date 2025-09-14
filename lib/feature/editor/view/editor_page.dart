import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:convert';
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:uuid/uuid.dart';

class EditorPage extends StatefulWidget {
  final Uint8List? imageBytes;
  final String? firebaseId; // ID записи в Realtime Database
  const EditorPage({super.key, this.imageBytes, this.firebaseId});

  @override
  State<EditorPage> createState() => _EditorPageState();
}

class _EditorPageState extends State<EditorPage> {
  final GlobalKey _containerKey = GlobalKey(); // Добавьте этот ключ
  final picker = ImagePicker();
  Color _color = Colors.black;
  double _thickness = 4;
  bool _isEraser = false;
  final GlobalKey _repaintKey = GlobalKey();
  ui.Image? _bgImage;
  final List<_Stroke> _strokes = [];
  _Stroke? _current;
  bool _isImageLoading = false;
  String? _firebasePath; // Добавьте это

  @override
  void initState() {
    super.initState();
    // Загружаем переданное изображение, если оно есть
    if (widget.imageBytes != null) {
      _loadImageFromBytes(widget.imageBytes!);
    }
  }

  Future<void> _loadImageFromBytes(Uint8List bytes) async {
    setState(() {
      _isImageLoading = true;
    });

    ui.decodeImageFromList(bytes, (img) {
      if (mounted) {
        setState(() {
          _bgImage = img;
          _isImageLoading = false;
        });
      }
    });
  }

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
    PermissionStatus status;

    // Для Android используем Permission.storage
    if (Platform.isAndroid) {
      status = await Permission.photos.request();
      //status = await Permission.storage.request();
    }
    // Для iOS используем Permission.photosAddOnly
    else if (Platform.isIOS) {
      status = await Permission.photos.request();
      //status = await Permission.photosAddOnly.request();
    } else {
      status = await Permission.photosAddOnly.request();
    }
    if (!status.isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Нет разрешения на сохранение')),
        );
      }
      return;
    }
    final bytes = await _renderImageBytes();

    // Сохраняем в галерею устройства
    await ImageGallerySaverPlus.saveImage(
      bytes,
      quality: 100,
      name: 'Aeza_${const Uuid().v4()}',
    );
    if (!mounted) return;
    // ScaffoldMessenger.of(
    //   context,
    // ).showSnackBar(const SnackBar(content: Text('Сохранено в галерею')));

    // Сохраняем в Firebase Realtime Database в base64
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final id = const Uuid().v4();
        final base64String = base64Encode(bytes);

        final database = FirebaseDatabase.instance.ref('aaaa/image/${user.uid}');
        if(widget.firebaseId!= null) {
          database.child(widget.firebaseId!).update({
              ///обновляем данные
              'id': widget.firebaseId!,
              'userId': user.uid,
              'base64': base64String,
              'createdAt': DateTime.now().millisecondsSinceEpoch,
          });
        } else {
          await database.child(id).set({
            'id': id,
            'userId': user.uid,
            'base64': base64String,
            'createdAt': DateTime
                .now()
                .millisecondsSinceEpoch,
          });
        }

        if (!mounted) return;
        Navigator.of(context).pop();
        //Navigator.canPop(context);
        // ScaffoldMessenger.of(
        //   context,
        // ).showSnackBar(const SnackBar(content: Text('Загружено в Firebase')));
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Ошибка загрузки: $e')));
      }
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
            centerTitle: true,
            title: const Text(
              'Новое изображение',
              style: TextStyle(color: Color(0xFFEEEEEE)),
            ),
            leading: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(
                Icons.keyboard_arrow_left,
                color: Color(0xFFEEEEEE),
              ),
            ),
            actions: [
              // IconButton(
              //   onPressed: _share,
              //   icon: const Icon(Icons.ios_share, color: Color(0xFFEEEEEE)),
              // ),
              IconButton(
                onPressed: _save,
                icon: const Icon(Icons.check, color: Color(0xFFEEEEEE)),
              ),
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
                      onSave: _save,
                      onShare: _share,
                    ),
                    Expanded(
                      child: Container(
                        key: _containerKey,
                       // padding: EdgeInsets.all(16),
                        // height: MediaQuery.of(context).size.height * 0.8, // 80% высоты экрана
                        width: double.infinity, // На всю ширину
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: Colors.grey,
                            width: 1,
                          ), // Для визуализации границ
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: GestureDetector(
                          onPanStart: (d) {
                            final box =
                                _containerKey.currentContext?.findRenderObject()
                                    as RenderBox;
                            final localPos = box.globalToLocal(
                              d.globalPosition,
                            );

                            if (!box.size.contains(localPos)) {
                              return; // Игнорируем касания вне области контейнера
                            }

                            if (!_isInside(localPos, box.size)) return;
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
                            final renderBox =
                                _containerKey.currentContext?.findRenderObject()
                                    as RenderBox;
                            final localPosition = renderBox.globalToLocal(
                              d.globalPosition,
                            );

                            if (!renderBox.size.contains(localPosition)) {
                              _current = null;
                              return;
                            }
                            _current?.path.lineTo(
                              d.localPosition.dx,
                              d.localPosition.dy,
                            );
                            setState(() {});
                          },
                          onPanEnd: (_) {
                            _current = null;
                          },
                          child: Stack(
                            children: [
                              RepaintBoundary(
                                key: _repaintKey,
                                child: CustomPaint(
                                  painter: _CanvasPainter(_strokes, _bgImage),
                                  child:
                                      const SizedBox.expand(), // гарантированно растягиваем
                                ),
                              ),

                              if (_isImageLoading)
                                const Center(child: CircularProgressIndicator()),
                            ],
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

bool _isInside(Offset pos, Size size) {
  return pos.dx >= 0 &&
      pos.dy >= 0 &&
      pos.dx <= size.width &&
      pos.dy <= size.height;
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

    // Обрезаем холст по скругленным углам
    final clipRect = Rect.fromLTWH(0, 0, size.width, size.height);
    final clipRadius = Radius.circular(25);
    canvas.clipRRect(RRect.fromRectAndRadius(clipRect, clipRadius));

    // Рисуем белый фон
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = Colors.white,
    );

    // // Рисуем фоновое изображение, если оно есть
    // if (bgImage != null) {
    //   // Сохраняем пропорции изображения
    //   final double imageRatio = bgImage!.width / bgImage!.height;
    //   final double canvasRatio = size.width / size.height;
    //
    //   Rect dstRect;
    //   if (imageRatio > canvasRatio) {
    //     // Изображение шире холста
    //     final double height = size.width / imageRatio;
    //     final double top = (size.height - height) / 2;
    //     dstRect = Rect.fromLTWH(0, top, size.width, height);
    //   } else {
    //     // Изображение выше холста
    //     final double width = size.height * imageRatio;
    //     final double left = (size.width - width) / 2;
    //     dstRect = Rect.fromLTWH(left, 0, width, size.height);
    //   }
    //
    //   final srcRect = Rect.fromLTWH(
    //     0,
    //     0,
    //     bgImage!.width.toDouble(),
    //     bgImage!.height.toDouble(),
    //   );
    //
    //   canvas.drawImageRect(bgImage!, srcRect, dstRect, Paint());
    // }

    // Рисуем фоновое изображение с эффектом BoxFit.cover
    if (bgImage != null) {
      final srcRect = Rect.fromLTWH(
        0,
        0,
        bgImage!.width.toDouble(),
        bgImage!.height.toDouble(),
      );

      final double imageRatio = bgImage!.width / bgImage!.height;
      final double canvasRatio = size.width / size.height;

      Rect dstRect;

      if (imageRatio > canvasRatio) {
        // изображение относительно шире → растягиваем по высоте
        final double newWidth = size.height * imageRatio;
        final double left = (size.width - newWidth) / 2;
        dstRect = Rect.fromLTWH(left, 0, newWidth, size.height);
      } else {
        // изображение относительно выше → растягиваем по ширине
        final double newHeight = size.width / imageRatio;
        final double top = (size.height - newHeight) / 2;
        dstRect = Rect.fromLTWH(0, top, size.width, newHeight);
      }

      canvas.drawImageRect(bgImage!, srcRect, dstRect, Paint());
    }

    // Рисуем штрихи поверх изображения
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
  final VoidCallback onSave;
  final VoidCallback onShare;
  const _Toolbar({
    required this.color,
    required this.thickness,
    required this.isEraser,
    required this.onColor,
    required this.onThickness,
    required this.onEraser,
    required this.onImport,
    required this.onSave,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          GestureDetector(
            onTap: onShare,
            child: SvgPicture.asset("assets/icon/ic_download.svg"),
          ),
          SizedBox(width: 12),
          GestureDetector(
            onTap: onImport,
            child: SvgPicture.asset("assets/icon/ic_image.svg"),
          ),
          SizedBox(width: 12),
          GestureDetector(
            onTap: () {
              double tempThickness = thickness; // Локальная переменная для диалога
              // Показать диалог для выбора толщины кисти
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Толщина кисти'),
                  content: StatefulBuilder(
                    builder: (context, setState) => Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Текущая толщина: ${tempThickness.toInt()}'),
                        Slider(
                          value: tempThickness,
                          min: 1,
                          max: 24,
                          divisions: 23,
                          onChanged: (value) {
                            setState(() {
                              tempThickness = value;
                            });
                            // Немедленно обновляем главное состояние
                            onThickness(value);
                          },
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Готово'),
                    ),
                  ],
                ),
              );
            },
            child: SvgPicture.asset("assets/icon/ic_pencil.svg"),
          ),
          SizedBox(width: 12),
          GestureDetector(
            onTap: () => onEraser(!isEraser),
            child: SvgPicture.asset("assets/icon/ic_lastic.svg"),
          ),
          SizedBox(width: 12),
          GestureDetector(
            onTap: () async {
              final c = await showDialog<Color?>(
                context: context,
                builder: (_) => AlertDialog(
                  content: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        [
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
            child: SvgPicture.asset("assets/icon/ic_palette.svg"),
          ),
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
