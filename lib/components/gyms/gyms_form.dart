import 'package:boulder_league_app/helpers/toast_notification.dart';
import 'package:boulder_league_app/models/base_meta_data.dart';
import 'package:boulder_league_app/models/gym.dart';
import 'package:boulder_league_app/models/season.dart';
import 'package:boulder_league_app/models/season_filters.dart';
import 'package:boulder_league_app/services/gym_service.dart';
import 'package:boulder_league_app/services/season_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:uuid/uuid.dart';

class GymsForm extends StatefulWidget {
  final Gym? gym;
  const GymsForm({super.key, this.gym});

  @override
  State<GymsForm> createState() => GymsFormState();
}

class GymsFormState extends State<GymsForm> {
  final _gymFormKey = GlobalKey<FormBuilderState>();
  final SeasonService _seasonService = SeasonService();

  List<Season> availableSeasons = [];
  bool isLoading = false;
  bool isUpdate = false;

  @override
  void initState() {
    super.initState();
    setIsUpdate();
    initSeasons();
  }

  void setIsLoading(bool value) {
    setState(() {
      isLoading = value;
    });
  }

  void setIsUpdate() {
    setState(() {
      isUpdate = widget.gym != null;
    });
  }

  void initSeasons() {
    if(isUpdate) {
      _seasonService.getSeasons(SeasonFilters(gymId: widget.gym!.id)).listen((seasons) {
        setState(() {
          availableSeasons = seasons;
        });
      });
    }
  }

  void onSave(Map<String, FormBuilderFieldState<FormBuilderField<dynamic>, dynamic>> fields) async {
    try {
      setIsLoading(true);

      final user = FirebaseAuth.instance.currentUser!;

      final gym = Gym(
        id: widget.gym?.id ?? Uuid().v4(),
        name: fields['name']!.value,
        activeSeasonId: fields['activeSeasonId']?.value ?? '',
        baseMetaData: BaseMetaData(
          createdByUid: widget.gym?.baseMetaData.createdByUid ?? user.uid,
          lastUpdateByUid: user.uid,
          createdAt: widget.gym?.baseMetaData.createdAt ?? DateTime.now().toUtc(),
          lastUpdateAt: DateTime.now().toUtc()
        )
      );

      if (widget.gym == null) {
        GymService().addGym(gym).then((value) => {
          if (value.success) {
            ToastNotification.success(value.message, null),
            _gymFormKey.currentState?.reset(),
            Navigator.pop(context)
          } else {
            ToastNotification.error(value.message, null)
          }
        });
      } else {
        GymService().updateGym(gym).then((value) => {
          if (value.success) {
            ToastNotification.success(value.message, null),
            _gymFormKey.currentState?.reset(),
            Navigator.pop(context)
          } else {
            ToastNotification.error(value.message, null)
          }
        });
      }
    } catch (e) {
      ToastNotification.error('Failed to add/edit gym: $e', null);
    } finally {
      setIsLoading(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isUpdate ? 'Update Gym' : 'Add Gym'),
      ),
      body: FormBuilder(
        key: _gymFormKey,
        child: Column(
          spacing: 10,
          children: [
            SizedBox(height: 10),
            FormBuilderTextField(
              name: 'name',
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Name'
              ),
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required()
              ]),
              initialValue: widget.gym?.name ?? '',
            ),
            if(isUpdate)
            FormBuilderDropdown(
              name: 'activeSeasonId', 
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Active Season'
              ),
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required()
              ]),
              items: availableSeasons.isNotEmpty ? availableSeasons.map((season) => DropdownMenuItem(
                value: season.id,
                child: Text(season.name),
              )).toList() : [
                DropdownMenuItem(
                  value: 'NO_ACTIVE_SEASON',
                  child: Text('No Available Seasons')
                )
              ],
              initialValue: widget.gym?.activeSeasonId ?? 'NO_ACTIVE_SEASON',
            ),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: isLoading ? null : () {
                  if (_gymFormKey.currentState!.validate()) {
                    onSave(_gymFormKey.currentState!.fields);
                  }
                },
                icon: isLoading ?
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 2.0
                    )
                  ) : Icon(isUpdate ? Icons.save : Icons.add),
                label: Text(isUpdate ? 'Update' : 'Add'),
              )
            )
          ]
        )
      )
    );
  }
}
