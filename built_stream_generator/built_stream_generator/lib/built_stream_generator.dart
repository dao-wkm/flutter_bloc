import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:built_stream_generator/src/generator.dart';

Builder stream(BuilderOptions options) =>
    SharedPartBuilder([BuiltStreamGenerator()], 'built_stream');
