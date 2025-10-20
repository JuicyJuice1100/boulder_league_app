import 'package:boulder_league_app/helpers/toast_notification.dart';
import 'package:boulder_league_app/models/base_meta_data.dart';
import 'package:boulder_league_app/models/boulder.dart';
import 'package:boulder_league_app/models/season.dart';
import 'package:boulder_league_app/services/boulder_service.dart';
import 'package:boulder_league_app/services/season_service.dart';
import 'package:boulder_league_app/static/weeks.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:uuid/uuid.dart';

class BouldersForm extends StatefulWidget {
  final Boulder? boulder;
  const BouldersForm({super.key, this.boulder});

  @override
  State<BouldersForm> createState() => BouldersFormState();
}

class BouldersFormState extends State<BouldersForm> {
  final _boulderFormKey = GlobalKey<FormBuilderState>();
  final SeasonService _seasonService = SeasonService();
  
  List<Season> seasons = [];
  bool isLoading = false;
  bool isUpdate = false;

  @override
  void initState() {
    super.initState();
    getSeasons();
    setIsUpdate();
  }

  void setIsLoading(bool value) {
    setState(() {
      isLoading = value;
    });
  }

  void getSeasons() {
    setState(() {
      isLoading = true;
    });

    _seasonService
      .getSeasons(null)
      .listen((seasons) {
        setState(() {
          this.seasons = seasons;
          isLoading = false;
        });
      });
  }

  void setIsUpdate() {
    setState(() {
      isUpdate = widget.boulder != null;
    });
  }

  void onSave(Map<String, FormBuilderFieldState<FormBuilderField<dynamic>, dynamic>> fields) async {
    try {
      setIsLoading(true);

      final user = FirebaseAuth.instance.currentUser!;

      final boulder = Boulder(
        id: widget.boulder?.id ?? Uuid().v4(),
        gymId: fields['gymId']!.value,
        name: fields['name']!.value,
        week: fields['week']!.value,
        seasonId: fields['season']!.value,
        baseMetaData: BaseMetaData(
          createdByUid: widget.boulder?.baseMetaData.createdByUid ?? user.uid, 
          lastUpdateByUid: user.uid, 
          createdAt: widget.boulder?.baseMetaData.createdAt ?? DateTime.now().toUtc(), 
          lastUpdateAt: DateTime.now().toUtc()
        )
      );

      if(widget.boulder == null) {
        BoulderService().addBoulder(boulder).then((value) => {
          if(value.success) {
            ToastNotification.success(value.message, null),
            _boulderFormKey.currentState?.reset(),
            Navigator.pop(context)
          } else {
            ToastNotification.error(value.message, null)
          }
        });
      } else {
        BoulderService().updateBoulder(boulder).then((value) => {
        if(value.success) {
            ToastNotification.success(value.message, null),
            _boulderFormKey.currentState?.reset(),
            Navigator.pop(context)
          } else {
            ToastNotification.error(value.message, null)
          }
        });
      }
     
    } catch (e) {
      ToastNotification.error('Failed to add boulder: $e', null);
    } finally {
      setIsLoading(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isUpdate ? 'Update Boulder' : 'Add Boulder')
      ),
      body: FormBuilder(
        key: _boulderFormKey,
        child: Column(
          spacing: 10,
          children: [
            SizedBox(height: 10),
            FormBuilderDropdown(
              name: 'gymId',
              decoration: InputDecoration(
                border: OutlineInputBorder(), 
                labelText: 'Gym'
              ),
              initialValue: 'climb_kraft',
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required()
              ]),
              items: const [
                DropdownMenuItem(
                  value: 'climb_kraft',
                  child: Text('Climb Kraft'),
                ),
              ],
            ),
            FormBuilderTextField(
              name: 'name',
              decoration: InputDecoration(
                border: OutlineInputBorder(), 
                labelText: 'Name'
              ),
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required()
              ]),
              initialValue: widget.boulder?.name ?? '',
            ),
            isLoading 
              ? CircularProgressIndicator() :
              FormBuilderDropdown(
                name: 'season',
                decoration: InputDecoration(
                  border: OutlineInputBorder(), 
                  labelText: 'Season'
                ),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required()
                ]), 
                items: seasons
                  .map((season) => DropdownMenuItem(
                        value: season.id,
                        child: Text(season.name),
                      ))
                  .toList(),
                initialValue: widget.boulder?.seasonId,
              ),
            FormBuilderDropdown(
              name: 'week',
              decoration: InputDecoration(
                border: OutlineInputBorder(), 
                labelText: 'Week'
              ),
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required()
              ]), 
              initialValue: widget.boulder?.week,
              items: weeksList.map((week) => DropdownMenuItem(
                value: week,
                child: Text(week.toString())
              )).toList(),
            ),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: isLoading ? null : ()  {
                  if (_boulderFormKey.currentState!.validate()) {
                    onSave(_boulderFormKey.currentState!.fields);
                  }
                },
                icon: isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 2.0
                      )
                    )
                  : Icon(isUpdate ? Icons.save : Icons.add),
                label: Text(isUpdate ? 'Update' : 'Add'),
              )
            )
          ]
        )
      )
    );
  }
}