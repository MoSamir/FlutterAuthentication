import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_authentication/src/blocs/states/AuthenticationStates.dart';

abstract class AuthenticationEvents {}



class RequestLoginWithMethod extends AuthenticationEvents{
  final LoginMethod loginPlatform;
  final String userPhoneNumber ;
  RequestLoginWithMethod(this.loginPlatform , {this.userPhoneNumber});
}

class AuthenticateUser extends AuthenticationEvents{}

class VerifyUserNumber extends AuthenticationEvents{
  final String smsCode ;
  VerifyUserNumber({this.smsCode});
}


class LoginWithCredentials extends AuthenticationEvents{
  final AuthCredential credential;
  LoginWithCredentials({@required this.credential});
}

class LogoutUser extends AuthenticationEvents{}

class MoveToState extends AuthenticationEvents{
  final AuthenticationStates targetState ;
  MoveToState({@required this.targetState});

}

enum LoginMethod{
  PHONE,
  FACEBOOK,
  GOOGLE,
  APPLE,
  ANONYMOUSLY,
}