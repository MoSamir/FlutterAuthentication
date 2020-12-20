import 'package:flutter/material.dart';
import 'package:flutter_authentication/src/blocs/bloc/AuthenticationBloc.dart';
import 'package:flutter_authentication/src/blocs/events/AuthenticationStates.dart';
import 'package:flutter_authentication/src/blocs/states/AuthenticationStates.dart';
import 'package:flutter_authentication/src/ui/LoginScreen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class HomeScreen extends StatelessWidget {

  AuthenticationBloc bloc ;


  @override
  Widget build(BuildContext context) {
    bloc = BlocProvider.of<AuthenticationBloc>(context);
    return Scaffold(
      body: BlocConsumer(
        builder: (context, state){
          return ModalProgressHUD(inAsyncCall: state is AuthenticationLoading, child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('You Are logged in '),
                FlatButton(onPressed: (){
                  bloc.add(LogoutUser());
                }, child: Text('Logout')),
              ],
            ),
          ),);
        },
        listener: (context, state){
          if(state is AuthenticationInitialized){
            Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context)=> LoginScreen()), (route) => false);
          }
        },
        cubit: bloc,
      ),
    );
  }
}
