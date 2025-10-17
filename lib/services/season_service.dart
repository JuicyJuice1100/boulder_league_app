import 'dart:math';

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
        .where('name', isEqualTo: season.name)
        .get();

      if (query.docs.isNotEmpty) {
        return BaseReturnObject(
          success: false,
          message: 'Unable to create season - it may already exist or dates overlap with existing season',
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
      return BaseReturnObject(
        success: false, 
        message: error.toString()
      );
    }
  }

  Stream<List<Season>> getSeasons(SeasonFilters? filters) {
    Query<Season> query = seasonRef;

    final startDate = filters?.startDate;
    final endDate = filters?.endDate;
    final isActive = filters?.isActive;
    final createdByUid = filters?.createdByUid;

    if (startDate != null) query = query.where('startDate', isGreaterThanOrEqualTo: startDate);
    if (endDate != null) query = query.where('week', isLessThan: endDate);
    if (isActive != null) query = query.where('isActive', isEqualTo: isActive);
    if (createdByUid != null) query = query.where('createdByUid', isEqualTo: createdByUid);

    return query.snapshots().map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }
}