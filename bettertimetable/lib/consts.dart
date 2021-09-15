class Consts {
  static String appName = 'Better Timetable';
  static const List<Map<String, String>> availableSearchTargets = [
    {'name': '系所/分類', 'value': 'department'},
    {'name': '教師', 'value': 'teacher'},
    {'name': '課名', 'value': 'name'},
    {'name': '課號', 'value': 'id'},
    {'name': '永久課號', 'value': 'pid'}
  ];

  static const List<Map<String, String>> availableAcySems = [
    {'name': '110 上', 'value': '1101'},
  ];

  static const List<Map<String, String>> availableLanguages = [
    {'name': '中文', 'value': 'zh-tw'}
  ];

  static const int recommendationCount = 5;

  static const String apiEndpoint = 'http://localhost:8888/api/';

  static const double borderRadius = 16.0;
}
