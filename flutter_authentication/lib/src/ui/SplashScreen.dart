import 'package:flutter/material.dart';
import 'package:flutter_authentication/src/blocs/bloc/AuthenticationBloc.dart';
import 'package:flutter_authentication/src/blocs/events/AuthenticationStates.dart';
import 'package:flutter_authentication/src/blocs/states/AuthenticationStates.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'HomeScreen.dart';
import 'LoginScreen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    BlocProvider.of<AuthenticationBloc>(context).add(AuthenticateUser());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer(
      listener: (context , state){
        if(state is AuthenticationInitialized){
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=> LoginScreen()));
          return;
        }
        else if(state is AuthenticationSuccess){
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=> HomeScreen()));
          return;
        }
      },
      builder: (context , state){
        return Scaffold(body: Container(
          child: Center(
            child: SizedBox(
              width: 30,
              height: 30,
              child: CircularProgressIndicator(),
            ),
          ),
        ),);
      },
      cubit: BlocProvider.of<AuthenticationBloc>(context),
    );
  }
}
