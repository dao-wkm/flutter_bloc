import 'dart:async';
import 'package:example/built_stream/login_state.dart';

class LoginRepository {
  Future<LoginResults> readMultiple(LoginParams params) =>
      Future.value(LoginResults(profile: Map(), userProfile: "fadf"));
}
