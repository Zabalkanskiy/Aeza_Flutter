import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class StorageRepository {
  final FirebaseStorage storage;
  final FirebaseFirestore firestore;
  StorageRepository({required this.storage, required this.firestore});

  Future<String> uploadUserImage({
    required String userId,
    required Uint8List bytes,
  }) async {
    final String id = const Uuid().v4();
    final ref = storage.ref('users/$userId/images/$id.png');
    await ref.putData(bytes, SettableMetadata(contentType: 'image/png'));
    final url = await ref.getDownloadURL();
    await firestore
        .collection('users')
        .doc(userId)
        .collection('images')
        .doc(id)
        .set({'id': id, 'url': url, 'createdAt': FieldValue.serverTimestamp()});
    return url;
  }

  Stream<List<Map<String, dynamic>>> userImagesStream(String userId) {
    return firestore
        .collection('users')
        .doc(userId)
        .collection('images')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => d.data()).toList());
  }
}

