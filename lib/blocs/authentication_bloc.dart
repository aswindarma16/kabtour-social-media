import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../globals.dart';
import '../services/secure_storage_service.dart';
import '../models/user.dart';

// Authentication Event ========================================================= START
class AuthenticationEvent extends Equatable {
  const AuthenticationEvent();

  @override
  List<Object> get props => [];
}

// event to check session in the backgroudn at splash screen
class AppStarted extends AuthenticationEvent {}

class LogIn extends AuthenticationEvent {
  final String userName, password;
  
  const LogIn({
    required this.userName,
    required this.password
  });
}

class LogOut extends AuthenticationEvent {}
// Authentication Event ========================================================= END

// Authentication State ========================================================= START
abstract class AuthenticationState extends Equatable {
  @override
  List<Object> get props => [];
}

class AuthenticationAuthenticated extends AuthenticationState {
  final User userData;

  AuthenticationAuthenticated({
    required this.userData
  });
}

class AuthenticationUnauthenticated extends AuthenticationState {}

class AuthenticationLoading extends AuthenticationState {}

class AuthenticationFailure extends AuthenticationState {
  final String message;

  AuthenticationFailure({
    required this.message
  });
}
// Authentication State ========================================================= END

// Authentication Bloc ========================================================= START
class AuthenticationBloc extends Bloc<AuthenticationEvent, AuthenticationState> {
  AuthenticationBloc(super.initialState) {
    on<AppStarted>(_mapAppStartedToState);
    on<LogIn>(_mapLoginToState);
    on<LogOut>(_mapLogOutToState);
  }

  void _mapAppStartedToState(AppStarted event, Emitter<AuthenticationState> emit) async {
    emit(AuthenticationLoading());

    String? loggedInUser;

    try {
      loggedInUser = await SecureStorageService.getUser();
    } catch (e) {
      // error
    }

    if(loggedInUser == null || loggedInUser == "") {
      emit(AuthenticationUnauthenticated());
    }
    else {
      emit(
        AuthenticationAuthenticated(
          userData: User(
            userName: loggedInUser
          ),
        )
      );
    }
  }

  FutureOr<void> _mapLoginToState(LogIn event, Emitter<AuthenticationState> emit) async {
    emit(AuthenticationLoading());
    try {
      // simulate loading
      await Future.delayed(const Duration(seconds: 2));

      final users = await SecureStorageService.getRegisteredUsers();

      final user = users.firstWhere(
        (u) => u['username'] == event.userName && u['password'] == event.password,
        orElse: () => {},
      );

      if (user.isEmpty) {
        emit(
          AuthenticationFailure(
            message: "Wrong username or password",
          ),
        );
      } else {
        final loggedInUser = User(userName: user["username"]);

        await SecureStorageService.saveUser(loggedInUser.userName);

        emit(
          AuthenticationAuthenticated(
            userData: loggedInUser,
          ),
        );
      }
    } catch (error) {
      emit(
        AuthenticationFailure(
          message: generalErrorMessage,
        ),
      );
    }
  }

  void _mapLogOutToState(LogOut event, Emitter<AuthenticationState> emit) async {
    emit(AuthenticationLoading());
    await SecureStorageService.deleteUser();
    emit(AuthenticationUnauthenticated());
  }
}
// Authentication Bloc ========================================================= END
