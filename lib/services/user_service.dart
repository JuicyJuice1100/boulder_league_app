import 'package:boulder_league_app/models/base_return_object.dart';
import 'package:boulder_league_app/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final userRef = FirebaseFirestore.instance
    .collection('users')
    .withConverter<User>(
      fromFirestore: (snapshot, options) => User.fromJson(snapshot.data()!),
      toFirestore: (user, options) => user.toJson(),
    );

  Future<BaseReturnObject> getUser() async {
    throw('Not implemented');
  }

  Future<BaseReturnObject> createUser(User user) async {
    try {
      await userRef.add(user);
      
      return BaseReturnObject(
        success: true,
        message: 'User created successfully'
      );
    } on FirebaseException catch (error) {
      return BaseReturnObject(
        success: false,
        message: error.message ?? 'Unknown Firebase Error'
      );
    } catch (error) {
      return BaseReturnObject(
        success: false,
        message: 'Unknown Generic Error'
      );
    }

  }

  Future<BaseReturnObject> deleteUserById(String id) async {
    throw('Not implemented');
  }

  Future<BaseReturnObject> updateUser(User user) async {
    throw('Not implemented');
  }
}