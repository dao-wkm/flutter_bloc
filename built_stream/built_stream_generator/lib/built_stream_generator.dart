import 'dart:async';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/src/builder/build_step.dart';
import 'package:source_gen/source_gen.dart';
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

        List<_Property> inputs = [];
        List<_Property> optionalInputs = [];
        List<_Property> outputs = [];
        List<_Property> optionalOutputs = [];
        _Property repository;
        String action;
        bool withDefaultBloc;
        collectFields(element).forEach((FieldElement fieldElement) {
          // bool isRepository = false;
          fieldElement.metadata
              .map((annotation) => annotation.computeConstantValue())
              .forEach((value) {
            if (value?.type?.displayName == 'Repository') {
              dynamic actionField = value?.getField('action');
              if (actionField != null) {
                action = actionField.toStringValue();
              }
              dynamic withDefaultBlocField = value?.getField('withDefaultBloc');
              if (withDefaultBlocField != null) {
                withDefaultBloc = withDefaultBlocField.toBoolValue();
              }
              // isRepository = true;
              repository =
                  _Property(fieldElement.type.toString(), fieldElement.name);
            }

            if (value?.type?.displayName == 'Input') {
              dynamic optionalField = value?.getField('optional');
              bool optional;
              if (optionalField != null) {
                optional = optionalField.toBoolValue();
              }
              if (optional) {
                optionalInputs.add(
                    _Property(fieldElement.type.toString(), fieldElement.name));
              } else {
                inputs.add(
                    _Property(fieldElement.type.toString(), fieldElement.name));
              }
            }

            if (value?.type?.displayName == 'Output') {
              dynamic optionalField = value?.getField('optional');
              bool optional;
              if (optionalField != null) {
                optional = optionalField.toBoolValue();
              }
              if (optional) {
                optionalOutputs.add(
                    _Property(fieldElement.type.toString(), fieldElement.name));
              } else {
                outputs.add(
                    _Property(fieldElement.type.toString(), fieldElement.name));
              }
            }
          });

          // if (isRepository) {
          //   repository =
          //       _Property(fieldElement.type.toString(), fieldElement.name);
          // }

          // bool isOutput = fieldElement.metadata.any(
          //     (ElementAnnotation elementAnnotation) =>
          //         metadataToStringValue(elementAnnotation) == 'output');

          // if (isOutput) {
          //   outputs.add(
          //       _Property(fieldElement.type.toString(), fieldElement.name));
          // }

          // bool isInput = fieldElement.metadata.any(
          //     (ElementAnnotation elementAnnotation) =>
          //         metadataToStringValue(elementAnnotation) == 'input');

          // if (isInput) {
          //   inputs.add(
          //       _Property(fieldElement.type.toString(), fieldElement.name));
          // }
        });

        result.writeln('class ${className}Params {');
        inputs.forEach((_Property property) {
          result.writeln('final $property;');
        });
        optionalInputs.forEach((_Property property) {
          result.writeln('final $property;');
        });
        String inputParams =
            inputs.map((property) => 'this.' + property.name).join(', ');
        String optionalInputParams = '';
        if (optionalInputs.length > 0) {
          optionalInputParams += inputParams.length > 0 ? ', ' : '';
          optionalInputParams +=
              '{${optionalInputs.map((property) => 'this.' + property.name).join(', ')}}';
        }
        result.writeln(
            ' const ${className}Params($inputParams$optionalInputParams);');
        result.writeln('}');

        result.writeln('class ${className}Results {');
        outputs.forEach((_Property property) {
          result.writeln('final $property;');
        });
        optionalOutputs.forEach((_Property property) {
          result.writeln('final $property;');
        });
        String outputParams =
            outputs.map((property) => 'this.' + property.name).join(', ');
        String optionalOutputParams = '';
        if (optionalOutputs.length > 0) {
          optionalOutputParams += outputParams.length > 0 ? ', ' : '';
          optionalOutputParams +=
              '{${optionalOutputs.map((property) => 'this.' + property.name).join(', ')}}';
        }
        result.writeln(
            ' const ${className}Results($outputParams$optionalOutputParams);');
        result.writeln('}');

        result.writeln('abstract class ${className}State {'
            ' bool get isLoading;'
            ' const ${className}State();'
            '}');

        result.writeln('class ${className}Start extends ${className}State {'
            ' @override'
            ' bool get isLoading => true;'
            ' const ${className}Start();'
            '}');

        result.writeln('class ${className}Succeed extends ${className}State {'
            ' @override'
            ' bool get isLoading => false;'
            ' final ${className}Results results;'
            ' const ${className}Succeed(this.results);'
            '}');

        result.writeln('class ${className}Error extends ${className}State {'
            ' @override'
            ' bool get isLoading => false;'
            ' final ${className}Params params;'
            ' final dynamic error;'
            ' const ${className}Error(this.error, this.params);'
            ' @override'
            ' String toString() {'
            '   if (kReleaseMode) return \'\${super.runtimeType}\';'
            '   return \'\${super.runtimeType}: \$error\';'
            ' }'
            '}');

        result.writeln('class ${className}Stream {'
            ' ${repository} = ${repository.type}();'
            ' Stream<${className}State> process(${className}Params params) async* {'
            '   try {'
            '     yield const ${className}Start();'
            '     ${className}Results results = await ${repository.name}.$action(params);'
            '     yield ${className}Succeed(results);'
            '   } catch (e) {'
            '     yield ${className}Error(e, params);'
            '   }'
            ' }'
            '}');

        if (withDefaultBloc) {
          result.writeln('class ${className}Bloc {'
              ' ${className}Stream _${_lowerFirst(className)}Stream;'
              ' SwitchSubject<${className}Params, ${className}State> ${_lowerFirst(className)}Subject;'
              ' ${className}Bloc() {'
              '   _${_lowerFirst(className)}Stream = ${className}Stream();'
              '   ${_lowerFirst(className)}Subject = SwitchSubject<${className}Params, ${className}State>(_${_lowerFirst(className)}Stream.process);'
              ' }'
              ' dispose() => ${_lowerFirst(className)}Subject.dispose();'
              '}');
        }
      }
    }
    return result.toString();
  }
}

class _Property {
  final String type;
  final String name;

  _Property(this.type, this.name);
  @override
  String toString() {
    return '$type $name';
  }
}

String _lowerFirst(String word) =>
    '${word[0].toLowerCase()}${word.substring(1)}';
