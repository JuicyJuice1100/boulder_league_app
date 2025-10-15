import 'package:boulder_league_app/models/base_return_object.dart';
import 'package:boulder_league_app/models/scored_boulder.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BoulderScoringService {
  final userRef = FirebaseFirestore.instance
    .collection(FirebaseAuth.instance.currentUser!.uid)
    .withConverter<ScoredBoulder>(
      fromFirestore: (snapshot, options) => ScoredBoulder.fromJson(snapshot.data()!, snapshot.id),
      toFirestore: (completedBoulder, options) => completedBoulder.toJson()
    );


  Future<BaseReturnObject> scoreBoulder(ScoredBoulder scoredBoulder) async {
    try{
      await userRef.doc(scoredBoulder.boulderId).set(scoredBoulder, SetOptions(merge: true));

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
        message: error.toString()
      );
    }
  }
}