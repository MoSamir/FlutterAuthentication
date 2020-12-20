import 'package:apple_sign_in/apple_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_authentication/src/model/ErrorViewModel.dart';
import 'package:flutter_authentication/src/model/ResponseViewModel.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthenticationProviders {

  static Future<ResponseViewModel<AuthCredential>> loginWithFacebook() async{
    try {
      AccessToken accessToken = await FacebookAuth.instance.login();
      return ResponseViewModel<AuthCredential>(
        isSuccess: true,
        responseData: FacebookAuthProvider.credential(accessToken.token),
      );
    } on FacebookAuthException catch (e) {
      switch (e.errorCode) {
        case FacebookAuthErrorCode.OPERATION_IN_PROGRESS:
          return ResponseViewModel<AuthCredential>(
            isSuccess: false,
            errorViewModel: ErrorViewModel(
              errorMessage: '',
              errorCode: 300,
            ),
          );
          break;
        case FacebookAuthErrorCode.CANCELLED:
          return ResponseViewModel<AuthCredential>(
            isSuccess: false,
            errorViewModel: ErrorViewModel(
              errorMessage: '',
              errorCode: 300,
            ),
          );
          break;
        case FacebookAuthErrorCode.FAILED:
          return ResponseViewModel<AuthCredential>(
            isSuccess: false,
            errorViewModel: ErrorViewModel(
              errorMessage: e.message,
              errorCode: 300,
            ),
          );
          break;
        default:
          return ResponseViewModel<AuthCredential>(
            isSuccess: false,
            errorViewModel: ErrorViewModel(
              errorMessage: '',
              errorCode: 300,
            ),
          );
      }
    }

  }

  static Future<ResponseViewModel<AuthCredential>> loginWithGoogle() async{
    GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email'],);
      try {
        GoogleSignInAccount user = await _googleSignIn.signIn();

        GoogleSignInAuthentication authenticationCredentials = await user.authentication;
        return ResponseViewModel<AuthCredential>(
          isSuccess: true,
          responseData: GoogleAuthProvider.credential(accessToken: authenticationCredentials.accessToken,
           idToken: authenticationCredentials.idToken),
        );
      } catch (error) {
        return ResponseViewModel<AuthCredential>(
          isSuccess: false,
          errorViewModel: ErrorViewModel(
            errorCode: 300,
            errorMessage: error.toString(),
          ),
        );
      }

  }

  static Future<ResponseViewModel<AuthCredential>> loginWithApple() async{
     final AuthorizationResult result = await AppleSignIn.performRequests([
     AppleIdRequest(requestedScopes: [Scope.email, Scope.fullName])]);
   if(result.status == AuthorizationStatus.authorized){
     final appleCredentials = result.credential;
     final oAuthProvider = OAuthProvider('apple.com');
     return ResponseViewModel<AuthCredential>(
       isSuccess: true,
       responseData: oAuthProvider.credential(
           accessToken: String.fromCharCodes(
               appleCredentials.authorizationCode),
           idToken: String.fromCharCodes(appleCredentials.identityToken)
       ),
     );
   }
   else {
     return ResponseViewModel<AuthCredential>(
         isSuccess: false,
       errorViewModel: ErrorViewModel(
         errorCode: 300,
         errorMessage: result.error.localizedFailureReason
       ),
     );
   }
  }

  // ignore: missing_return
  static Future<void> verifyUserPhoneNumber(String phoneNumber, Function onCodeSent, Function onVerificationCompleted, Function onVerificationIdTimeout, Function onVerificationFail) {
    FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (AuthCredential credentials) {
          onVerificationCompleted(credentials);
          return;
        },
        verificationFailed: (FirebaseAuthException exception) {
          onVerificationFail(exception);
          return;
        },
        codeSent: (String tokenId, int foreResend) {
          onCodeSent(tokenId);
          return;
        },
        codeAutoRetrievalTimeout: (String tokenId) {
          onVerificationIdTimeout(tokenId);
          return;
        });
  }

  static Future<ResponseViewModel<User>>loginWithCredentials(AuthCredential credentials) async{

    try{
      UserCredential firebaseUserCredentials = (await FirebaseAuth.instance.signInWithCredential(credentials));
      if(firebaseUserCredentials != null && firebaseUserCredentials.user != null){
        return ResponseViewModel<User>(
          isSuccess: true,
          responseData: firebaseUserCredentials.user,
        );
      }
      else{
        return ResponseViewModel<User>(
          isSuccess: false,
          errorViewModel: ErrorViewModel(
              errorCode: 300,
              errorMessage: 'unable to sign you in please try again later'
          ),
        );
      }
    } catch(exception){
      print(exception);
      String errorMessage = '';
      if (exception.code.contains('invalid-verification-code')) {
        errorMessage = 'Invalid verification code';
      } else if (exception.code.contains('too-many-requests')) {
        errorMessage = 'User consumed many requests please try again in while';
      } else if(exception.code.contains('session-expired')){
        errorMessage = 'Your sms code is expired :( , please try typing your Phone number to receive new SMS';
      }  else {
        errorMessage = 'Invalid Phone number provided';
      }
      return ResponseViewModel<User>(
        isSuccess: false,
        errorViewModel: ErrorViewModel(
            errorCode: 300,
            errorMessage: errorMessage,
        ),
      );
    }
  }

  static Future<ResponseViewModel<User>> loginAnonymously() async{
    UserCredential firebaseUserCredentials = (await FirebaseAuth.instance.signInAnonymously());
    if(firebaseUserCredentials != null && firebaseUserCredentials.user != null){
      return ResponseViewModel<User>(
        isSuccess: true,
        responseData: firebaseUserCredentials.user,
      );
    }
    else{
      return ResponseViewModel<User>(
        isSuccess: false,
        errorViewModel: ErrorViewModel(
            errorCode: 300,
            errorMessage: 'unable to sign you in please try again later'
        ),
      );
    }
  }

  static Future<ResponseViewModel<bool>>logout() async{
    try{
      await FirebaseAuth.instance.signOut();
      return ResponseViewModel<bool>(
          isSuccess: true,
          responseData: true
      );
    } catch(exception){
      return ResponseViewModel<bool>(
          isSuccess: false,
        errorViewModel: ErrorViewModel(
          errorMessage: 'Something went wrong try again later please',
          errorCode: 300
        ),
      );
    }
  }

  static Future<User> getCurrentUser() async{
    return FirebaseAuth.instance.currentUser;
  }






}