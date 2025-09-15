import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:aeza_flutter/core/save_image.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('save_image.dart', () {
    test('imageFromBase64String returns Image widget for valid base64', () {
      final bytes = Uint8List.fromList([0, 0, 0, 0]);
      final b64 = base64Encode(bytes);

      final widget = imageFromBase64String(b64);

      expect(widget, isNotNull);
    });

    test('convertImageToBase64 reads file bytes and encodes', () async {
      final tempDir = Directory.systemTemp.createTempSync();
      final file = File('${tempDir.path}/test.bin');
      final content = List<int>.generate(16, (i) => i);
      await file.writeAsBytes(content);

      final b64 = await convertImageToBase64(file.path);

      expect(b64, base64Encode(content));
    });
  });
}
