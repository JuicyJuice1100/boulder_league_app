import 'package:boulder_league_app/helpers/toast_notification.dart';
import 'package:boulder_league_app/models/base_meta_data.dart';
import 'package:boulder_league_app/models/season.dart';
import 'package:boulder_league_app/services/season_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class SeasonCardForm extends StatefulWidget {
  final Season? season;
  const SeasonCardForm({super.key, this.season});

  @override
  State<SeasonCardForm> createState() => SeasonCardFormState();
}

class SeasonCardFormState extends State<SeasonCardForm> {
  final _addSeasonFormKey = GlobalKey<FormBuilderState>();
  
  List<Season> filteredSeasons = [];
  bool isLoading = false;

  void setIsLoading(bool value) {
    setState(() {
      isLoading = value;
    });
  }

  void onSave(Map<String, FormBuilderFieldState<FormBuilderField<dynamic>, dynamic>> fields) async {
    try {
      setIsLoading(true);

      final user = FirebaseAuth.instance.currentUser!;

      final season = Season(
        id: widget.season?.id ?? Uuid().v4(),
        gymId: fields['gymId']!.value,
        name: fields['name']!.value,
        startDate: fields['daterange']!.value.start,
        endDate: fields['daterange']!.value.end,
        isActive: fields['active']!.value, 
        baseMetaData: BaseMetaData(
          createdByUid: widget.season?.baseMetaData.createdByUid ?? user.uid, 
          lastUpdateByUid: user.uid, 
          createdAt:  widget.season?.baseMetaData.createdAt ?? DateTime.now().toUtc(), 
          lastUpdateAt: DateTime.now().toUtc())
      );

      if(widget.season == null) {
        SeasonService().addSeason(season).then((value) => {
          if(value.success) {
            ToastNotification.success(value.message, null),
            _addSeasonFormKey.currentState?.reset(),
            Navigator.pop(context)
          } else {
            ToastNotification.error(value.message, null)
          }
        });
      } else {
        SeasonService().updateSeason(season).then((value) => {
          if(value.success) {
            ToastNotification.success(value.message, null),
            _addSeasonFormKey.currentState?.reset(),
            Navigator.pop(context)
          } else {
            ToastNotification.error(value.message, null)
          }
        });
      }
    } catch (e) {
      ToastNotification.error('Failed to add/edit boulder: $e', null);
    } finally {
      setIsLoading(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Season'),
      ),
      body: FormBuilder(
        key: _addSeasonFormKey,
        child: Column(
          spacing: 10,
          children: [
            SizedBox(height: 10),
            FormBuilderDropdown(
              name: 'gymId',
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Gym',
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
              initialValue: widget.season?.name ?? '',
            ),
            FormBuilderDateRangePicker(
              name: 'daterange',
              decoration: InputDecoration(
                border: OutlineInputBorder(), 
                labelText: 'Date Range'
              ),
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required()
              ]), 
              firstDate: DateTime(DateTime.now().year),
              lastDate: DateTime(DateTime.now().year + 1),
              format: DateFormat('MMM dd, yyyy'),
              initialEntryMode: DatePickerEntryMode.input,
              initialValue: widget.season != null
                ? DateTimeRange(start: widget.season!.startDate, end: widget.season!.endDate)
                : null,
            ),
            FormBuilderCheckbox(
              name: 'active',  
              title: Text('Active Season'),
              initialValue: widget.season?.isActive ?? false,
            ),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: isLoading ? null : ()  {
                  if (_addSeasonFormKey.currentState!.validate()) {
                    onSave(_addSeasonFormKey.currentState!.fields);
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
                  ) : Icon(Icons.add), 
                label: Text('Add'),
              )
            )
          ]
        )
      )
    );
  }
}