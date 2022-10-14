import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc/bloc.dart';
import 'package:notes_bloc/apis/login_api.dart';
import 'package:notes_bloc/apis/notes_api.dart';
import 'package:notes_bloc/bloc/actions.dart';
import 'package:notes_bloc/bloc/app_bloc.dart';
import 'package:notes_bloc/dialogs/generic_dialog.dart';
import 'package:notes_bloc/dialogs/loading_screen.dart';
import 'package:notes_bloc/model.dart';
import 'package:notes_bloc/strings.dart';
import 'package:notes_bloc/views/iterable_list_view.dart';
import 'package:notes_bloc/views/login_view.dart';

import 'bloc/app_state.dart';

void main() {
  runApp(
    MaterialApp(
      title: "Demo",
      theme: ThemeData(
          primarySwatch: Colors.blue
      ),
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context){
    return BlocProvider(
      create: (context) => AppBloc(
        loginApi: LoginApi(),
        notesApi: NotesApi(), 
        acceptedLoginHandle:const LoginHandle.fooBar(),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(homePage),
        ),
        body: BlocConsumer<AppBloc,AppState>(
            listener: (context, appState){
              //loading screen
              if(appState.isLoading){
                LoadingScreen.instance().show(
                  context: context,
                  text: pleaseWait,
                );
              }else{
                LoadingScreen.instance().hide();
              }
              //display possible errors
              final loginError =appState.loginError;
              if(loginError != null){
                showGenericDialog<bool>(
                  context: context,
                  title: loginErrorDialogTitle,
                  content: loginErrorDialogContent,
                  optionsBuilder: () => {ok: true},

                );
              }
              if (appState.isLoading == false &&
                  appState.loginError == null &&
                  appState.loginHandle == const LoginHandle.fooBar() &&
                  appState.fetchedNotes == null) {
                context.read<AppBloc>().add(const LoadNotesAction(),
                );
              }

              //if we are logged in, but we have no fetched notes, fetch them now
            },
            builder: (context,appState){
              final notes = appState.fetchedNotes;
              if(notes == null){
                return LoginView(
                  onLoginTapped: (email,password){
                    context.read<AppBloc>().add(LoginAction(email: email,password: password));
                  },
                );
              } else{
                return notes.toListView();
              }
            }),
      ),
    );
  }
}
