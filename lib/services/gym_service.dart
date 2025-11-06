import 'package:boulder_league_app/env_config.dart';
import 'package:boulder_league_app/models/base_return_object.dart';
import 'package:boulder_league_app/models/gym.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class GymService {
  final gymRef = FirebaseFirestore.instanceFor(
      app: Firebase.app(),
      databaseId: EnvConfig.firebaseDatabaseId
    )
    .collection('gyms')
    .withConverter<Gym>(
      fromFirestore: (snapshot, options) => Gym.fromJson(snapshot.data()!, snapshot.id),
      toFirestore: (gym, options) => gym.toJson()
    );

  Future<BaseReturnObject> addGym(Gym gym) async {
    try {
      final query = await gymRef
        .where('name', isEqualTo: gym.name)
        .get();

      if (query.docs.isNotEmpty) {
        return BaseReturnObject(
          success: false,
          message: 'A gym with that name already exists',
        );
      }

      await gymRef.add(gym);

      return BaseReturnObject(
        success: true,
        message: 'Gym created successfully'
      );
    } on FirebaseAuthException catch (error) {
      return BaseReturnObject(
        success: false,
        message: error.message ?? 'Unknown Firebase Auth Error'
      );
    } catch (error) {
      return BaseReturnObject(
        success: false,
        message: error.toString()
      );
    }
  }

  Future<BaseReturnObject> updateGym(Gym gym) async {
    try {
      final query = await gymRef
        .where('name', isEqualTo: gym.name)
        .get();

      final hasDuplicate = query.docs.any((doc) => doc.id != gym.id);

      if (hasDuplicate) {
        return BaseReturnObject(
          success: false,
          message: 'Another gym with that name already exists',
        );
      }

      await gymRef.doc(gym.id).set(gym, SetOptions(merge: true));

      return BaseReturnObject(
        success: true,
        message: 'Gym updated successfully'
      );
    } on FirebaseAuthException catch (error) {
      return BaseReturnObject(
        success: false,
        message: error.message ?? 'Unknown Firebase Auth Error'
      );
    } catch (error) {
      return BaseReturnObject(
        success: false,
        message: error.toString()
      );
    }
  }

  Stream<List<Gym>> getGyms() {
    Query<Gym> query = gymRef;

    // Order by name
    query = query.orderBy('name');

    return query.snapshots().map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }
}
