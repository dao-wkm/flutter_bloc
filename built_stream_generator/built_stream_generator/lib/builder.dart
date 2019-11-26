import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:built_stream_generator/src/stream_generator.dart';

Builder stream(BuilderOptions options) =>
    SharedPartBuilder([BuiltStreamGenerator()], 'stream_generator');
