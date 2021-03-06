import 'package:blindly/models/user_profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:form_validators/form_validators.dart';
import 'package:uuid/uuid.dart';

import '../logging.dart';
import 'first_name_screen.dart';

class EmailScreen extends StatefulWidget {
  EmailScreen({
    Key key,
  }) : super(key: key);

  @override
  _EmailScreenState createState() => _EmailScreenState();
}

class _EmailScreenState extends State<EmailScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _emailAddress;
  bool _savingEmailAddress = false;

  Future<void> _saveEmailAddress() async {
    if (_formKey.currentState.validate()) {
      try {
        setState(() {
          _savingEmailAddress = true;
        });
        String randomPassword = Uuid().v4();
        final emailCredential = EmailAuthProvider.credential(
          email: _emailAddress.trim(),
          password: randomPassword,
        );
        final updatedUserCredential =
            await _auth.currentUser.linkWithCredential(emailCredential);
        updatedUserCredential.user.sendEmailVerification();

        final userProfile = UserProfile.fromFirestore(await _firestore
            .collection('users')
            .doc(updatedUserCredential.user.uid)
            .get());
        if (userProfile == null) {
          _goToFirstNameScreen();
        } else {
          //TODO go to main screen
        }
      } on FirebaseAuthException catch (e) {
        log.e(e.code, e);
        //TODO handle error
      } finally {
        setState(() {
          _savingEmailAddress = false;
        });
      }
    }
  }

  void _goToFirstNameScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FirstNameScreen(),
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
                  AppLocalizations.of(context).emailAddressTitle,
                  style: Theme.of(context).textTheme.headline5,
                ),
                SizedBox(
                  height: 32.0,
                ),
                Text(
                  AppLocalizations.of(context).emailAddressPrompt,
                  style: Theme.of(context).textTheme.bodyText1,
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextFormField(
                        enabled: !_savingEmailAddress,
                        autofocus: true,
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Theme.of(context).accentColor,
                            ),
                          ),
                        ),
                        autocorrect: false,
                        keyboardType: TextInputType.emailAddress,
                        cursorColor: Theme.of(context).cursorColor,
                        onChanged: (value) {
                          _emailAddress = value;
                        },
                        style: Theme.of(context).textTheme.bodyText1,
                        onEditingComplete: _saveEmailAddress,
                        validator: validate([
                          Required(
                            AppLocalizations.of(context).missingEmailError,
                          ),
                          Email(
                            AppLocalizations.of(context).invalidEmailAddress,
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
                        child: _savingEmailAddress
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
                        onPressed:
                            _savingEmailAddress ? null : _saveEmailAddress,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
