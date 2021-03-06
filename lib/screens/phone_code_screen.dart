import 'dart:async';

import 'package:blindly/models/user_profile.dart';
import 'package:blindly/screens/email_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:form_validators/form_validators.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../logging.dart';
import 'first_name_screen.dart';

class PhoneCodeScreen extends StatefulWidget {
  final String phoneNumber;
  final int resendToken;
  final String verificationId;

  const PhoneCodeScreen({
    @required this.phoneNumber,
    @required this.resendToken,
    @required this.verificationId,
  });

  @override
  _PhoneCodeScreenState createState() => _PhoneCodeScreenState();
}

class _PhoneCodeScreenState extends State<PhoneCodeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController textEditingController = TextEditingController();
  StreamController<ErrorAnimationType> errorController;

  String _code = '';
  bool _verifyingCode = false;
  bool _resendingCode = false;
  bool _hasError = false;
  int _resendToken;
  String _verificationId;

  @override
  void initState() {
    _resendToken = widget.resendToken;
    _verificationId = widget.verificationId;
    errorController = StreamController<ErrorAnimationType>();
    super.initState();
  }

  @override
  void dispose() {
    errorController.close();
    super.dispose();
  }

  Future<void> _verifyCode(BuildContext context) async {
    if (!_formKey.currentState.validate()) {
      errorController
          .add(ErrorAnimationType.shake); // Triggering error shake animation
      setState(() {
        _hasError = true;
      });
    } else {
      setState(() {
        _hasError = false;
        _verifyingCode = true;
      });
      PhoneAuthCredential phoneAuthCredential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: _code,
      );

      _signInWithPhoneCredential(context, phoneAuthCredential);
    }
  }

  Future<void> _signInWithPhoneCredential(
    BuildContext context,
    PhoneAuthCredential phoneAuthCredential,
  ) async {
    // Sign the user in (or link) with the credential
    try {
      final user = await _auth.signInWithCredential(phoneAuthCredential);
      setState(() {
        _verifyingCode = false;
      });
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
    } on FirebaseAuthException catch (e) {
      setState(() {
        _hasError = true;
        _verifyingCode = false;
      });
      log.e(e.code, e);
      String errorMessage =
          AppLocalizations.of(context).genericAuthenticationError;
      switch (e.code) {
        case 'invalid-credential':
          log.e(e.code, e);
          break;
        case 'operation-not-allowed':
          //should never happen if environment configured properly
          log.e(e.code, e);
          break;
        case 'user-disabled':
          log.w(e.code, e);
          errorMessage = AppLocalizations.of(context).accountDisabledError;
          break;
        case 'invalid-verification-code':
          log.e(e.code, e);
          break;
        case 'invalid-verification-id':
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
  }

  Future<void> _resendCode(BuildContext context) async {
    setState(() {
      _resendingCode = true;
    });
    _auth.verifyPhoneNumber(
      phoneNumber: widget.phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) {
        setState(() {
          _resendingCode = false;
        });
        _signInWithPhoneCredential(context, credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        log.e(e.code, e);
      },
      codeSent: (String verificationId, int resendToken) {
        setState(() {
          _resendingCode = false;
          _resendToken = resendToken;
          _verificationId = verificationId;
        });
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        setState(() {
          _verificationId = verificationId;
        });
      },
      forceResendingToken: _resendToken,
    );
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
                    AppLocalizations.of(context).phoneNumberVerificationTitle,
                    style: Theme.of(context).textTheme.headline5,
                  ),
                  SizedBox(
                    height: 32.0,
                  ),
                  RichText(
                    text: TextSpan(
                      text: AppLocalizations.of(context)
                          .phoneNumberVerificationPrompt,
                      style: Theme.of(context).textTheme.bodyText1,
                      children: [
                        TextSpan(
                          text: widget.phoneNumber,
                          style: Theme.of(context).textTheme.bodyText1.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ),
                  if (_resendToken != null)
                    TextButton(
                      onPressed:
                          _resendingCode ? null : () => _resendCode(context),
                      child: Text(
                        AppLocalizations.of(context)
                            .phoneNumberVerificationResendCode
                            .toUpperCase(),
                      ),
                    ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        PinCodeTextField(
                          enabled: !_verifyingCode && !_resendingCode,
                          appContext: context,
                          length: 6,
                          obscureText: false,
                          animationType: AnimationType.fade,
                          pinTheme: PinTheme(
                            shape: PinCodeFieldShape.circle,
                            borderRadius: BorderRadius.circular(5),
                            fieldHeight: 60,
                            fieldWidth: 50,
                            activeColor: Theme.of(context).accentColor,
                            selectedColor: Theme.of(context).accentColor,
                            inactiveColor: Theme.of(context).accentColor,
                            activeFillColor: _hasError
                                ? Theme.of(context).errorColor
                                : Theme.of(context).accentColor,
                            inactiveFillColor: Theme.of(context).primaryColor,
                            selectedFillColor: Theme.of(context).accentColor,
                          ),
                          cursorColor: Theme.of(context).accentColor,
                          animationDuration: Duration(milliseconds: 300),
                          textStyle: Theme.of(context).textTheme.headline6,
                          backgroundColor: Theme.of(context).primaryColor,
                          enableActiveFill: true,
                          autoFocus: true,
                          enablePinAutofill: true,
                          autoDismissKeyboard: false,
                          boxShadows: [],
                          errorAnimationController: errorController,
                          controller: textEditingController,
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            setState(() {
                              _code = value;
                            });
                          },
                          beforeTextPaste: (text) {
                            log.d("Allowing to paste $text");
                            //if you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
                            //but you can show anything you want here, like your pop up saying wrong paste format or etc
                            return true;
                          },
                          validator: validate([
                            Required(
                              AppLocalizations.of(context).phoneCodeMissing,
                            ),
                            MinLength(
                              6,
                              AppLocalizations.of(context).phoneCodeTooShort,
                            )
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
                          child: _verifyingCode || _resendingCode
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
                          onPressed: _verifyingCode || _resendingCode
                              ? null
                              : () => _verifyCode(context),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
