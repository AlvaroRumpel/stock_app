#!/usr/bin/env dart

import 'dart:convert';
import 'dart:io';

void main(List<String> args) async {
  final flavor = args.isEmpty ? 'production' : args.first;

  if (flavor != 'dev' && flavor != 'production') {
    _print('Flavor inválido: "$flavor". Use "dev" ou "production".');
    exit(1);
  }

  final definesFile = File('dart_defines/$flavor.json');
  if (!definesFile.existsSync()) {
    _print('Arquivo não encontrado: ${definesFile.path}');
    exit(1);
  }

  final json = jsonDecode(definesFile.readAsStringSync()) as Map<String, dynamic>;
  final dartDefines = json.entries
      .map((e) => '--dart-define=${e.key}=${e.value}')
      .toList();

  final buildMode = flavor == 'production' ? 'release' : 'debug';

  final command = [
    'flutter',
    'build',
    'apk',
    '--flavor=$flavor',
    '--$buildMode',
    ...dartDefines,
  ];

  _print('Gerando APK — flavor: $flavor | modo: $buildMode');
  _print('Comando: ${command.join(' ')}\n');

  final isWindows = Platform.isWindows;
  final process = await Process.start(
    isWindows ? 'cmd' : command.first,
    isWindows ? ['/c', ...command] : command.sublist(1),
    mode: ProcessStartMode.inheritStdio,
  );

  final exitCode = await process.exitCode;
  if (exitCode == 0) {
    _print('\nAPK gerada com sucesso!');
    _print('build/app/outputs/flutter-apk/app-$flavor-$buildMode.apk');
  } else {
    _print('\nFalha ao gerar APK (exit code: $exitCode)');
    exit(exitCode);
  }
}

void _print(String msg) => stdout.writeln('[build_apk] $msg');
