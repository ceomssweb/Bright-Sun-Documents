import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? get currentUser => _auth.currentUser;
  bool get isLoggedIn =>
      _auth.currentUser != null && _auth.currentUser!.emailVerified;
  String get userEmail => _auth.currentUser?.email ?? '';
  String get displayName => _auth.currentUser?.displayName ?? 'User';
  String get photoURL => _auth.currentUser?.photoURL ?? '';
  String get uid => _auth.currentUser?.uid ?? '';

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<String?> signIn(String email, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _setUserData(result.user!);
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  Future<String?> signUp(String email, String password, String username) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await result.user!.updateDisplayName(username);
      // Add to Emp-list
      await _database.ref('Emp-list').push().set({
        'mail': email,
        'name': username,
        'key': result.user!.uid,
      });
      await sendVerificationMail();
      await _setUserData(result.user!);
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  Future<String?> signUpWithPhoto(
      String email, String password, String username, dynamic fileBytes, String fileName) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await result.user!.updateDisplayName(username);
      await _database.ref('Emp-list').push().set({
        'mail': email,
        'name': username,
        'key': result.user!.uid,
      });

      // Upload profile picture
      final storageRef = FirebaseStorage.instance
          .ref('profile-picture/$email/$fileName');
      if (fileBytes is Uint8List) {
        await storageRef.putData(fileBytes);
      } else if (fileBytes is File) {
        await storageRef.putFile(fileBytes);
      }
      final downloadURL = await storageRef.getDownloadURL();
      await result.user!.updatePhotoURL(downloadURL);

      await sendVerificationMail();
      await _setUserData(result.user!);
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  Future<void> sendVerificationMail() async {
    await _auth.currentUser?.sendEmailVerification();
  }

  Future<String?> forgotPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  Future<String?> googleSignIn() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return 'Google sign-in cancelled';
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final result = await _auth.signInWithCredential(credential);
      await _setUserData(result.user!);
      notifyListeners();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
    notifyListeners();
  }

  Future<void> _setUserData(User user) async {
    final userData = UserModel(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName ?? '',
      photoURL: user.photoURL ?? '',
      emailVerified: user.emailVerified,
    );
    await _firestore
        .collection('users')
        .doc(user.uid)
        .set(userData.toMap(), SetOptions(merge: true));
  }

  DatabaseReference getEmpListRef() {
    return _database.ref('Emp-list');
  }
}
