import 'package:boulder_league_app/models/base_return_object.dart';
import 'package:boulder_league_app/models/scored_boulder.dart';
import 'package:boulder_league_app/models/scored_boulder_filters.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ScoringService {
  final scoreRef = FirebaseFirestore.instance
    .collection('scores')
    .withConverter<ScoredBoulder>(
      fromFirestore: (snapshot, options) => ScoredBoulder.fromJson(snapshot.data()!, snapshot.id),
      toFirestore: (scoredBoulder, options) => scoredBoulder.toJson()
    );


  Future<BaseReturnObject> addScore(ScoredBoulder scoredBoulder) async {
    try {
      final query = await scoreRef
        .where('boulderId', isEqualTo: scoredBoulder.boulderId)
        .where('uid', isEqualTo: scoredBoulder.uid)
        .get();

      if (query.docs.isNotEmpty) {
        return BaseReturnObject(
          success: false,
          message: 'A score for this boulder already exists',
        );
      }

      await scoreRef.add(scoredBoulder);

      return BaseReturnObject(
        success: true,
        message: 'Score recorded successfully'
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

  Future<BaseReturnObject> updateScore(ScoredBoulder scoredBoulder) async {
    try {
      final query = await scoreRef
        .where('boulderId', isEqualTo: scoredBoulder.boulderId)
        .where('uid', isEqualTo: scoredBoulder.uid)
        .get();

      final hasDuplicate = query.docs.any((doc) => doc.id != scoredBoulder.id);

      if (hasDuplicate) {
        return BaseReturnObject(
          success: false,
          message: 'A score for this boulder already exists'
        );
      }

      await scoreRef.doc(scoredBoulder.id).set(scoredBoulder, SetOptions(merge: true));

      return BaseReturnObject(
        success: true,
        message: 'Score updated successfully'
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

  Stream<List<ScoredBoulder>> getScores(ScoredBoulderFilters? filters) {
    Query<ScoredBoulder> query = scoreRef;

    final gymId = filters?.gymId;
    final boulderId = filters?.boulderId;
    final seasonId = filters?.seasonId;
    final week = filters?.week;
    final uid = filters?.uid;

    if (gymId != null) query = query.where('gymId', isEqualTo: gymId);
    if (boulderId != null) query = query.where('boulderId', isEqualTo: boulderId);
    if (seasonId != null) query = query.where('seasonId', isEqualTo: seasonId);
    if (week != null) query = query.where('week', isEqualTo: week);
    if (uid != null) query = query.where('uid', isEqualTo: uid);

    return query.snapshots().map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }
}