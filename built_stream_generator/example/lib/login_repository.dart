import 'package:example/build/login_state.dart';

class LoginRepository {
  Future<LoginResults> readMultiple(LoginParams params) =>
      Future.value(LoginResults("", Map()));
}
