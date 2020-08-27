import 'package:firebase_auth/firebase_auth.dart';
import '../helpers/helper.dart';
import '../models/country_code.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../controllers/user_controller.dart';
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
  bool otpSent;
  TextEditingController phoneController;
  TextEditingController otpController;
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  String verificationId;
  UserController _con;
  OverlayEntry loader;
  GlobalKey<ScaffoldState> scaffoldKey;

  _MobileVerificationState() : super(UserController()) {
    _con = controller;
    loader = Helper.overlayLoader(context);
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
  }

  @override
  void initState() {
    phoneController = TextEditingController();
    otpController = TextEditingController();
    selectedCountryCode = countryCodes[0].number;
    otpSent = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final _ac = config.App(context);
    return Scaffold(
      key: _con.scaffoldKey,
      body: otpSent ? otpVerification(_ac) : phoneVerification(_ac),
    );
  }

  Widget phoneVerification(config.App ac) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 40, left: 40, right: 40),
          child: Form(
            key: _con.phoneFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  width: ac.appWidth(100),
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
                            color:
                                Theme.of(context).focusColor.withOpacity(0.2)),
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
                                    width: ac.appWidth(70), // for example
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
                  onChanged: (value) {
                    _con.user.phone = '$selectedCountryCode$value';
                  },
                ),
                SizedBox(height: 80),
                new BlockButtonWidget(
                  onPressed: () async {
                    // FocusScope.of(context).unfocus();
                    // Overlay.of(context).insert(loader);
                    final PhoneCodeAutoRetrievalTimeout autoRetrieve =
                        (String verId) {
                      setState(() {
                        verificationId = verId;
                        // otpSent = true;
                      });
                    };

                    final PhoneCodeSent smsCodeSent =
                        (String verId, [int forceCodeResend]) {
                      setState(() {
                        verificationId = verId;
                        otpSent = true;
                      });
                      print('VerificationId: $verificationId');
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
                          setState(() {
                            otpSent = false;
                          });
                        }
                      }).catchError((error) {
                        debugPrint('error : $error');
                        showToast('${error.toString()}');
                        setState(() {
                          otpSent = false;
                        });
                      });
                    };

                    final PhoneVerificationFailed veriFailed =
                        (FirebaseAuthException exception) {
                      print('${exception.message}');
                      showToast('${exception.message}');
                      setState(() {
                        otpSent = false;
                      });
                    };
                    print('PhoneVerify:201 - ${_con.user.phone}');
                    await FirebaseAuth.instance.verifyPhoneNumber(
                        phoneNumber: _con.user.phone,
                        codeAutoRetrievalTimeout: autoRetrieve,
                        codeSent: smsCodeSent,
                        timeout: const Duration(seconds: 5),
                        verificationCompleted: verifiedSuccess,
                        verificationFailed: veriFailed);
                  },
                  color: Theme.of(context).accentColor,
                  text: Text(S.of(context).submit.toUpperCase(),
                      style: Theme.of(context).textTheme.headline6.merge(
                          TextStyle(color: Theme.of(context).primaryColor))),
                ),
                SizedBox(
                  height: 50,
                ),
                FlatButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed('/SignUp');
                  },
                  textColor: Theme.of(context).hintColor,
                  child: Text(S.of(context).i_dont_have_an_account),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget otpVerification(config.App ac) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Form(
            key: _con.otpFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  width: ac.appWidth(100),
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
                  controller: otpController,
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
                Row(
                  children: [
                    Text(
                      'SMS has been sent to ${_con.user.phone}',
                      style: Theme.of(context).textTheme.caption,
                      textAlign: TextAlign.center,
                    ),
                    FlatButton(
                      onPressed: () {
                        setState(() {
                          otpSent = false;
                        });
                      },
                      textColor: Theme.of(context).hintColor,
                      child: Text('CHANGE'),
                    ),
                  ],
                ),
                SizedBox(height: 80),
                new BlockButtonWidget(
                  onPressed: () {
                    var _authCredential = PhoneAuthProvider.credential(
                        verificationId: verificationId,
                        smsCode: otpController.text);
                    // showDialog(
                    //     context: context,
                    //     barrierDismissible: false,
                    //     builder: (context) {
                    //       return Container(
                    //         child: Center(
                    //           child: CircularProgressIndicator(),
                    //         ),
                    //       );
                    //     });
                    print(
                        'VerificationId: $verificationId, SmsCode: $otpController.text');
                    firebaseAuth
                        .signInWithCredential(_authCredential)
                        .then((UserCredential credential) {
                      User user = credential.user;

                      if (user != null) {
                        _con.loginByOtp();
                      }

                      ///go To Next Page
                    }).catchError((error) {
                      setState(() {
                        otpSent = false;
                      });
                    });
                  },
                  color: Theme.of(context).accentColor,
                  text: Text(S.of(context).verify.toUpperCase(),
                      style: Theme.of(context).textTheme.headline6.merge(
                          TextStyle(color: Theme.of(context).primaryColor))),
                ),
                SizedBox(height: 50),
                FlatButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed('/SignUp');
                  },
                  textColor: Theme.of(context).hintColor,
                  child: Text('Don\'t have an account? Register here.'),
                ),
              ],
            ),
          ),
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
