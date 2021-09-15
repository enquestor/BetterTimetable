import 'package:bettertimetable/api.dart';
import 'package:bettertimetable/controllers/UserController.dart';
import 'package:get/get.dart';

class CacheController extends GetxController {
  final _departments = Rx<dynamic>(null);
  final _recents = Rx<List<Map<String, dynamic>>>([]);
  final _loaded = false.obs;

  Future<List<Map<String, dynamic>>> getRecents() async {
    return [];
  }

  Future<void> init() async {
    var userController = Get.put(UserController());
    this.departments = await getDepartments(acysem: userController.acysem);
    this.recents = await getRecents();
    this._loaded.value = true;
  }

  set departments(value) => this._departments.value = value;
  get departments => this._departments.value;
  set recents(value) => this._recents.value = value;
  List<Map<String, dynamic>> get recents => this._recents.value;
  bool get loaded => this._loaded.value;
}
