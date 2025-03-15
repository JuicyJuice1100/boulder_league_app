import 'package:firebase_auth/firebase_auth.dart';

class LoginService {
  Future<bool> login(String email, String password) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password
      );
      return true;
    } on FirebaseAuthException catch (error) {
      if(error.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (error.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
      return false;
    } catch (error) {
      print(error);
      return false;
    }
  }

  Future<bool> createAccount(String email, String password) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password
      );
      return true;
    } on FirebaseAuthException catch (error) {
      if(error.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (error.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
      return false;
    } catch (error) {
      print(error);
      return false;
    }

  }

  Future<bool> logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      return true;
    } catch (error) {
      print(error);
      return false;
    }
  }
}