import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../generated/l10n.dart';
import '../elements/BlockButtonWidget.dart';
import '../helpers/app_config.dart' as config;

class MobileVerification2 extends StatefulWidget {
  final String verificationCode;

  MobileVerification2({Key key, this.verificationCode}) : super(key: key);

  @override
  _MobileVerification2State createState() => _MobileVerification2State();
}

class _MobileVerification2State extends State<MobileVerification2> {
  TextEditingController otpController;
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  @override
  void initState() {
    otpController = TextEditingController();
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
                    'Verify Your Account',
                    style: Theme.of(context).textTheme.headline5,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'We are sending OTP to validate your mobile number. Hang on!',
                    style: Theme.of(context).textTheme.bodyText2,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            SizedBox(height: 50),
            TextField(
              style: Theme.of(context).textTheme.headline5,
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
                hintText: '000-000',
              ),
            ),
            SizedBox(height: 15),
            Text(
              'SMS has been sent to +155 4585 555',
              style: Theme.of(context).textTheme.caption,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 80),
            new BlockButtonWidget(
              onPressed: () {
                var _authCredential = PhoneAuthProvider.credential(
                    verificationId: widget.verificationCode,
                    smsCode: otpController.text);
                showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) {
                      return Container(
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    });
                firebaseAuth
                    .signInWithCredential(_authCredential)
                    .then((UserCredential credential) {
                  User user = credential.user;

                  if (user != null) {
                    Navigator.of(context)
                        .pushReplacementNamed('/Pages', arguments: 2);
                  }

                  ///go To Next Page
                }).catchError((error) {
                  Navigator.pop(context);
                });
              },
              color: Theme.of(context).accentColor,
              text: Text(S.of(context).verify.toUpperCase(),
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
}
