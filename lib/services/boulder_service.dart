import 'package:boulder_league_app/models/base_return_object.dart';
import 'package:boulder_league_app/models/boulder.dart';
import 'package:boulder_league_app/models/boulder_filters.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BoulderService {
  final boulderRef = FirebaseFirestore.instance
    .collection('boulders')
    .withConverter<Boulder>(
      fromFirestore: (snapshot, options) => Boulder.fromJson(snapshot.data()!, snapshot.id),
      toFirestore: (boulder, options) => boulder.toJson()
    );


  Future<BaseReturnObject> addBoulder(Boulder boulder) async {
    try{
      final query = await boulderRef
        .where('name', isEqualTo: boulder.name)
        .where('week', isEqualTo: boulder.week)
        .where('seasonId', isEqualTo: boulder.seasonId)
        .get();

      if (query.docs.isNotEmpty) {
        return BaseReturnObject(
          success: false,
          message: 'This boulder already exists',
        );
      }

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
        message: error.toString()
      );
    }
  }

  Stream<List<Boulder>> getBoulders(BoulderFilters? filters) {
    Query<Boulder> query = boulderRef;

    final season = filters?.season;
    final week = filters?.week;
    final createdByUid = filters?.createdByUid;

    if (season != null) query = query.where('season', isEqualTo: season);
    if (week != null) query = query.where('week', isEqualTo: week);
    if (createdByUid != null) query = query.where('createdByUid', isEqualTo: createdByUid);

    return query.snapshots().map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }
}