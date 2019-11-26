import 'package:build/build.dart';
import 'package:built_stream_generator/built_stream_generator.dart';
import 'package:source_gen/source_gen.dart';

Builder builtStream(BuilderOptions options) =>
    SharedPartBuilder([BuiltStreamGenerator()], 'built_stream');
