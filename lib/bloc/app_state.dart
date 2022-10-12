import 'package:flutter/foundation.dart' show immutable;
import 'package:notes_bloc/model.dart';

@immutable
class AppState{
  final bool isLoading;
  final LoginErrors? loginError;
  final LoginHandle? loginHandle;
  final Iterable<Note>? fetchedNotes;

  const AppState.empty()
      : isLoading = false,
        loginError = null,
        loginHandle = null,
        fetchedNotes = null;

  AppState({
      required this.isLoading,
      required this.loginError,
      required this.loginHandle,
      required this.fetchedNotes,
  });

  @override
  String toString() => {
    'isLoading' : isLoading,
    'loginError' : loginError,
    'loginHandle' : loginHandle,
    'fetchedNotes' : fetchedNotes,

  }.toString();
}

