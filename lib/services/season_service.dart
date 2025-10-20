import 'package:boulder_league_app/models/base_return_object.dart';
import 'package:boulder_league_app/models/season.dart';
import 'package:boulder_league_app/models/season_filters.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SeasonService {
  final seasonRef = FirebaseFirestore.instance
    .collection('seasons')
    .withConverter<Season>(
      fromFirestore: (snapshot, options) => Season.fromJson(snapshot.data()!, snapshot.id),
      toFirestore: (season, options) => season.toJson()
    );


  Future<BaseReturnObject> addSeason(Season season) async {
    try{
      final query = await seasonRef
        .where('gymId', isEqualTo: season.gymId)
        .where('name', isEqualTo: season.name)
        .get();

      if (query.docs.isNotEmpty) {
        return BaseReturnObject(
          success: false,
          message: 'Another season with that name already exists',
        );
      }

      await seasonRef.add(season);

      return BaseReturnObject(
        success: true,
        message: 'Season created successfully'
      );
    } on FirebaseAuthException catch (error) {
      return BaseReturnObject(
        success: false, 
        message: error.message ?? 'Unknown Firebase Auth Error'
      );
    } catch (error) {
      print(error.toString());
      return BaseReturnObject(
        success: false, 
        message: error.toString()
      );
    }
  }

    Future<BaseReturnObject> updateSeason(Season season) async {
    try{
      final query = await seasonRef
        .where('gymId', isEqualTo: season.gymId)
        .where('name', isEqualTo: season.name)
        .get();

      final hasDuplicate = query.docs.any((doc) => doc.id != season.id);

      if (hasDuplicate) {
        return BaseReturnObject(
          success: false,
          message: 'Another season with that name already exists',
        );
      }

      await seasonRef.doc(season.id).set(season, SetOptions(merge: true));

      return BaseReturnObject(
        success: true,
        message: 'Season created successfully'
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

  Stream<List<Season>> getSeasons(SeasonFilters? filters) {
    Query<Season> query = seasonRef;

    final gymId = filters?.gymId;
    final startDate = filters?.startDate;
    final endDate = filters?.endDate;
    final isActive = filters?.isActive;

    if (gymId != null) query = query.where('gymId', isEqualTo: gymId);
    if (startDate != null) query = query.where('startDate', isGreaterThanOrEqualTo: startDate);
    if (endDate != null) query = query.where('week', isLessThan: endDate);
    if (isActive != null) query = query.where('isActive', isEqualTo: isActive);

    return query.snapshots().map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }
}