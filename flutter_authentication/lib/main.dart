import 'package:flutter/material.dart';
import 'package:flutter_authentication/src/blocs/bloc/AuthenticationBloc.dart';
import 'package:flutter_authentication/src/blocs/states/AuthenticationStates.dart';
import 'package:flutter_authentication/src/ui/LoginScreen.dart';
import 'package:flutter_authentication/src/ui/SplashScreen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';


AuthenticationBloc authenticationBloc = AuthenticationBloc(AuthenticationLoading());

void main() async{

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(AppEntry());
}

class AppEntry extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: authenticationBloc,
      child: MaterialApp(
        title: 'Authentication Demo',
        home: SplashScreen(),
      ),
    );
  }
}

