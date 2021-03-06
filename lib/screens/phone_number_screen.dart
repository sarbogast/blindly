import 'dart:io';

import 'package:blindly/models/user_profile.dart';
import 'package:blindly/screens/first_name_screen.dart';
import 'package:blindly/screens/phone_code_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../logging.dart';
import 'email_screen.dart';

class PhoneNumberScreen extends StatefulWidget {
  @override
  _PhoneNumberScreenState createState() => _PhoneNumberScreenState();
}

class _PhoneNumberScreenState extends State<PhoneNumberScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final initialNumber = PhoneNumber(
    isoCode: Platform.localeName.split('_').last,
  );
  PhoneNumber _phoneNumber;
  bool _verifyingPhoneNumber = false;
  bool _authenticating = false;

  Future<void> _validatePhoneNumber(BuildContext context) async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      setState(() {
        _verifyingPhoneNumber = true;
      });
      String languageCode = Platform.localeName.split('_').first;
      await _auth.setLanguageCode(languageCode);
      //no need to catch exception, handled by verificationFailed callback
      await _auth.verifyPhoneNumber(
        phoneNumber: _phoneNumber.toString(),
        verificationCompleted: (PhoneAuthCredential credential) async {
          if (!mounted) return;
          setState(() {
            _verifyingPhoneNumber = false;
          });
          await _signInAndCheckProfile(context, credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          if (!mounted) return;
          setState(() {
            _verifyingPhoneNumber = false;
          });
          String errorMessage =
              AppLocalizations.of(context).phoneNumberGenericError;
          //Error codes: https://firebase.google.com/docs/reference/swift/firebaseauth/api/reference/Classes/PhoneAuthProvider?authuser=1#-verifyphonenumber:uidelegate:completion:
          switch (e.code) {
            case 'invalid-phone-number':
              //This should not happen because the phone number is validated
              log.e(e.code, e);
              break;
            case 'captcha-check-failed':
              log.w(e.code, e);
              errorMessage =
                  AppLocalizations.of(context).phoneNumberCaptchaError;
              break;
            case 'quota-exceeded':
              log.e(e.code, e);
              break;
            case 'missing-phone-number':
              //This should not happen because the phone number is validated
              log.e(e.code, e);
              break;
            default:
              log.e(e.code, e);
          }
          Scaffold.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              duration: Duration(seconds: 10),
            ),
          );
        },
        codeSent: (String verificationId, resendToken) {
          if (!mounted) return;
          setState(() {
            _verifyingPhoneNumber = false;
          });
          _goToPhoneCodeScreen(
            resendToken: resendToken,
            verificationId: verificationId,
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          if (!mounted) return;
          setState(() {
            _verifyingPhoneNumber = false;
          });
          _goToPhoneCodeScreen(
            resendToken: null,
            verificationId: verificationId,
          );
        },
      );
    }
  }

  void _goToPhoneCodeScreen({int resendToken, String verificationId}) {
    log.d('Resend token: $resendToken');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PhoneCodeScreen(
          phoneNumber: _phoneNumber.toString(),
          resendToken: resendToken,
          verificationId: verificationId,
        ),
      ),
    );
  }

  Future<void> _signInAndCheckProfile(
      BuildContext context, PhoneAuthCredential credential) async {
    // ANDROID ONLY!
    // Sign the user in (or link) with the auto-generated credential
    UserCredential user;
    try {
      setState(() {
        _authenticating = true;
      });
      user = await _auth.signInWithCredential(credential);
      setState(() {
        _authenticating = false;
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        _authenticating = false;
      });
      String errorMessage =
          AppLocalizations.of(context).genericAuthenticationError;
      switch (e.code) {
        case 'invalid-credential':
          log.e(e.code, e);
          break;
        case 'operation-not-allowed':
          //should never happen if the environment is configured properly
          log.e(e.code, e);
          break;
        case 'user-disabled':
          log.w(e.code, e);
          errorMessage = AppLocalizations.of(context).accountDisabledError;
          break;
        case 'invalid-verification-code':
          //should never happen
          log.e(e.code, e);
          break;
        case 'invalid-verification-id':
          //should never happen
          log.e(e.code, e);
          break;
      }
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          duration: Duration(seconds: 10),
        ),
      );
    }
    if (user != null) {
      if (user.user.email == null) {
        _goToEmailScreen();
      } else {
        final userProfile = UserProfile.fromFirestore(
            await _firestore.collection('users').doc(user.user.uid).get());
        if (userProfile == null) {
          _goToFirstNameScreen();
        } else {
          //TODO go to main screen
        }
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

  void _goToEmailScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EmailScreen(),
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
      body: Builder(
        builder: (context) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context).phoneNumberTitle,
                    style: Theme.of(context).textTheme.headline5,
                  ),
                  SizedBox(
                    height: 16.0,
                  ),
                  Text(
                    AppLocalizations.of(context).phoneNumberExplanation,
                    style: Theme.of(context).textTheme.bodyText1.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onPrimary
                              .withOpacity(0.75),
                        ),
                  ),
                  Expanded(
                    child: InternationalPhoneNumberInput(
                      isEnabled: !_verifyingPhoneNumber && !_authenticating,
                      formatInput: true,
                      onInputChanged: (value) {
                        _phoneNumber = value;
                      },
                      initialValue: initialNumber,
                      autoFocus: true,
                      selectorConfig: SelectorConfig(
                        selectorType: PhoneInputSelectorType.DIALOG,
                        countryComparator: (country1, country2) {
                          return country1.name.compareTo(country2.name);
                        },
                        useEmoji: true,
                      ),
                      cursorColor: Theme.of(context).cursorColor,
                      hintText: AppLocalizations.of(context).phoneNumberHint,
                      errorMessage:
                          AppLocalizations.of(context).phoneNumberInvalidError,
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context).phoneNumberExplanation2,
                          style: Theme.of(context).textTheme.bodyText2.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimary
                                    .withOpacity(0.75),
                              ),
                        ),
                      ),
                      SizedBox(width: 32.0),
                      Container(
                        width: 44.0,
                        height: 44.0,
                        child: RawMaterialButton(
                          shape: CircleBorder(),
                          elevation: 3.0,
                          child: _verifyingPhoneNumber || _authenticating
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
                          onPressed: _verifyingPhoneNumber || _authenticating
                              ? null
                              : () => _validatePhoneNumber(context),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
