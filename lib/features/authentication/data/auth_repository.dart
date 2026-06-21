import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/errors/app_exception.dart';

/// Encapsula o Firebase Authentication e traduz erros em [AppException].
class AuthRepository {
  AuthRepository(this._auth);

  final FirebaseAuth _auth;

  /// Stream do estado de autenticação (null = deslogado).
  Stream<User?> authStateChanges() => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<User> signIn({required String email, required String password}) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return credential.user!;
    } on FirebaseAuthException catch (e) {
      throw AuthErrorMapper.map(e.code);
    } catch (_) {
      throw AuthErrorMapper.map(null);
    }
  }

  Future<User> register({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return credential.user!;
    } on FirebaseAuthException catch (e) {
      throw AuthErrorMapper.map(e.code);
    } catch (_) {
      throw AuthErrorMapper.map(null);
    }
  }

  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw AuthErrorMapper.map(e.code);
    } catch (_) {
      throw AuthErrorMapper.map(null);
    }
  }

  Future<void> updatePassword(String newPassword) async {
    try {
      await _auth.currentUser?.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw AuthErrorMapper.map(e.code);
    } catch (_) {
      throw AuthErrorMapper.map(null);
    }
  }

  Future<void> signOut() => _auth.signOut();

  Future<void> deleteAccount() async {
    try {
      await _auth.currentUser?.delete();
    } on FirebaseAuthException catch (e) {
      throw AuthErrorMapper.map(e.code);
    } catch (_) {
      throw AuthErrorMapper.map(null);
    }
  }
}
