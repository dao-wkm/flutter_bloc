import 'package:example/login_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:built_stream/built_stream.dart';
import 'dart:async';
import 'package:customized_streams/customized_streams.dart';

part "login_state.g.dart";

class _Login {
  @Repository('readMultiple')
  LoginRepository repository;

  @input
  String username;
  @input
  String password;
  @input
  bool onlyPassword;

  @output
  dynamic userProfile;
  @output
  Map profile;
}
