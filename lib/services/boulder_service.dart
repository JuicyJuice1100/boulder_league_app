import 'package:boulder_league_app/models/base_return_object.dart';
import 'package:boulder_league_app/models/boulder.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BoulderService {
  final boulderRef = FirebaseFirestore.instance
    .collection('boulders')
    .withConverter<Boulder>(
      fromFirestore: (snapshot, options) => Boulder.fromJson(snapshot.data()!),
      toFirestore: (boulder, options) => boulder.toJson()
    );


  Future<BaseReturnObject> createBoulder(Boulder boulder) async {
    try{
      await boulderRef.add(boulder);

      return BaseReturnObject(
        success: true,
        message: 'Boulder created successfully'
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