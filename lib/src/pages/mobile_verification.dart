import 'package:firebase_auth/firebase_auth.dart';
import 'package:markets/src/models/country_code.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:markets/src/controllers/user_controller.dart';

import '../../generated/l10n.dart';
import '../elements/BlockButtonWidget.dart';
import '../helpers/app_config.dart' as config;

class MobileVerification extends StatefulWidget {
  @override
  _MobileVerificationState createState() => _MobileVerificationState();
}

class _MobileVerificationState extends StateMVC<MobileVerification> {
  String phoneNumber;
  String selectedCountryCode;

  TextEditingController phoneController;
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  String verificationId;
  UserController _con;

  _MobileVerificationState() : super(UserController()) {
    _con = controller;
  }

  @override
  void initState() {
    phoneController = TextEditingController();
    selectedCountryCode = countryCodes[0].number;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final _ac = config.App(context);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: _ac.appWidth(100),
              child: Column(
                children: <Widget>[
                  Text(
                    'Verify Phone ',
                    style: Theme.of(context).textTheme.headline5,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Your phone and address book are used to connect. Call you to verify your phone Number',
                    style: Theme.of(context).textTheme.bodyText2,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
            DropdownButtonHideUnderline(
              child: Container(
                decoration: ShapeDecoration(
                  shape: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: Theme.of(context).focusColor.withOpacity(0.2)),
                  ),
                ),
                child: DropdownButton(
                  value: selectedCountryCode,
                  elevation: 9,
                  onChanged: (value) {
                    setState(() {
                      selectedCountryCode = value;
                    });
                  },
                  items: [
                    ...countryCodes
                        .map((countryCode) => DropdownMenuItem(
                              value: countryCode.number,
                              child: SizedBox(
                                width: _ac.appWidth(70), // for example
                                child: Text(
                                    '(${countryCode.number}) - ${countryCode.name}',
                                    textAlign: TextAlign.center),
                              ),
                            ))
                        .toList()
                  ],
                  // items: [
                  // DropdownMenuItem(
                  //   value: '+213',
                  //   child: SizedBox(
                  //     width: _ac.appWidth(70), // for example
                  //     child: Text('(+213) - Algeria',
                  //         textAlign: TextAlign.center),
                  //   ),
                  // ),
                  //   DropdownMenuItem(
                  //     value: '+216',
                  //     child: SizedBox(
                  //       width: _ac.appWidth(70), // for example
                  //       child: Text('(+216) - Tunisia',
                  //           textAlign: TextAlign.center),
                  //     ),
                  //   ),
                  // ],
                ),
              ),
            ),
            SizedBox(height: 30),
            TextField(
              controller: phoneController,
              textAlign: TextAlign.center,
              decoration: new InputDecoration(
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color: Theme.of(context).focusColor.withOpacity(0.2)),
                ),
                focusedBorder: new UnderlineInputBorder(
                  borderSide: new BorderSide(
                    color: Theme.of(context).focusColor.withOpacity(0.5),
                  ),
                ),
                hintText: 'Phone number',
              ),
              maxLength: 10,
              onSubmitted: (value) {
                _con.user.phone = value;
              },
            ),
            SizedBox(height: 80),
            new BlockButtonWidget(
              onPressed: () async {
                final PhoneCodeAutoRetrievalTimeout autoRetrieve =
                    (String verId) {
                  verificationId = verId;
                };

                final PhoneCodeSent smsCodeSent =
                    (String verId, [int forceCodeResend]) {
                  verificationId = verId;
                  // Navigator.of(context)
                  //     .pushNamed('/MobileVerification2', arguments: verId);
                };

                final PhoneVerificationCompleted verifiedSuccess =
                    (AuthCredential auth) {
                  firebaseAuth
                      .signInWithCredential(auth)
                      .then((UserCredential credential) {
                    if (credential.user != null) {
                      User user = credential.user;
                      print('can go to next page');
                      _con.loginByPhoneNumber();
                      // Navigator.of(context)
                      //     .pushReplacementNamed('/Pages', arguments: 2);
                    } else {
                      debugPrint('user not authorized');
                      showToast('user not authorized');
                    }
                  }).catchError((error) {
                    debugPrint('error : $error');
                    showToast('${error.toString()}');
                  });
                };

                final PhoneVerificationFailed veriFailed =
                    (FirebaseAuthException exception) {
                  print('${exception.message}');
                  showToast('${exception.message}');
                };
                print('$selectedCountryCode${phoneController.text}');
                await FirebaseAuth.instance.verifyPhoneNumber(
                    phoneNumber: '$selectedCountryCode${phoneController.text}',
                    codeAutoRetrievalTimeout: autoRetrieve,
                    codeSent: smsCodeSent,
                    timeout: const Duration(seconds: 5),
                    verificationCompleted: verifiedSuccess,
                    verificationFailed: veriFailed);
              },
              color: Theme.of(context).accentColor,
              text: Text(S.of(context).submit.toUpperCase(),
                  style: Theme.of(context)
                      .textTheme
                      .headline6
                      .merge(TextStyle(color: Theme.of(context).primaryColor))),
            ),
          ],
        ),
      ),
    );
  }

  void showToast(String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 3,
        backgroundColor: Colors.black87,
        textColor: Colors.white,
        fontSize: 16.0);
  }
}
