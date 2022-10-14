import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/foundation.dart';
import 'package:notes_bloc/apis/login_api.dart';
import 'package:notes_bloc/apis/notes_api.dart';
import 'package:notes_bloc/bloc/actions.dart';
import 'package:notes_bloc/bloc/app_bloc.dart';
import 'package:notes_bloc/bloc/app_state.dart';
import 'package:notes_bloc/dialogs/generic_dialog.dart';
import 'package:notes_bloc/dialogs/loading_screen.dart';
import 'package:notes_bloc/model.dart';
import 'package:notes_bloc/strings.dart';
import 'package:notes_bloc/views/iterable_list_view.dart';
import 'package:notes_bloc/views/login_view.dart';
import 'package:bloc_test/bloc_test.dart';

const Iterable<Note> mockNotes = [
  Note(title: 'Note 1'),
  Note(title: 'Note 2'),
  Note(title: 'Note 3'),
];

@immutable
class DummyNotesApi implements NotesApiProtocol{
  final LoginHandle acceptedLoginHandle;
  final Iterable<Note>? notesToReturnForAcceptedLoginHandle;


  const DummyNotesApi({
    required this.acceptedLoginHandle,
    required this.notesToReturnForAcceptedLoginHandle
  });

  const DummyNotesApi.empty()
  : acceptedLoginHandle = const LoginHandle.fooBar(),
        notesToReturnForAcceptedLoginHandle = null;

  @override
  Future<Iterable<Note>?> getNotes({required LoginHandle loginHandle,
  })async {
    if(loginHandle == acceptedLoginHandle){
      return notesToReturnForAcceptedLoginHandle;
    }else{
      return null;
    }
  }
}
@immutable
class DummyLoginApi implements LoginApiProtocol{
  final String acceptedEmail;
  final String acceptedPassword;
  final LoginHandle handleToReturn;

  DummyLoginApi({
    required this.handleToReturn,
    required this.acceptedEmail,
    required this.acceptedPassword,
  });
  const DummyLoginApi.empty() :
        acceptedEmail = '',
        acceptedPassword = '',
        handleToReturn = const  LoginHandle.fooBar();

  @override
  Future<LoginHandle?> login({
    required String email,
    required String password
  }) async {
    if(email == acceptedEmail &&
    password == acceptedPassword){
      return handleToReturn;
    }else{
      return null;
    }
  }
}

const acceptedLoginHandle = LoginHandle(token: 'ABC');
void main(){
  blocTest<AppBloc, AppState>('Initial state of the bloc should be AppState.empty',
      build: () => AppBloc(
          loginApi: const DummyLoginApi.empty(),
          notesApi: const DummyNotesApi.empty(),
        acceptedLoginHandle: acceptedLoginHandle,
      ),
    verify: (appState) => expect(appState.state, const AppState.empty(),)
  );
  blocTest<AppBloc, AppState>('Can we login with correct credentials?',
      build: () => AppBloc(
        loginApi:   DummyLoginApi(
            acceptedEmail: 'bar@baz.com',
            acceptedPassword:'foo',
            handleToReturn: acceptedLoginHandle),
        notesApi: const DummyNotesApi.empty(),
        acceptedLoginHandle: acceptedLoginHandle,
      ),
    act: (appBloc) => appBloc.add(
      const LoginAction(email: 'bar@baz.com', password: 'foo')
    ),
    expect: () => [
       AppState(
        isLoading: true,
        loginError: null,
        loginHandle: null,
        fetchedNotes: null
    ),
      AppState(
        isLoading: false,
        loginError: null,
        loginHandle: acceptedLoginHandle,
        fetchedNotes: null,
      ),
    ],
  );
  blocTest<AppBloc, AppState>('We should not be able to log in with invalid credentials',
    build: () => AppBloc(
      loginApi:   DummyLoginApi(
          acceptedEmail: 'foo@bar.com',
          acceptedPassword:'bar',
          handleToReturn: acceptedLoginHandle),
      notesApi: const DummyNotesApi.empty(),
      acceptedLoginHandle: acceptedLoginHandle
    ),
    act: (appBloc) => appBloc.add(
        const LoginAction(email: 'bar@baz.com', password: 'foo')
    ),
    expect: () => [
      AppState(
          isLoading: true,
          loginError: null,
          loginHandle: null,
          fetchedNotes: null
      ),
      AppState(
        isLoading: false,
        loginError: LoginErrors.invalidHandle,
        loginHandle: null,
        fetchedNotes: null,
      ),
    ],
  );

  blocTest<AppBloc, AppState>('Load some notes with a valid login handle',
    build: () => AppBloc(
      loginApi:   DummyLoginApi(
          acceptedEmail: 'foo@bar.com',
          acceptedPassword:'bar',
          handleToReturn: acceptedLoginHandle),
      notesApi:  const DummyNotesApi(acceptedLoginHandle: acceptedLoginHandle,
      notesToReturnForAcceptedLoginHandle: mockNotes,
      ),
      acceptedLoginHandle: acceptedLoginHandle,
    ),
    act: (appBloc) {
      appBloc.add(
          const LoginAction(
              email: 'foo@bar.com',
              password: 'bar',
          ),
      );
      appBloc.add(
        const LoadNotesAction(
        ),
      );
    },
    expect: () => [
      AppState(
          isLoading: true,
          loginError: null,
          loginHandle: null,
          fetchedNotes: null
      ),
      AppState(
        isLoading: false,
        loginError: null,
        loginHandle: acceptedLoginHandle,
        fetchedNotes: null,
      ),
      AppState(
        isLoading: true,
        loginError: null,
        loginHandle: acceptedLoginHandle,
        fetchedNotes: null,
      ),
      AppState(
        isLoading: false,
        loginError: null,
        loginHandle: acceptedLoginHandle,
        fetchedNotes: mockNotes,
      ),
    ],
  );


}