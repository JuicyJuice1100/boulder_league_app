import 'package:boulder_league_app/models/base_return_object.dart';
import 'package:boulder_league_app/models/completed_boulder.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BoulderService {
  final completedBoulderRef = FirebaseFirestore.instance
    .collection('completed_boulder')
    .withConverter<CompletedBoulder>(
      fromFirestore: (snapshot, options) => CompletedBoulder.fromJson(snapshot.data()!),
      toFirestore: (completedBoulder, options) => completedBoulder.toJson()
    );


  Future<BaseReturnObject> createCompletedBoulder(CompletedBoulder completedBoulder) async {
    try{
      await completedBoulderRef.add(completedBoulder);

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