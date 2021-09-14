import 'package:bettertimetable/consts.dart';
import 'package:get/get.dart';

class UserController extends GetxController {
  final _acysem = ''.obs;
  final _language = ''.obs;

  UserController() {
    acysem = Consts.availableAcySems.first['value']!;
    language = Consts.availableLanguages.first['value']!;
  }

  set acysem(String value) => this._acysem.value = value;
  String get acysem => this._acysem.value;
  String get acy => this._acysem.substring(0, 3);
  String get sem => this._acysem.substring(3, 4);

  set language(String value) => this._language.value = value;
  String get language => this._language.value;
}
