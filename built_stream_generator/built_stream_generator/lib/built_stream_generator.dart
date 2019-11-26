import 'dart:async';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/src/builder/build_step.dart';
import 'package:source_gen/source_gen.dart';
import 'package:built_stream/built_stream.dart';
import 'package:built_stream_generator/src/fields.dart';
import 'package:built_stream_generator/src/metadata.dart';

class BuiltStreamGenerator extends Generator {
  String _getClassName(String displayName) =>
      displayName.substring(1, displayName.length);
  @override
  FutureOr<String> generate(LibraryReader library, BuildStep buildStep) async {
    var result = StringBuffer();
    for (var element in library.allElements) {
      if (element is ClassElement) {
        String className = _getClassName(element.displayName);

        List<Property> inputs = [];
        List<Property> outputs = [];
        Property repository;
        String action;
        collectFields(element).forEach((FieldElement fieldElement) {
          bool isRepository = fieldElement.metadata
              .map((annotation) => annotation.computeConstantValue())
              .any((value) {
            dynamic field = value?.getField('action');
            if (field != null) {
              action = field.toStringValue();
            }
            return value?.type?.displayName == 'Repository';
          });

          if (isRepository) {
            repository =
                Property(fieldElement.type.toString(), fieldElement.name);
          }

          bool isOutput = fieldElement.metadata.any(
              (ElementAnnotation elementAnnotation) =>
                  metadataToStringValue(elementAnnotation) == 'output');

          if (isOutput) {
            outputs
                .add(Property(fieldElement.type.toString(), fieldElement.name));
          }

          bool isInput = fieldElement.metadata.any(
              (ElementAnnotation elementAnnotation) =>
                  metadataToStringValue(elementAnnotation) == 'input');

          if (isInput) {
            inputs
                .add(Property(fieldElement.type.toString(), fieldElement.name));
          }
        });

        result.writeln('class ${className}Params {');
        inputs.forEach((Property property) {
          result.writeln('final $property;');
        });
        result.writeln(
            ' const ${className}Params(${inputs.map((property) => 'this.' + property.name).join(', ')});');
        result.writeln('}');

        result.writeln('class ${className}Results {');
        outputs.forEach((Property property) {
          result.writeln('final $property;');
        });
        result.writeln(
            ' const ${className}Results(${outputs.map((property) => 'this.' + property.name).join(', ')});');
        result.writeln('}');

        result.writeln('class ${className}State {'
            ' const ${className}State();'
            '}');

        result.writeln('class ${className}Start extends ${className}State {'
            ' const ${className}Start();'
            '}');

        result.writeln('class ${className}Succeed extends ${className}State {'
            ' final ${className}Results results;'
            ' const ${className}Succeed(this.results);'
            '}');

        result.writeln('class ${className}Error extends ${className}State {'
            ' final dynamic error;'
            ' const ${className}Error(this.error);'
            ' @override'
            ' String toString() {'
            '   if (kReleaseMode) return \'\${super.runtimeType}\';'
            '   return \'\${super.runtimeType}: \$error\';'
            ' }'
            '}');

        result.writeln('class ${className}BuiltStream {'
            ' ${repository} = ${repository.type}();'
            ' Stream<${className}State> process(${className}Params params) async* {'
            '   try {'
            '     yield const ${className}Start();'
            '     ${className}Results results = await ${repository.name}.$action(params);'
            '     yield ${className}Succeed(results);'
            '   } catch (e) {'
            '     yield ${className}Error(e);'
            '   }'
            ' }'
            '}');
      }
    }

    return result.toString();
  }
}
