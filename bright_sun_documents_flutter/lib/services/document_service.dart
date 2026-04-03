import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import '../models/client_user.dart';
import 'auth_service.dart';

class DocumentService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final AuthService _authService;

  DocumentService(this._authService);

  String get userPath => _authService.uid;

  DatabaseReference getUsersListRef() => _database.ref('Users-list/$userPath');

  DatabaseReference getEmpUsersRef(String empKey) => _database.ref('Users-list/$empKey');

  Future<void> addClient(ClientUser user, List<String> fileNames) async {
    final now = DateTime.now().toIso8601String();
    await getUsersListRef().push().set({
      ...user.toMap(),
      'originalNames': fileNames,
      'createdAt': now,
      'updatedAt': now,
    });
  }

  Future<void> updateClient(String key, Map<String, dynamic> updates) async {
    updates['updatedAt'] = DateTime.now().toIso8601String();
    await _database.ref('Users-list/$userPath/$key').update(updates);
  }

  Future<void> deleteClient(String key) async {
    await _database.ref('Users-list/$userPath/$key').remove();
  }

  Future<void> updateDocumentStatus(String empKey, String userKey, String status) async {
    await _database.ref('Users-list/$empKey/$userKey').update({
      'finalDocStatus': status,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  Future<String> uploadFile(Uint8List fileBytes, String fileName, String mobileNumber) async {
    final storageRef = FirebaseStorage.instance.ref('users-documents/$userPath/$mobileNumber/$fileName');
    await storageRef.putData(fileBytes);
    return await storageRef.getDownloadURL();
  }

  Future<List<String>> getUploadedFiles(String mobileNumber) async {
    try {
      final ref = FirebaseStorage.instance.ref('users-documents/$userPath/$mobileNumber');
      final result = await ref.listAll();
      return result.items.map((item) => item.name).toList();
    } catch (_) {
      return [];
    }
  }

  Future<String?> getFileDownloadUrl(String mobileNumber, String fileName) async {
    try {
      final ref = FirebaseStorage.instance.ref('users-documents/$userPath/$mobileNumber/$fileName');
      return await ref.getDownloadURL();
    } catch (_) {
      return null;
    }
  }
}
