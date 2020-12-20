import 'package:firebase_auth/firebase_auth.dart';

import 'apis/AuthenticationProviders.dart';
import 'model/ResponseViewModel.dart';


class Repository {

  static Future<ResponseViewModel<AuthCredential>> loginWithFacebook () async =>
                                                  await AuthenticationProviders.loginWithFacebook();
  static Future<ResponseViewModel<AuthCredential>> loginWithGoogle () async =>
      await AuthenticationProviders.loginWithGoogle();

  static Future<ResponseViewModel<AuthCredential>> loginWithApple() async => await AuthenticationProviders.loginWithApple();



  static Future<void> verifyPhoneNumber(String phoneNumber , {
    Function onCodeSent , Function onVerificationCompleted ,
    Function onVerificationIdTimeout , Function onVerificationFail}) async =>
      await AuthenticationProviders.verifyUserPhoneNumber(phoneNumber, onCodeSent,
          onVerificationCompleted,onVerificationIdTimeout,onVerificationFail);

  static Future<ResponseViewModel<User>> loginWithCredentials (AuthCredential credentials) async =>
      await AuthenticationProviders.loginWithCredentials(credentials);

  static  Future<ResponseViewModel<User>> loginAnonymously()  async =>
      await AuthenticationProviders.loginAnonymously();


  static  Future<ResponseViewModel<bool>> logoutUser()  async =>
      await AuthenticationProviders.logout();

  static Future<User> getCurrentUser() async => await AuthenticationProviders.getCurrentUser();




}