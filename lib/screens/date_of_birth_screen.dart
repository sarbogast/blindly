import 'package:blindly/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import '../logging.dart';

class DateOfBirthScreen extends StatefulWidget {
  DateOfBirthScreen({
    Key key,
  }) : super(key: key);

  @override
  _DateOfBirthScreenState createState() => _DateOfBirthScreenState();
}

class _DateOfBirthScreenState extends State<DateOfBirthScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _savingDateOfBirth = false;
  DateTime _dateOfBirth =
      DateTime.now().subtract(Duration(days: (365.25 * 18).toInt()));

  Future<void> _saveDateOfBirth() async {
    if (_formKey.currentState.validate()) {
      setState(() {
        _savingDateOfBirth = true;
      });
      try {
        final DateFormat formatter = DateFormat('yyyy-MM-dd');
        await _firestore
            .collection('users')
            .doc(_auth.currentUser.uid)
            .update({'dateOfBirth': formatter.format(_dateOfBirth)});
        //TODO go to next screen
      } catch (e, s) {
        log.e(e.toString(), e, s);
      } finally {
        setState(() {
          _savingDateOfBirth = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final lastDate =
        today.subtract(Duration(days: (365.25 * minimumAge).toInt()));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).backgroundColor,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context).dateOfBirthTitle,
                  style: Theme.of(context).textTheme.headline5,
                ),
                SizedBox(
                  height: 16.0,
                ),
                Text(
                  AppLocalizations.of(context).dateOfBirthPrompt,
                  style: Theme.of(context).textTheme.bodyText1.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onPrimary
                            .withOpacity(0.75),
                      ),
                ),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      DateTimePicker(
                        autofocus: true,
                        initialValue: '',
                        //initialDate: _dateOfBirth,
                        type: DateTimePickerType.date,
                        decoration: InputDecoration(
                          hintText:
                              AppLocalizations.of(context).dateOfBirthHint,
                          border: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Theme.of(context).accentColor,
                            ),
                          ),
                        ),
                        dateHintText:
                            AppLocalizations.of(context).dateOfBirthHint,
                        enabled: !_savingDateOfBirth,
                        firstDate: DateTime(1900),
                        lastDate: today,
                        onChanged: (value) {
                          setState(() {
                            _dateOfBirth = DateTime.parse(value);
                          });
                        },
                        style: Theme.of(context).textTheme.bodyText1,
                        validator: (value) {
                          if (value == null || value == '')
                            return AppLocalizations.of(context)
                                .missingDateOfBirthError;
                          if (DateTime.parse(value).isAfter(lastDate))
                            return AppLocalizations.of(context)
                                .dateOfBirthTooYoungError;
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 44.0,
                      height: 44.0,
                      child: RawMaterialButton(
                        shape: CircleBorder(),
                        elevation: 3.0,
                        child: _savingDateOfBirth
                            ? CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Theme.of(context).colorScheme.onSecondary,
                                ),
                              )
                            : Icon(
                                Icons.arrow_forward_ios,
                                color:
                                    Theme.of(context).colorScheme.onSecondary,
                              ),
                        fillColor: Theme.of(context).colorScheme.secondary,
                        onPressed: _savingDateOfBirth ? null : _saveDateOfBirth,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
