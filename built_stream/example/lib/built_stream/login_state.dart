import 'package:example/login_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:built_stream/built_stream.dart';
import 'dart:async';
import 'package:customized_streams/customized_streams.dart';

part "login_state.g.dart";

class _Login {
  @Repository('readMultiple')
  LoginRepository repository;

  @Input(optional: true)
  String username;
  @Input(optional: true)
  String password;
  @Input()
  bool onlyPassword;

  @Output(optional: true)
  dynamic userProfile;
  @Output(optional: true)
  Map profile;
}
