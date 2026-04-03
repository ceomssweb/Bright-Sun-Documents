import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';
import '../constants/app_constants.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? get currentUser => _auth.currentUser;
  bool get isLoggedIn => _auth.currentUser != null && _auth.currentUser!.emailVerified;
  String get userEmail => _auth.currentUser?.email ?? '';
  String get displayName => _auth.currentUser?.displayName ?? 'User';
  String get photoURL => _auth.currentUser?.photoURL ?? '';
  String get uid => _auth.currentUser?.uid ?? '';
  bool get isAdmin => userEmail == AppConstants.adminEmail;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<String?> signIn(String email, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(email: email.trim(), password: password);
      if (result.user != null && !result.user!.emailVerified) {
        return 'Please verify your email before signing in.';
      }
      await _setUserData(result.user!);
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      return _mapAuthError(e.code);
    } catch (e) {
      return 'Sign in failed. Please try again.';
    }
  }

  Future<String?> signUp(String email, String password, String username) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(email: email.trim(), password: password);
      await result.user!.updateDisplayName(username.trim());
      await _database.ref('Emp-list').push().set({
        'mail': email.trim(),
        'name': username.trim(),
        'key': result.user!.uid,
        'createdAt': DateTime.now().toIso8601String(),
      });
      await sendVerificationMail();
      await _setUserData(result.user!);
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      return _mapAuthError(e.code);
    } catch (e) {
      return 'Registration failed. Please try again.';
    }
  }

  Future<String?> signUpWithPhoto(
      String email, String password, String username, dynamic fileBytes, String fileName) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(email: email.trim(), password: password);
      await result.user!.updateDisplayName(username.trim());
      await _database.ref('Emp-list').push().set({
        'mail': email.trim(),
        'name': username.trim(),
        'key': result.user!.uid,
        'createdAt': DateTime.now().toIso8601String(),
      });

      final storageRef = FirebaseStorage.instance.ref('profile-picture/${email.trim()}/$fileName');
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
      return _mapAuthError(e.code);
    } catch (e) {
      return 'Registration failed. Please try again.';
    }
  }

  Future<void> sendVerificationMail() async {
    await _auth.currentUser?.sendEmailVerification();
  }

  Future<String?> forgotPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return null;
    } on FirebaseAuthException catch (e) {
      return _mapAuthError(e.code);
    } catch (e) {
      return 'Failed to send reset email. Please try again.';
    }
  }

  Future<String?> googleSignIn() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return 'Google sign-in cancelled';
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final result = await _auth.signInWithCredential(credential);
      await _setUserData(result.user!);
      notifyListeners();
      return null;
    } catch (e) {
      return 'Google sign-in failed. Please try again.';
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
      createdAt: DateTime.now(),
    );
    await _firestore.collection('users').doc(user.uid).set(userData.toMap(), SetOptions(merge: true));
  }

  DatabaseReference getEmpListRef() => _database.ref('Emp-list');

  String _mapAuthError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'invalid-email':
        return 'Invalid email address format.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait and try again.';
      case 'user-disabled':
        return 'This account has been disabled.';
      default:
        return 'Authentication error. Please try again.';
    }
  }
}
