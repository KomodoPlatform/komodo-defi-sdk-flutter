import 'dart:io';
import 'package:path/path.dart' as path;

void main(List<String> arguments) {
  if (arguments.isEmpty) {
    print('Please provide the directory path as an argument.');
    exit(1);
  }

  final directory = Directory(arguments.first);
  if (!directory.existsSync()) {
    print('The provided directory does not exist.');
    exit(1);
  }

  final requestClasses = <String, Map<String, dynamic>>{};

  // Traverse the directory and collect all Dart files
  directory.listSync(recursive: true).forEach((file) {
    if (file is File && file.path.endsWith('.dart')) {
      final content = file.readAsStringSync();

      // Regex to match classes that extend BaseRequest
      final classRegex =
          RegExp(r'class\s+(\w+Request)\s+extends\s+BaseRequest');
      final constructorRegex = RegExp(r'(\w+Request)\(([^)]*)\)');

      for (final classMatch in classRegex.allMatches(content)) {
        final className = classMatch.group(1)!;

        final constructorMatch = constructorRegex.firstMatch(content);
        if (constructorMatch != null) {
          final constructorParameters = constructorMatch.group(2)!;
          final methodMatch =
              RegExp(r"method:\s*'([^']*)'").firstMatch(content);

          if (methodMatch != null) {
            final method = methodMatch.group(1)!;
            final methodSegments = method.split('::');

            // Store the class info in the requestClasses map
            Map<String, dynamic> current = requestClasses;

            for (final segment in methodSegments) {
              current = (current.putIfAbsent(
                segment,
                () => {'classes': {}, 'children': {}},
              )['children'] as Map)
                  .cast<String, dynamic>();
            }

            current['classes'] ??= <String, dynamic>{};

            // Store the request class details in the leaf node
            current['classes'][className] = {
              'constructorParameters': constructorParameters,
              'className': className,
            };
          }
        }
      }
    }
  });

  // Check if we found any request classes
  if (requestClasses.isEmpty) {
    print('No request classes were found.');
    exit(1);
  }

  // Generate the index class with nested classes and methods
  final buffer = StringBuffer();
  buffer.writeln('// Auto-generated RPC methods index');
  buffer.writeln('// ignore_for_file: unused_field, unused_element');
  buffer.writeln();
  buffer.writeln(
    "import 'package:komodo_defi_rpc_methods/komodo_defi_rpc_methods.dart';",
  );
  buffer.writeln();
  buffer.writeln('abstract class RpcMethods {');

  void generateNestedClasses(
    Map<String, dynamic> currentMap,
    String indent,
    bool isRoot,
  ) {
    currentMap.forEach((segment, data) {
      final children = (data['children'] as Map? ?? {}).cast<String, dynamic>();
      final classes = (data['classes'] as Map? ?? {}).cast<String, dynamic>();

      final className = '_${segment.pascalCase}Methods';
      if (isRoot) {
        buffer.writeln('$indent// ignore: library_private_types_in_public_api');
        buffer.writeln(
          '${indent}static const $className ${segment.camelCase} = $className();',
        );
      } else {
        buffer.writeln('${indent}class $className {');
        buffer.writeln('$indent  const $className();');
        buffer.writeln();
      }

      classes.forEach((requestClassName, info) {
        final constructorParams = info['constructorParameters'] as String;
        final formattedParams = formatParameters(constructorParams);
        final positionalParams = extractPositionalParams(constructorParams);

        buffer.writeln(
          '$indent  $requestClassName ${requestClassName.camelCase}({$formattedParams}) =>',
        );
        buffer.writeln('$indent      $requestClassName($positionalParams);');
        buffer.writeln();
      });

      if (children.isNotEmpty) {
        generateNestedClasses(children, '$indent  ', false);
      }

      if (!isRoot) {
        buffer.writeln('$indent}');
        buffer.writeln();
      }
    });
  }

  generateNestedClasses(requestClasses, '  ', true);

  buffer.writeln('}');

  final outputPath = path.join(directory.path, 'rpc_methods_index.dart');
  File(outputPath).writeAsStringSync(buffer.toString());

  print('RPC methods index generated at $outputPath');
}

String formatParameters(String params) {
  return params
      .split(',')
      .map((p) => p.trim())
      .where((p) => p.isNotEmpty)
      .map((p) => p.startsWith('required') ? p : 'required $p')
      .join(', ');
}

String extractPositionalParams(String params) {
  return params
      .split(',')
      .map((p) => p.trim())
      .where((p) => p.isNotEmpty)
      .map((p) => p.split(' ').last)
      .join(', ');
}

extension StringExtension on String {
  String get camelCase {
    return this[0].toLowerCase() + substring(1);
  }

  String get pascalCase {
    return this[0].toUpperCase() + substring(1);
  }
}
