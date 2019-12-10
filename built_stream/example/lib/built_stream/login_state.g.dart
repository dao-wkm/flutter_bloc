// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_state.dart';

// **************************************************************************
// BuiltStreamGenerator
// **************************************************************************

class LoginParams {
  final String username;
  final String password;
  final bool onlyPassword;
  const LoginParams(this.username, this.password, this.onlyPassword);
}

class LoginResults {
  final dynamic userProfile;
  final Map<dynamic, dynamic> profile;
  const LoginResults(this.userProfile, this.profile);
}

abstract class LoginState {
  bool get isLoading;
  const LoginState();
}

class LoginStart extends LoginState {
  @override
  bool get isLoading => true;
  const LoginStart();
}

class LoginSucceed extends LoginState {
  @override
  bool get isLoading => false;
  final LoginResults results;
  const LoginSucceed(this.results);
}

class LoginError extends LoginState {
  @override
  bool get isLoading => false;
  final dynamic error;
  const LoginError(this.error);
  @override
  String toString() {
    if (kReleaseMode) return '${super.runtimeType}';
    return '${super.runtimeType}: $error';
  }
}

class LoginStream {
  LoginRepository repository = LoginRepository();
  Stream<LoginState> process(LoginParams params) async* {
    try {
      yield const LoginStart();
      LoginResults results = await repository.readMultiple(params);
      yield LoginSucceed(results);
    } catch (e) {
      yield LoginError(e);
    }
  }
}

class LoginBloc {
  LoginStream _loginStream;
  SwitchSubject loginSubject;
  LoginBloc() {
    _loginStream = LoginStream();
    loginSubject = SwitchSubject<LoginParams, LoginState>(_loginStream.process);
  }
  dispose() => loginSubject.dispose();
}
