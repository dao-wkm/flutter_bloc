// const String input = 'input';
// const String output = 'output';

class Repository {
  final String action;
  final bool withDefaultBloc;
  const Repository(this.action, {this.withDefaultBloc = true});
}

class Input {
  final bool optional;
  const Input({this.optional = false});
}

class Output {
  final bool optional;
  const Output({this.optional = false});
}
