class Property {
  final String type;
  final String name;

  Property(this.type, this.name);
  @override
  String toString() {
    return '$type $name';
  }
}
