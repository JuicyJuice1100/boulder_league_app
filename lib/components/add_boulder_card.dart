import 'package:boulder_league_app/helpers/toast_notification.dart';
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

class AddBoulderCardForm extends StatefulWidget {
  const AddBoulderCardForm({super.key});

  @override
  State<AddBoulderCardForm> createState() => AddBoulderCardFormState();
}

class AddBoulderCardFormState extends State<AddBoulderCardForm> {
  final _addBoulderFormKey = GlobalKey<FormBuilderState>();
  List<Season> seasons = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getSeasons();
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

    SeasonService()
      .getSeasons(null)
      .listen((seasons) {
        setState(() {
          this.seasons = seasons;
          isLoading = false;
        });
      });
  }

  void onSave(Map<String, FormBuilderFieldState<FormBuilderField<dynamic>, dynamic>> fields) async {
    try {
      setIsLoading(true);

      BoulderService().addBoulder(Boulder(
        id: Uuid().v4(),
        name: fields['name']!.value,
        week: fields['week']!.value,
        seasonId: fields['season']!.value,
        createdAt: DateTime.now(),
        lastUpdate: DateTime.now(),
        createdByUid: FirebaseAuth.instance.currentUser!.uid,
      )).then((value) => {
        if(value.success) {
          ToastNotification.success(value.message, null),
          _addBoulderFormKey.currentState?.reset()
        } else {
          ToastNotification.error(value.message, null)
        }
      });
    } catch (e) {
      ToastNotification.error('Failed to add boulder: $e', null);
    } finally {
      setIsLoading(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Center(
              child: SingleChildScrollView(
                physics: ClampingScrollPhysics(),
                child: Card(
                  margin: EdgeInsets.all(20.0),
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: FormBuilder(
                      key: _addBoulderFormKey,
                      child: Column(
                        spacing: 10,
                        children: [
                          FormBuilderTextField(
                            name: 'name',
                            decoration: InputDecoration(
                              border: OutlineInputBorder(), 
                              labelText: 'Name'
                            ),
                            validator: FormBuilderValidators.compose([
                              FormBuilderValidators.required()
                            ])
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
                            items: weeksList.map((week) => DropdownMenuItem(
                              value: week,
                              child: Text(week.toString())
                            )).toList(),
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: isLoading ? null : ()  {
                                if (_addBoulderFormKey.currentState!.validate()) {
                                  onSave(_addBoulderFormKey.currentState!.fields);
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
                  )
                )
              )
            )
          ]
        )
      ),
    );
  }
}