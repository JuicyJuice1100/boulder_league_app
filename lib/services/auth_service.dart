import 'package:boulder_league_app/models/base_return_object.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<BaseReturnObject> login(String email, String password) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password
      );
      
      return BaseReturnObject(
        success: true,
        message: 'Login successful'
      );
    } on FirebaseAuthException catch (error) {
      return BaseReturnObject(
        success: false,
        message: error.message ?? 'Unknown Firebase Auth Error'
      );
    } catch (error) {
      return BaseReturnObject(
        success: false,
        message: 'Unknown Generic Error'
      );
    }
  }

  Future<BaseReturnObject> createAccount(String? username, String email, String password) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password
      ).then((result) {
        if(username != null) {
          result.user?.updateDisplayName(username);
        }

        result.user?.sendEmailVerification();
      });
      
      return BaseReturnObject(
        success: true,
        message: 'Account created successfully'
      );
    } on FirebaseAuthException catch (error) {
      return BaseReturnObject(
        success: false, 
        message: error.message ?? 'Unknown Firebase Auth Error'
      );
    } catch (error) {
      return BaseReturnObject(
        success: false, 
        message: 'Uknown Generic Error'
      );
    }
  }

  Future<BaseReturnObject> logout() async {
    try {
      await _firebaseAuth.signOut();
      
      return BaseReturnObject(
        success: true,
        message: 'Logout successful'
      );
    } on FirebaseAuthException catch (error) {
      return BaseReturnObject(
        success: false,
        message: error.message ?? 'Unknown Firebase Auth Error'
      );
    } catch (error) {
      return BaseReturnObject(
        success: false,
        message: 'Uknown Generic Error'
      );
    }
  }

  Future<BaseReturnObject> updateUsername(String username) async {
    try {
      await _firebaseAuth.currentUser?.updateDisplayName(username);
      
      return BaseReturnObject(
        success: true,
        message: 'Username Updated Successfully'
      );
    } on FirebaseAuthException catch (error) {
      return BaseReturnObject(
        success: false,
        message: error.message ?? 'Unknown Firebase Auth Error'
      );
    } catch (error) {
      return BaseReturnObject(
        success: false,
        message: 'Uknown Generic Error'
      );
    }
  }

  Future<BaseReturnObject> updateEmail(String email) async {
    try {
      await _firebaseAuth.currentUser?.verifyBeforeUpdateEmail(email);
      
      return BaseReturnObject(
        success: true,
        message: 'Username Updated Successfully'
      );
    } on FirebaseAuthException catch (error) {
      return BaseReturnObject(
        success: false,
        message: error.message ?? 'Unknown Firebase Auth Error'
      );
    } catch (error) {
      return BaseReturnObject(
        success: false,
        message: 'Uknown Generic Error'
      );
    }
  }

  Future<BaseReturnObject> updatePassword(String currentPassword, String newPassword) async {
    try {
      final credentials = EmailAuthProvider.credential(
        email: _firebaseAuth.currentUser!.email ?? '', password: currentPassword
      );

      _firebaseAuth.currentUser?.reauthenticateWithCredential(credentials).then((result) {
        _firebaseAuth.currentUser?.updatePassword(newPassword);
      });
      
      return BaseReturnObject(
        success: true,
        message: 'Password Updated Successfully'
      );
    } on FirebaseAuthException catch (error) {
      return BaseReturnObject(
        success: false,
        message: error.message ?? 'Unknown Firebase Auth Error'
      );
    } catch (error) {
      return BaseReturnObject(
        success: false,
        message: 'Uknown Generic Error'
      );
    }
  }

  Future<BaseReturnObject> sendPasswordReset(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      
      return BaseReturnObject(
        success: true,
        message: 'Logout successful'
      );
    } on FirebaseAuthException catch (error) {
      return BaseReturnObject(
        success: false,
        message: error.message ?? 'Unknown Firebase Auth Error'
      );
    } catch (error) {
      return BaseReturnObject(
        success: false,
        message: 'Uknown Generic Error'
      );
    }
  }

  Stream<User?> get onAuthStateChanged => _firebaseAuth.authStateChanges();
}