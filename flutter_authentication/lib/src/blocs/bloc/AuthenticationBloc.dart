import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_authentication/src/Repository.dart';

import 'package:flutter_authentication/src/blocs/events/AuthenticationStates.dart';
import 'package:flutter_authentication/src/blocs/states/AuthenticationStates.dart';
import 'package:flutter_authentication/src/model/ErrorViewModel.dart';
import 'package:flutter_authentication/src/model/ResponseViewModel.dart';
import 'package:flutter_authentication/src/utilities/NetworkUtilities.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

class AuthenticationBloc extends Bloc<AuthenticationEvents , AuthenticationStates>{
  AuthenticationBloc(AuthenticationStates initialState) : super(initialState);



  //----------------- phone Authentication ---------------------------------
  String phoneAuthenticationId ;
  onMessageReceived(String verificationId) {
    phoneAuthenticationId = verificationId;
    add(MoveToState(targetState: PendingUserSMSCode()));
  }
  onAuthCompleted(AuthCredential credentials) {
    add(LoginWithCredentials(credential: credentials,));
  }
  onAuthFailed(FirebaseAuthException error) {
    String errorMessage = '';
    if (error.code.contains('invalid-verification-code')) {
      errorMessage = 'Invalid verification code';
    } else if (error.code.contains('too-many-requests')) {
      errorMessage = 'User consumed many requests please try again in while';
    } else if(error.code.contains('session-expired')){
      errorMessage = 'Your sms code is expired :( , please try typing your Phone number to receive new SMS';
    } else {
      errorMessage = 'Invalid Phone number provided';

    }
    add(MoveToState(targetState: AuthenticationFailed(error: ErrorViewModel(errorMessage: errorMessage, errorCode: HttpStatus.notFound))));
    return;
  }
  onAuthVerificationCodeIdChange(String verificationId) {
    phoneAuthenticationId = verificationId;
  }
  //------------------------------------------------------------------------

  User firebaseUser ;


  @override
  Stream<AuthenticationStates> mapEventToState(AuthenticationEvents event) async*{

    bool isUserConnected = await NetworkUtilities.isConnected();
    if(isUserConnected == false){
      yield AuthenticationFailed(error: ErrorViewModel(errorMessage: 'Please Check your connection', errorCode: HttpStatus.requestTimeout));
      return;
    }


    if(event is RequestLoginWithMethod){
      yield* _handleLoginMethodRequest(event);
      return;
    }

    if(event is AuthenticateUser){
      yield* _handleCheckIfUserExist(event);
    }

    else if(event is LoginWithCredentials){
     yield* _handleLoginWithCredentials(event);
      return;
    }
    else if(event is VerifyUserNumber){
      add(LoginWithCredentials(credential: PhoneAuthProvider.credential(verificationId: phoneAuthenticationId, smsCode: event.smsCode)));
      return;
    }
    else if (event is MoveToState){
      yield event.targetState;
      return;
    }
    else if(event is LogoutUser){
     yield* _handleLogoutUser(event);
     return;
    }
  }

  Stream<AuthenticationStates>  _handleLoginMethodRequest(RequestLoginWithMethod event) async*{
    yield AuthenticationLoading();
    ResponseViewModel<AuthCredential> credential;
    switch (event.loginPlatform) {
      case LoginMethod.PHONE:
        await Repository.verifyPhoneNumber(
            event.userPhoneNumber, onCodeSent: onMessageReceived,
            onVerificationCompleted: onAuthCompleted,
            onVerificationFail: onAuthFailed,
            onVerificationIdTimeout: onAuthVerificationCodeIdChange);
        break;
      case LoginMethod.FACEBOOK:
        credential = await Repository.loginWithFacebook();
        break;
      case LoginMethod.GOOGLE:
        credential = await Repository.loginWithGoogle();
        break;
      case LoginMethod.APPLE:
        credential = await Repository.loginWithApple();
        break;

      case LoginMethod.ANONYMOUSLY:
        yield* loginAnonymously();
        break;
      default:
        break;
    }

    if(credential != null) {
      if (credential.isSuccess) {
        add(LoginWithCredentials(credential: credential.responseData));
      }
      else {

        yield AuthenticationFailed(error: credential.errorViewModel);
        return;
      }
    } else {
      yield AuthenticationFailed(error: ErrorViewModel(errorCode: 300 , errorMessage: ''));
    }
    return;
  }

  Stream<AuthenticationStates>  _handleLoginWithCredentials(LoginWithCredentials event) async*{
    yield AuthenticationLoading();
    if(event.credential != null){
      ResponseViewModel<User> userModelResponse = await Repository.loginWithCredentials(event.credential);
      if(userModelResponse.isSuccess){
        firebaseUser = userModelResponse.responseData;
        yield AuthenticationSuccess();
      }
      else{
        yield AuthenticationFailed(error: userModelResponse.errorViewModel);
        return;
      }
    }
    else {
      yield AuthenticationFailed(error: ErrorViewModel(errorCode:300, errorMessage: 'something went wrong please try again later' ));
      return;
    }

  }

  Stream<AuthenticationStates> loginAnonymously() async*{
    ResponseViewModel<User> user = await Repository.loginAnonymously();
    if(user.isSuccess){
      firebaseUser = user.responseData;
      yield AuthenticationSuccess();
      return;
    } else {
      yield AuthenticationFailed(error: ErrorViewModel(errorCode: 300 , errorMessage: 'Unexpected error happened while logging you in'));
    }
  }

  Stream<AuthenticationStates> _handleLogoutUser(LogoutUser event) async*{
    ResponseViewModel<bool> logoutResult = await Repository.logoutUser();

    if(logoutResult.isSuccess){
      firebaseUser = null;
      yield AuthenticationInitialized();
      return;
    } else {
      yield AuthenticationFailed(error: logoutResult.errorViewModel);
      return;
    }
  }

  Stream<AuthenticationStates> _handleCheckIfUserExist(AuthenticateUser event) async*{
   User user = await Repository.getCurrentUser();
   if(user == null){
     yield AuthenticationInitialized();
     return;
   }
   else {
     firebaseUser = user;
     yield AuthenticationSuccess();
     return;
   }

  }







}