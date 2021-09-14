import 'package:bettertimetable/NotFound.dart';
import 'package:bettertimetable/pages/Result.dart';
import 'package:bettertimetable/pages/Search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bettertimetable/Home.dart';
import 'package:bettertimetable/consts.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
        title: Consts.appName,
        theme: ThemeData(
          primarySwatch: Colors.teal,
          appBarTheme: AppBarTheme(backgroundColor: Colors.white),
          scaffoldBackgroundColor: Colors.white,
          cardTheme: CardTheme(
            elevation: 4.0,
            clipBehavior: Clip.antiAliasWithSaveLayer,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
          ),
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.teal,
          appBarTheme: AppBarTheme(backgroundColor: Color(0xff303030)),
          cardTheme: CardTheme(
            elevation: 4.0,
            clipBehavior: Clip.antiAliasWithSaveLayer,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
          ),
        ),
        themeMode: ThemeMode.system,
        initialRoute: '/',
        unknownRoute: GetPage(name: '/404', page: () => NotFound()),
        getPages: [
          GetPage(name: '/', page: () => Home(child: Search())),
          GetPage(name: '/result', page: () => Home(child: Result()))
        ]);
  }
}
