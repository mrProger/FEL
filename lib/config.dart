library config;

class config {
  static List<String> html = [];
  static List<String> head = [];
  static List<String> body = [];

  static List<String> code = [];

  static Map<String, String> messageMap = {
    'null_input': 'Error: Empty line\n',
    'file_not_found': 'Error: File not found\n',
    'compile_success': 'Compilation successful!\n'
  };
}