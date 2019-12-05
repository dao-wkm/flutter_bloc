import 'dart:collection';

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:built_collection/built_collection.dart';

BuiltList<FieldElement> collectFields(ClassElement element) =>
    collectFieldsForType(element.type);

BuiltList<FieldElement> collectFieldsForType(InterfaceType type) {
  var fields = <FieldElement>[];
  fields.addAll(_fieldElementsForType(type));

  Set<InterfaceType>.from(type.interfaces)
    ..addAll(type.mixins)
    ..forEach((interface) => fields.addAll(collectFieldsForType(interface)));

  var fieldSet = LinkedHashSet<FieldElement>(
      equals: (a, b) => a.displayName == b.displayName,
      hashCode: (a) => a.displayName.hashCode);
  fieldSet.addAll(fields);

  return BuiltList<FieldElement>.build((b) => b
    ..addAll(fieldSet)
    ..where((field) =>
        type.lookUpInheritedGetter(field.name, thisType: false)?.isAbstract ??
        true));
}

BuiltList<FieldElement> _fieldElementsForType(InterfaceType type) {
  var result = ListBuilder<FieldElement>();
  for (var accessor in type.accessors) {
    if (accessor.isSetter) continue;
    result.add(accessor.variable as FieldElement);
  }
  return result.build();
}
