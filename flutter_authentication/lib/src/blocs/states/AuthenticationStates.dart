import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_authentication/src/model/ErrorViewModel.dart';

abstract class AuthenticationStates {}


class AuthenticationInitialized extends AuthenticationStates{}
class AuthenticationSuccess extends AuthenticationStates{}
class AuthenticationLoading extends AuthenticationStates{}
class AuthenticationFailed extends AuthenticationStates{

  final ErrorViewModel error;
  AuthenticationFailed({@required this.error});


}
class AuthenticationCredentialsObtained extends AuthenticationStates{
  final AuthCredential credentials;
  AuthenticationCredentialsObtained({@required this.credentials});

}
class PendingUserSMSCode extends AuthenticationStates{}