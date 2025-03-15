import 'package:boulder_league_app/models/base_return_object.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  Future<BaseReturnObject> login(String email, String password) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
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

  Future<BaseReturnObject> createAccount(String email, String password, String confirmPassword) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password
      );
      
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
      await FirebaseAuth.instance.signOut();
      
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
}