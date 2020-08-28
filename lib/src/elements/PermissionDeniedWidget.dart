import 'package:flutter/material.dart';
import 'package:markets/src/controllers/user_controller.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../helpers/app_config.dart' as config;

class PermissionDeniedWidget extends StatefulWidget {
  PermissionDeniedWidget({
    Key key,
  }) : super(key: key);

  @override
  _PermissionDeniedWidgetState createState() => _PermissionDeniedWidgetState();
}

class _PermissionDeniedWidgetState extends StateMVC<PermissionDeniedWidget> {
  UserController _con;

  _PermissionDeniedWidgetState() : super(UserController()) {
    _con = controller;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      alignment: AlignmentDirectional.center,
      padding: EdgeInsets.symmetric(horizontal: 30),
      height: config.App(context).appHeight(70),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Center(
            child: Container(
              height: 150.0,
              width: 150.0,
              child: Image.asset('assets/img/logo.png'),
            ),
            // child: Stack(
            //   children: <Widget>[
            //     Container(
            //       width: 150,
            //       height: 150,
            //       decoration: BoxDecoration(
            //           shape: BoxShape.circle,
            //           gradient: LinearGradient(
            //               begin: Alignment.bottomLeft,
            //               end: Alignment.topRight,
            //               colors: [
            //                 Theme.of(context).focusColor.withOpacity(0.7),
            //                 Theme.of(context).focusColor.withOpacity(0.05),
            //               ])),
            //       child: Icon(
            //         Icons.https,
            //         color: Theme.of(context).scaffoldBackgroundColor,
            //         size: 70,
            //       ),
            //     ),
            //     Positioned(
            //       right: -30,
            //       bottom: -50,
            //       child: Container(
            //         width: 100,
            //         height: 100,
            //         decoration: BoxDecoration(
            //           color: Theme.of(context)
            //               .scaffoldBackgroundColor
            //               .withOpacity(0.15),
            //           borderRadius: BorderRadius.circular(150),
            //         ),
            //       ),
            //     ),
            //     Positioned(
            //       left: -20,
            //       top: -50,
            //       child: Container(
            //         width: 120,
            //         height: 120,
            //         decoration: BoxDecoration(
            //           color: Theme.of(context)
            //               .scaffoldBackgroundColor
            //               .withOpacity(0.15),
            //           borderRadius: BorderRadius.circular(150),
            //         ),
            //       ),
            //     ),
            //     Container(
            //       height: 150.0,
            //       width: 150.0,
            //       child: Image.asset('assets/img/logo.png'),
            //     ),
            //   ],
            // ),
          ),
          SizedBox(height: 15),
          Opacity(
            opacity: 0.4,
            child: Text(
              S.of(context).you_must_signin_to_access_to_this_section,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .headline3
                  .merge(TextStyle(fontWeight: FontWeight.w300)),
            ),
          ),
          SizedBox(height: 50),
          FlatButton(
            onPressed: () {
              Navigator.of(context).pushNamed('/Login');
            },
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 70),
            color: Theme.of(context).accentColor.withOpacity(1),
            shape: StadiumBorder(),
            child: Text(
              'Login with Email & Password',
              // S.of(context).login,
              style: Theme.of(context).textTheme.headline6.merge(
                  TextStyle(color: Theme.of(context).scaffoldBackgroundColor)),
            ),
          ),
          SizedBox(height: 20),
          FlatButton(
            onPressed: () {
              Navigator.of(context).pushNamed('/MobileVerification');
            },
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 70),
            color: Theme.of(context).focusColor.withOpacity(1),
            shape: StadiumBorder(),
            child: Text(
              'Login with Phone number',
              // S.of(context).login,
              style: Theme.of(context).textTheme.headline6.merge(
                  TextStyle(color: Theme.of(context).scaffoldBackgroundColor)),
            ),
          ),
          SizedBox(height: 20),
          FlatButton(
            onPressed: () {
              // Navigator.of(context).pushNamed('/MobileVerification');
              _con.signInWithGoogle().whenComplete(() {
                print('Succesfuly logged in');
                _con.register();
              });
            },
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 70),
            color: Theme.of(context).errorColor.withOpacity(1),
            shape: StadiumBorder(),
            child: Text(
              'Login with Google',
              // S.of(context).login,
              style: Theme.of(context).textTheme.headline6.merge(
                  TextStyle(color: Theme.of(context).scaffoldBackgroundColor)),
            ),
          ),
          SizedBox(height: 20),
          FlatButton(
            onPressed: () {
              // Navigator.of(context).pushNamed('/MobileVerification');
              _con.signInWithFacebook();
            },
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 70),
            color: Theme.of(context).primaryColorDark.withOpacity(1),
            shape: StadiumBorder(),
            child: Text(
              'Login with Facebook',
              // S.of(context).login,
              style: Theme.of(context).textTheme.headline6.merge(
                  TextStyle(color: Theme.of(context).scaffoldBackgroundColor)),
            ),
          ),
          SizedBox(height: 20),
          FlatButton(
            onPressed: () {
              Navigator.of(context).pushReplacementNamed('/SignUp');
            },
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 25),
            shape: StadiumBorder(),
            child: Text(
              S.of(context).i_dont_have_an_account,
              style: TextStyle(color: Theme.of(context).focusColor),
            ),
          ),
        ],
      ),
    );
  }
}
