import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
// import 'package:firestore/custom_web_view.dart';

import '../../generated/l10n.dart';
import '../helpers/helper.dart';
import '../models/user.dart';
import '../repository/user_repository.dart' as repository;

String your_client_id = "518416208939727";
String your_redirect_url =
    "https://www.facebook.com/connect/login_success.html";

class UserController extends ControllerMVC {
  User user = new User();
  bool hidePassword = true;
  bool loading = false;
  GlobalKey<FormState> loginFormKey;
  GlobalKey<FormState> phoneFormKey;
  GlobalKey<FormState> otpFormKey;
  GlobalKey<ScaffoldState> scaffoldKey;
  FirebaseMessaging _firebaseMessaging;
  OverlayEntry loader;

  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  UserController() {
    loader = Helper.overlayLoader(context);
    loginFormKey = new GlobalKey<FormState>();
    phoneFormKey = new GlobalKey<FormState>();
    otpFormKey = new GlobalKey<FormState>();
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
    _firebaseMessaging = FirebaseMessaging();
    _firebaseMessaging.getToken().then((String _deviceToken) {
      user.deviceToken = _deviceToken;
    }).catchError((e) {
      print('Notification not configured');
    });
  }

  void login() async {
    FocusScope.of(context).unfocus();
    if (loginFormKey.currentState.validate()) {
      loginFormKey.currentState.save();
      Overlay.of(context).insert(loader);
      repository.login(user).then((value) {
        if (value != null && value.apiToken != null) {
          Navigator.of(scaffoldKey.currentContext)
              .pushReplacementNamed('/Pages', arguments: 2);
        } else {
          scaffoldKey?.currentState?.showSnackBar(SnackBar(
            content: Text(S.of(context).wrong_email_or_password),
          ));
        }
      }).catchError((e) {
        loader.remove();
        scaffoldKey?.currentState?.showSnackBar(SnackBar(
          content: Text(S.of(context).this_account_not_exist),
        ));
      }).whenComplete(() {
        Helper.hideLoader(loader);
      });
    }
  }

  Future<User> phoneChecker() async {
    FocusScope.of(context).unfocus();
    Overlay.of(context).insert(loader);
    return await repository
        .getUserDetailsForPhoneAuth(user)
        .then((value) => value)
        .catchError((e) => repository.currentUser);
  }

  void loginByPhoneNumber() async {
    FocusScope.of(context).unfocus();
    // if (phoneFormKey.currentState.validate()) {
    // phoneFormKey.currentState.save();
    Overlay.of(context).insert(loader);
    repository.getUserDetailsForPhoneAuth(user).then((value) {
      if (value != null && value.apiToken != null) {
        Navigator.of(scaffoldKey.currentContext)
            .pushReplacementNamed('/Pages', arguments: 2);
      } else {
        scaffoldKey?.currentState?.showSnackBar(SnackBar(
          content: Text(S.of(context).wrong_email_or_password),
        ));
      }
    }).catchError((e) {
      loader.remove();
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text('${user.phone} number is not registerd.'),
      ));
    }).whenComplete(() {
      Helper.hideLoader(loader);
    });
    // }
  }

  void loginByOtp() async {
    FocusScope.of(context).unfocus();
    // if (otpFormKey.currentState.validate()) {
    // otpFormKey.currentState.save();
    Overlay.of(context).insert(loader);
    repository.getUserDetailsForPhoneAuth(user).then((value) {
      if (value != null && value.apiToken != null) {
        Navigator.of(scaffoldKey.currentContext)
            .pushReplacementNamed('/Pages', arguments: 2);
      } else {
        scaffoldKey?.currentState?.showSnackBar(SnackBar(
          content: Text(S.of(context).wrong_email_or_password),
        ));
      }
    }).catchError((e) {
      loader.remove();
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text('${user.phone} number is not registerd.'),
      ));
      Helper.hideLoader(loader);
    }).whenComplete(() {
      Helper.hideLoader(loader);
    });
    // }
  }

  void register() async {
    FocusScope.of(context).unfocus();
    if (loginFormKey.currentState.validate()) {
      loginFormKey.currentState.save();
      Overlay.of(context).insert(loader);
      repository.register(user).then((value) {
        if (value != null && value.apiToken != null) {
          Navigator.of(scaffoldKey.currentContext)
              .pushReplacementNamed('/Pages', arguments: 2);
        } else {
          scaffoldKey?.currentState?.showSnackBar(SnackBar(
            content: Text(S.of(context).wrong_email_or_password),
          ));
        }
      }).catchError((e) {
        loader.remove();
        print(e.toString());
        scaffoldKey?.currentState?.showSnackBar(SnackBar(
          content: Text('Email or phone already exists.'),
          // content: Text(S.of(context).this_email_account_exists),
        ));
      }).whenComplete(() {
        Helper.hideLoader(loader);
      });
    }
  }

  Future<User> registerSocial() async {
    // FocusScope.of(context).unfocus();
    // if (loginFormKey.currentState.validate()) {
    // loginFormKey.currentState.save();
    return repository.register(user);
    Overlay.of(context).insert(loader);
    // repository.register(user).then((value) {
    //   if (value != null && value.apiToken != null) {
    //     Navigator.of(scaffoldKey.currentContext)
    //         .pushReplacementNamed('/Pages', arguments: 2);
    //   } else {
    //     scaffoldKey?.currentState?.showSnackBar(SnackBar(
    //       content: Text(S.of(context).wrong_email_or_password),
    //     ));
    //   }
    // }).catchError((e) {
    //   loader.remove();
    //   print(e.toString());
    //   scaffoldKey?.currentState?.showSnackBar(SnackBar(
    //     content: Text('Email or phone already exists.'),
    //     // content: Text(S.of(context).this_email_account_exists),
    //   ));
    // }).whenComplete(() {
    //   Helper.hideLoader(loader);
    // });
    // }
  }

  void resetPassword() {
    FocusScope.of(context).unfocus();
    if (loginFormKey.currentState.validate()) {
      loginFormKey.currentState.save();
      Overlay.of(context).insert(loader);
      repository.resetPassword(user).then((value) {
        if (value != null && value == true) {
          scaffoldKey?.currentState?.showSnackBar(SnackBar(
            content:
                Text(S.of(context).your_reset_link_has_been_sent_to_your_email),
            action: SnackBarAction(
              label: S.of(context).login,
              onPressed: () {
                Navigator.of(scaffoldKey.currentContext)
                    .pushReplacementNamed('/Login');
              },
            ),
            duration: Duration(seconds: 10),
          ));
        } else {
          loader.remove();
          scaffoldKey?.currentState?.showSnackBar(SnackBar(
            content: Text(S.of(context).error_verify_email_settings),
          ));
        }
      }).whenComplete(() {
        Helper.hideLoader(loader);
      });
    }
  }

  Future<String> signInWithGoogle() async {
    try {
      final GoogleSignInAccount googleSignInAccount =
          await googleSignIn.signIn().catchError((onError) => print(onError));

// Return null to prevent further exceptions if googleSignInAccount is null
      if (googleSignInAccount == null) return null;
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      final auth.AuthCredential credential = auth.GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      final auth.UserCredential authResult =
          await _auth.signInWithCredential(credential);
      final auth.User authUser = authResult.user;

      assert(!authUser.isAnonymous);
      assert(await authUser.getIdToken() != null);

      final auth.User currentUser = await _auth.currentUser;
      assert(authUser.uid == currentUser.uid);

      user.email = authUser.email;
      user.name = authUser.displayName;
      user.social = 'google';

      return 'signInWithGoogle succeeded: $user';
    } on PlatformException catch (e) {
      print(e.toString());
      scaffoldKey?.currentState?.showSnackBar(
        SnackBar(
          content: Text('An error occured while login.'),
          // content: Text(S.of(context).error_verify_email_settings),
        ),
      );
    }
    return null;
  }

  void signOutGoogle() async {
    await googleSignIn.signOut();

    print("User Sign Out");
  }

  void signInWithFacebook() async {
    try {
      // Trigger the sign-in flow
      final LoginResult result = await FacebookAuth.instance.login();

      // Create a credential from the access token
      final auth.FacebookAuthCredential facebookAuthCredential =
          auth.FacebookAuthProvider.credential(result.accessToken.token);

      // Once signed in, return the UserCredential
      auth.UserCredential userCredential = await auth.FirebaseAuth.instance
          .signInWithCredential(facebookAuthCredential);
      user.name = userCredential.user.displayName;
      user.email = userCredential.user.email;
      user.social = 'facebook';
    } on PlatformException catch (e) {
      print('Facebook Login Error: ${e.toString()}');
    }
  }

  signOutFacebook() async {
    await FacebookAuth.instance.logOut();
  }

  signOut() async {
    await signOutGoogle();
    // await signOutFacebook();
    await repository.logout();
  }
}
