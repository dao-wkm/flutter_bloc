import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/constant/value.dart';
import 'package:source_gen/source_gen.dart';

DartObject getConstantValueFromAnnotation(ElementAnnotation annotation) {
  final value = annotation.computeConstantValue();
  if (value == null) {
    throw InvalidGenerationSourceError(
        'Can’t process annotation “${annotation.toSource()}” in '
        '“${annotation.librarySource.uri}”. Please check for a missing import.');
  }
  return value;
}

String metadataToStringValue(ElementAnnotation annotation) {
  final value = getConstantValueFromAnnotation(annotation);
  return value.toStringValue();
}
