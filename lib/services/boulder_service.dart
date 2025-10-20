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
        .where('gymId', isEqualTo: boulder.gymId)
        .where('name', isEqualTo: boulder.name)
        .where('seasonId', isEqualTo: boulder.seasonId)
        .where('week', isEqualTo: boulder.week)
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

  Future<BaseReturnObject> updateBoulder(Boulder boulder) async {
    try {
      final query = await boulderRef
        .where('gymId', isEqualTo: boulder.gymId)
        .where('name', isEqualTo: boulder.name)
        .where('seasonId', isEqualTo: boulder.seasonId)
        .where('week', isEqualTo: boulder.week)
        .get();

      final hasDuplicate = query.docs.any((doc) => doc.id != boulder.id);

      if(hasDuplicate) {
        return BaseReturnObject(
          success: false,
          message: 'Another boulder with that name already exists for selected season selected season on selected week'
        );
      }

      await boulderRef.doc(boulder.id).set(boulder, SetOptions(merge: true));

      return BaseReturnObject(
        success: true,
        message: 'Boulder created successfully'
      );
    } on FirebaseAuthException catch (error) {
      return BaseReturnObject(
        success: false, 
        message: error.message ?? 'Unknown Firebase Auth Error'
      );
    } 
    catch (error) {
      return BaseReturnObject(
        success: false, 
        message: error.toString()
      );
    }
  }

  Stream<List<Boulder>> getBoulders(BoulderFilters? filters) {
    Query<Boulder> query = boulderRef;

    final gymId = filters?.gymId;
    final seasonId = filters?.seasonId;
    final week = filters?.week;

    if (gymId != null) query = query.where('gymId', isEqualTo: gymId);
    if (seasonId != null) query = query.where('seasonId', isEqualTo: seasonId);
    if (week != null) query = query.where('week', isEqualTo: week);

    return query.snapshots().map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }
}