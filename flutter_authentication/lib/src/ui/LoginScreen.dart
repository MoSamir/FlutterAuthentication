import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_authentication/src/blocs/bloc/AuthenticationBloc.dart';
import 'package:flutter_authentication/src/blocs/events/AuthenticationStates.dart';
import 'package:flutter_authentication/src/blocs/states/AuthenticationStates.dart';
import 'package:flutter_authentication/src/ui/HomeScreen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:international_phone_input/international_phone_input.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import 'PhoneAuthentication.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  AuthenticationBloc authenticaitonBloc;

  TextEditingController _phoneNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    authenticaitonBloc = BlocProvider.of<AuthenticationBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: BlocConsumer(
      cubit: authenticaitonBloc,
      listener: (context, state) {

        if (state is AuthenticationSuccess) {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => HomeScreen()));
        }
        else if(state is PendingUserSMSCode){
          Navigator.of(context).push(MaterialPageRoute(builder: (context)=> PhoneAuthentication()));
          return;
        }
      },
      builder: (context, state) {

        return ModalProgressHUD(
          inAsyncCall: state is AuthenticationLoading,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Text('Login with' , textAlign: TextAlign.center, style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 25,
                ),),
              ),


              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FlatButton.icon(
                      onPressed: () {
                        loginViaPhoneNumber(context);
                      },
                      icon: Icon(Icons.phone),
                      label: Text(
                        'Phone Number',
                        textAlign: TextAlign.center,
                      )),
                  FlatButton.icon(
                      icon: FaIcon(FontAwesomeIcons.google , color: Colors.red,),
                      onPressed: () {
                        authenticaitonBloc
                            .add(RequestLoginWithMethod(LoginMethod.GOOGLE));
                        return;
                      },
                      label: Text('Google')),
                ],
              ),
              SizedBox(height: 10,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FlatButton.icon(
                    icon: FaIcon(FontAwesomeIcons.facebook , color: Colors.blue[900],),
                      onPressed: () {
                        authenticaitonBloc
                            .add(RequestLoginWithMethod(LoginMethod.FACEBOOK));
                        return;
                      },
                      label: Text('Facebook')),
                  FlatButton.icon(
                    icon: Icon(Icons.account_circle_outlined),
                      onPressed: () {
                        authenticaitonBloc
                            .add(RequestLoginWithMethod(LoginMethod.ANONYMOUSLY));
                        return;
                      },
                      label: Text('Anonymously')),
                ],
              ),
              SizedBox(height: 10,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [FlatButton.icon(
                    icon: FaIcon(FontAwesomeIcons.apple),
                    onPressed: () {
                      if(Platform.isIOS){
                        authenticaitonBloc
                            .add(RequestLoginWithMethod(LoginMethod.APPLE));
                        return;
                      } else {
                        Fluttertoast.showToast(
                            msg: "Supported for iPhone only",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                            fontSize: 16.0
                        );
                      }
                    },
                    label: Text('Apple')),],
              )
            ],
          ),
        );
      },
    ));
  }

  void loginViaPhoneNumber(BuildContext context) {

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Container(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: InternationalPhoneInput(
                onPhoneNumberChange: onPhoneNumberChange,
                enabledCountries: ['+20'],
                hintText: 'Enter you phone number',
                showCountryFlags: true,
              ),
            ),
          ),
          actions: [
            FlatButton(
              onPressed: () {
                if(_phoneNumberController.text != null){
                  authenticaitonBloc.add(RequestLoginWithMethod(
                      LoginMethod.PHONE,
                      userPhoneNumber: _phoneNumberController.text));
                  Navigator.pop(context);
                } else {
                  Fluttertoast.showToast(
                      msg: "Invalid Phone Number",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      fontSize: 16.0
                  );
                }
              },
              child: Text('Validate'),
            ),
            FlatButton(
                onPressed: () {
                  _phoneNumberController.clear();
                  Navigator.pop(context);
                },
                child: Text('Cancel'))
          ],
        ));
  }

  void onPhoneNumberChange(String phoneNumber, String internationalizedPhoneNumber, String isoCode) {
    _phoneNumberController.text = internationalizedPhoneNumber;
  }
}
