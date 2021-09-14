import 'dart:convert';

import 'package:bettertimetable/consts.dart';
import 'package:http/http.dart' as http;

Future<dynamic> getDepartments({required String acysem}) async {
  try {
    var response = await http.post(
        Uri.parse(Consts.apiEndpoint + 'departments'),
        body: jsonEncode({'acysem': '1101'}),
        headers: {'Content-Type': 'application/json'});
    return jsonDecode(response.body);
  } catch (error) {
    print(error);
  }
}

Future<dynamic> getCourses(
    {required String acysem,
    required String type,
    required String query,
    required bool force}) async {
  try {
    var response = await http.post(Uri.parse(Consts.apiEndpoint + 'query'),
        body: jsonEncode(
            {'acysem': acysem, 'type': type, 'query': query, 'force': force}),
        headers: {'Content-Type': 'application/json'});
    return jsonDecode(response.body);
  } catch (error) {
    print(error);
  }
}
