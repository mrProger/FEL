import 'dart:io';
import '../lib/fel_system.dart';
import '../lib/config.dart';

void main() async {
  FelSystem felSystem = new FelSystem();
  String fileName = "";
  bool result = false;

  while (true) {
    config.code.clear();
    config.html.clear();
    config.head.clear();
    config.body.clear();

    print('Input path to FEL file: ');
    String? input = stdin.readLineSync();

    if (input?.replaceAll(' ', '') == '')
      print(config.messageMap['null_input']);
    else {
      if (input?.trim() == 'exit' || input?.trim() == 'quit')
        return;

      File file = new File(input.toString());

      if (file.existsSync() && input.toString().toLowerCase().endsWith('.fel')) {
        bool readFelFileResult = await felSystem.readFelFile(input.toString());

        for (int i = 0; i < config.code.length; i++)
          felSystem.compileAllCode(config.code[i]);

        fileName = felSystem.getFileName(input.toString());
        result = await felSystem.createHtmlPage('${input.toString().replaceAll(fileName + '.fel', '')}${fileName}.html');

        if (result)
          print(config.messageMap['compile_success']);
        else
          print(config.messageMap['file_not_found']);
      }
    }
  }
}