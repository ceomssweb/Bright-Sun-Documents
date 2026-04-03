import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import '../models/client_user.dart';
import 'auth_service.dart';

class UsersDocumentsService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final AuthService _authService;

  static const String adminUser = 'saravanan039@hotmail.com';

  String get userPath => _authService.uid;

  UsersDocumentsService(this._authService);

  DatabaseReference getUsersListRef() {
    return _database.ref('Users-list/$userPath');
  }

  DatabaseReference getEmpUsersRef(String empKey) {
    return _database.ref('Users-list/$empKey');
  }

  Future<void> addUser(ClientUser user, List<String> fileNames, String finalDocStatus) async {
    await getUsersListRef().push().set({
      ...user.toMap(),
      'originalNames': fileNames,
      'finalDocStatus': finalDocStatus,
    });
  }

  Future<void> updateUser(String key, ClientUser user, List<String> fileNames) async {
    await _database.ref('Users-list/$userPath/$key').update({
      'fullName': user.fullName,
      'fatherName': user.fatherName,
      'email': user.email,
      'selectedDoc': user.selectedDoc,
      'currentOwnerName': user.currentOwnerName,
      'currentOwnerAddress': user.currentOwnerAddress,
      'currentOwnerAge': user.currentOwnerAge,
      'currentOwnergender': user.currentOwnergender,
      'selectBuyerRelation': user.selectBuyerRelation,
      'buyerName': user.buyerName,
      'buyerAddress': user.buyerAddress,
      'buyerAge': user.buyerAge,
      'selectedBuyGender': user.selectedBuyGender,
      'originalNames': fileNames,
      'paymentStatus': user.paymentStatus,
    });
  }

  Future<void> deleteUser(String key) async {
    await _database.ref('Users-list/$userPath/$key').remove();
  }

  Future<void> uploadFinalDoc(String empKey, String userKey, String fileName) async {
    await _database.ref('Users-list/$empKey/$userKey').update({
      'finalDocStatus': fileName,
    });
  }

  Future<String> uploadFile(Uint8List fileBytes, String fileName, String mobileNumber) async {
    final storageRef = FirebaseStorage.instance
        .ref('users-documents/$userPath/$mobileNumber/$fileName');
    await storageRef.putData(fileBytes);
    return await storageRef.getDownloadURL();
  }
}
