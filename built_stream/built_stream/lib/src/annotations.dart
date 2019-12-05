const String input = 'input';
const String output = 'output';

class Repository {
  final String action;
  final bool withDefaultBloc;
  const Repository(this.action, {this.withDefaultBloc = true});
}
