import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:js/js.dart';

class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;
  String _error = '';
  
  User? get currentUser => _auth.currentUser;
  bool get isLoading => _isLoading;
  String get error => _error;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<T> handleThenable<T>(dynamic thenable) {
    if (kIsWeb) {
      final completer = Completer<T>();
      thenable.then(allowInterop((value) {
        completer.complete(value);
      }));
      return completer.future;
    }
    return Future.value();  
  }

  
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }


  void clearError() {
    _error = '';
    notifyListeners();
  }


  Future<void> signUp(String email, String password) async {
    try {
      _setLoading(true);
      clearError();
      
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
    } on FirebaseAuthException catch (e) {
      _setError(_handleAuthException(e));
      rethrow;
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

 
  Future<void> signIn(String email, String password) async {
    try {
      _setLoading(true);
      clearError();
      
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
    } on FirebaseAuthException catch (e) {
      _setError(_handleAuthException(e));
      rethrow;
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }


  Future<void> signOut() async {
    try {
      _setLoading(true);
      clearError();
      
      await _auth.signOut();
      
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  
  Future<void> resetPassword(String email) async {
    try {
      _setLoading(true);
      clearError();
      
      await _auth.sendPasswordResetEmail(email: email);
      
    } on FirebaseAuthException catch (e) {
      _setError(_handleAuthException(e));
      rethrow;
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }


  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'operation-not-allowed':
        return 'This operation is not allowed.';
      default:
        return 'An error occurred: ${e.message}';
    }
  }
}