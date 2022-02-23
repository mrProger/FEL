library fel_system;

import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'config.dart';

class FelSystem {
  List<String> mainTagsList = ['html', 'head', 'body'];
  List<String> tagsNoContentList = ['hr', 'img', 'br', 'meta'];

  List<String> parseLineCode(String line) => line.split('->');

  Map<String, String> parseLine(List<String> line) {
    Map<String, String> ret = new Map<String, String>();
    RegExp regExp = RegExp(r"([\w\-]+)\(\'([\w\-\\\/\+\*\.\,\!\|\@\#\№\$\;\$\%\^\:\&\?\_\=\s]+)\'\)");

    line.forEach((elem) {
      String tag;
      String attribute;

      if (mainTagsList.indexOf(elem) == -1 && tagsNoContentList.indexOf(elem) == -1) {
        tag = elem.replaceAllMapped(regExp, (Match match) => '${match[1]}').toString().replaceAll("'", "");
        attribute = elem.replaceAllMapped(regExp, (Match match) => '${match[2] != null ? match[2] : "null"}').toString().replaceAll("'", "");

        ret.addAll({tag: attribute});
      }
      else if (mainTagsList.indexOf(elem) != -1)
        ret.addAll({elem.replaceAllMapped(regExp, (Match match) => match[1].toString()): 'main_tag'});
      else
        ret.addAll({elem.replaceAllMapped(regExp, (Match match) => match[1].toString()): 'null'});
    });

    return ret;
  }

  String? compile(Map<String, String> args) {
    String ret = '';

    if (args['tag'] != '') {
      if (args['tag'] != 'img' && args['tag'] != 'hr' && args['tag'] != 'js' && args['tag'] != 'css' && args['tag'] != 'meta')
        ret = "<${args['tag']} class='${args['class']}' id='${args['id']}' onclick='${args['onclick']}'>${args['value']}</${args['tag']}>";
      else if (args['tag'] == 'img')
        ret = "<${args['tag']} class='${args['class']}' id='${args['id']}' src='${args['src']}' alt='${args['alt']}'>";
      else if (args['tag'] == 'hr')
        ret = "<${args['tag']} class='${args['class']}' id='${args['id']}' width='${args['width']}' height='${args['height']}'>";
      else if (args['tag'] == 'js')
        ret = "<script src='${args['value']}'></script>";
      else if (args['tag'] == 'css')
        ret = "<link rel='stylesheet' href='${args['value']}'>";
      else if (args['tag'] == 'br')
        ret = '<br>';
      else if (args['tag'] == 'meta')
        ret = "<meta http-equiv='${args['http-equiv']}' content='${args['content']}'>";

      if (args['mainTag'] != '') {
        if (args['mainTag'] == 'html')
          config.html.add(ret);

        else if (args['mainTag'] == 'head')
          config.head.add(ret);

        else if (args['mainTag'] == 'body')
          config.body.add(ret);
      }
    }

    return ret;
  }

  Future<bool> readFelFile(String path) async {
    bool status = false;

    try {
      await new File(path)
          .openRead()
          .map(utf8.decode)
          .transform(new LineSplitter())
          .forEach((value) => config.code.add(value))
          .whenComplete(() => status = true);
    }
    catch(exception, message) {
      print('Ошибка! ${exception}\nИнформация: ${message}');
      return false;
    }

    return status;
  }

  bool isTag(String line) {
    bool result = false;
    List<String> operators = ['class', 'id', 'value', 'onclick', 'src', 'alt', 'width', 'height', 'http-equiv', 'content'];

    operators.forEach((operator) => result = operator == line);

    return result;
  }

  bool compileAllCode(String lineCode) {
    Map<String, String> params = new Map<String, String>();
    var subStr = parseLineCode(lineCode);
    List<String> hashMapKeys = ['mainTag', 'tag', 'class', 'id', 'value', 'onclick', 'src', 'alt', 'width', 'height', 'http-equiv', 'content'];
    Map<String, String> result = Map<String, String>();

    try {
      for (int i = 0; i < hashMapKeys.length; i++)
        params.addAll({hashMapKeys[i]: ''});

      result = parseLine(subStr);

      result.forEach((key, value) {
        if (result[key] == 'main_tag' && (key == 'html' || key == 'head' || key == 'body'))
          params['mainTag'] = key;
        else if (hashMapKeys.indexOf(key) == -1) {
          params['tag'] = key;
          params['value'] = result[key].toString();
        }
        else
          params[key] = result[key].toString();
      });

      compile(params);
    }
    catch(exception, message) {
      print('Ошибка! ${exception}\nИнформация: ${message}');
      return false;
    }

    return true;
  }

  String getFileName(String path) {
    RegExp regExp = new RegExp("([\\w]+.fel)");
    var groupCount = path.replaceAllMapped(regExp, (Match match) => '${match.groupCount}');

    String fileName = 'null';

    if (groupCount.length > 0)
      fileName = path.replaceAllMapped(regExp, (Match match) => '${match[1].toString().replaceAll('.fel', '')}');

    return fileName;
  }

  Future<bool> createHtmlPage(String pageName) async {
    String strToWrite = '';

    try {
      if (config.html.length == 0) {
        strToWrite = '<html>\n<head>\n';
        config.head.forEach((tag) => strToWrite += '${tag}\n');
        strToWrite += '</head>\n<body>\n';
        config.body.forEach((tag) => strToWrite += '${tag}\n');
        strToWrite += '</body>\n</html>';
      }
      else {
        strToWrite = '<html>\n';
        config.html.forEach((tag) => strToWrite += '${tag}\n');
        strToWrite += '<head>\n';
        config.head.forEach((tag) => strToWrite += '${tag}\n');
        strToWrite += '</head>\n<body>\n';
        config.body.forEach((tag) => strToWrite += '${tag}\n');
        strToWrite += '</body>\n</html>';
      }

      await File(pageName).writeAsString(strToWrite);
    }
    catch (exception, message) {
      print('Ошибка! ${exception}\nИнформация: ${message}');
      return false;
    }

    return true;
  }
}