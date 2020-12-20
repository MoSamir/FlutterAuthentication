import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_authentication/src/blocs/bloc/AuthenticationBloc.dart';
import 'package:flutter_authentication/src/blocs/events/AuthenticationStates.dart';
import 'package:flutter_authentication/src/blocs/states/AuthenticationStates.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import 'HomeScreen.dart';

class PhoneAuthentication extends StatefulWidget {
  @override
  _PhoneAuthenticationState createState() => _PhoneAuthenticationState();
}

class _PhoneAuthenticationState extends State<PhoneAuthentication> {

  final GlobalKey<FormState> _phoneNumberAuthFormKey = GlobalKey<FormState>();
  TextEditingController _phoneSmsCode = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Verify your phone number'),
        ),
      body: BlocConsumer(
        cubit: BlocProvider.of<AuthenticationBloc>(context),
        listener: (context, state){
          if (state is AuthenticationSuccess) {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => HomeScreen()));
          }
          if (state is AuthenticationFailed) {
            if (state.error.errorCode == HttpStatus.requestTimeout) {
              Fluttertoast.showToast(
                  msg: "Check your connection and try again",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                  fontSize: 16.0
              );
              return;
            }
            else if (state.error.errorCode == HttpStatus.serviceUnavailable) {
              Fluttertoast.showToast(
                  msg: "Please try again in while",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                  fontSize: 16.0
              );
              return;
            }
            else if (state.error.errorCode != 401) {
              Fluttertoast.showToast(
                  msg: state.error.errorMessage,
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                  fontSize: 16.0
              );
              return;
            }
          }
        },
        builder: (context, state){
          return ModalProgressHUD(
              inAsyncCall: state is AuthenticationLoading,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20 , vertical: 5),
                child: Form(
                  key: _phoneNumberAuthFormKey,
                  child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
                  TextFormField(
                    controller: _phoneSmsCode,
                    validator: (String input){
                    return  input == null || input.length == 0 ? 'Required Field missing' : null;
                    },
                  ),
                  SizedBox(height: 20,),
                  FlatButton(onPressed: (){
                    BlocProvider.of<AuthenticationBloc>(context).add(VerifyUserNumber(smsCode: _phoneSmsCode.text));
                  }, child: Text('Login')),

            ],
          ),
                ),
              ));
        },
      ),
    );
  }
}
