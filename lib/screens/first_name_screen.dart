import 'package:blindly/screens/date_of_birth_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:form_validators/form_validators.dart';

import '../logging.dart';

class FirstNameScreen extends StatefulWidget {
  FirstNameScreen({
    Key key,
  }) : super(key: key);

  @override
  _FirstNameScreenState createState() => _FirstNameScreenState();
}

class _FirstNameScreenState extends State<FirstNameScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _savingFirstName = false;
  String _firstName = '';

  Future<void> _saveFirstName() async {
    if (_formKey.currentState.validate()) {
      setState(() {
        _savingFirstName = true;
      });
      try {
        final currentUser = _auth.currentUser;
        await _firestore
            .collection('users')
            .doc(currentUser.uid)
            .set({'firstName': _firstName.trim()});
        _goToDateOfBirthScreen();
      } catch (e, s) {
        log.e(e.toString(), e, s);
      } finally {
        setState(() {
          _savingFirstName = false;
        });
      }
    }
  }

  void _goToDateOfBirthScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DateOfBirthScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  AppLocalizations.of(context).firstNameTitle,
                  style: Theme.of(context).textTheme.headline5,
                ),
                SizedBox(
                  height: 16.0,
                ),
                Text(
                  AppLocalizations.of(context).firstNamePrompt,
                  style: Theme.of(context).textTheme.bodyText1.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onPrimary
                            .withOpacity(0.75),
                      ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextFormField(
                        enabled: !_savingFirstName,
                        autofocus: true,
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Theme.of(context).accentColor,
                            ),
                          ),
                        ),
                        keyboardType: TextInputType.text,
                        textCapitalization: TextCapitalization.words,
                        cursorColor: Theme.of(context).cursorColor,
                        style: Theme.of(context).textTheme.bodyText1,
                        onChanged: (value) {
                          _firstName = value;
                        },
                        onEditingComplete: _saveFirstName,
                        validator: validate([
                          Required(
                            AppLocalizations.of(context).missingFirstNameError,
                          ),
                        ]),
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
                        child: _savingFirstName
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
                        onPressed: _savingFirstName ? null : _saveFirstName,
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
