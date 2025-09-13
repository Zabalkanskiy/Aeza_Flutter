import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

Future<String> convertImageToBase64(String imagePath) async {
  // Чтение файла в байты
  List<int> imageBytes = await File(imagePath).readAsBytes();
  // Кодирование байтов в строку Base64
  String base64String = base64Encode(imageBytes);
  return base64String;
}

// Для преобразования из base64 обратно в изображение
Image imageFromBase64String(String base64String) {
  // Декодирование строки Base64 в байты
  Uint8List bytes = base64Decode(base64String);
  // Создание виджета Image из байтов
  return Image.memory(bytes);
}