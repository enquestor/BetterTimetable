import 'package:bettertimetable/consts.dart';
import 'package:bettertimetable/controllers/UserController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Home extends StatefulWidget {
  final Widget child;
  const Home({Key? key, required this.child}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  var userController = Get.put(UserController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                child: Row(
                  children: [
                    Icon(Icons.event_available,
                        color: Theme.of(context).brightness == Brightness.light
                            ? Theme.of(context).primaryColor
                            : Colors.white),
                    SizedBox(width: 16),
                    Text(
                      Consts.appName,
                      style: TextStyle(
                          color:
                              Theme.of(context).brightness == Brightness.light
                                  ? Theme.of(context).primaryColor
                                  : Colors.white),
                    ),
                  ],
                ),
                onTap: () => Get.toNamed('/'),
              ),
            ),
            SizedBox(width: 24),
            SizedBox(
              width: 72,
              child: DropdownButtonFormField(
                onChanged: (String? newValue) =>
                    userController.acysem = newValue!,
                value: userController.acysem,
                style: Theme.of(context).textTheme.bodyText1,
                decoration: InputDecoration(enabledBorder: InputBorder.none),
                icon: Icon(Icons.arrow_drop_down, color: Colors.grey.shade600),
                items: Consts.availableAcySems
                    .map((availableAcySem) => DropdownMenuItem(
                          value: availableAcySem['value'],
                          child: Text(
                            availableAcySem['name']!,
                          ),
                        ))
                    .toList(),
              ),
            ),
            // Visibility(
            //   visible: context.vRouter.url != '/',
            //   child: Flexible(
            //     child: Row(
            //       mainAxisAlignment: MainAxisAlignment.start,
            //       mainAxisSize: MainAxisSize.max,
            //       crossAxisAlignment: CrossAxisAlignment.center,
            //       children: [
            //         SizedBox(width: 32),
            //         Flexible(
            //           child: TextField(
            //             decoration: InputDecoration(
            //               enabledBorder: UnderlineInputBorder(
            //                 borderSide: BorderSide(color: Colors.grey.shade400),
            //               ),
            //               focusedBorder: UnderlineInputBorder(
            //                 borderSide: BorderSide(color: Colors.white),
            //               ),
            //               hintText: '搜尋 ...',
            //               hintStyle: TextStyle(color: Colors.grey.shade200),
            //               focusColor: Theme.of(context).cardColor,
            //             ),
            //             cursorColor: Colors.grey.shade200,
            //             style: TextStyle(color: Theme.of(context).cardColor),
            //           ),
            //         ),
            //         IconButton(
            //           onPressed: () => {},
            //           icon: Icon(Icons.search),
            //           splashRadius: 20,
            //         ),
            //       ],
            //     ),
            //   ),
            // ),
            // SizedBox(width: 140),
          ],
        ),
        actions: [
          Visibility(
            visible: Get.currentRoute != '/',
            child: IconButton(
              onPressed: () => Get.toNamed('/'),
              icon: Icon(Icons.search),
              splashRadius: 20,
              color: Theme.of(context).textTheme.subtitle1!.color,
            ),
          ),
          IconButton(
            onPressed: () => Get.toNamed('/'),
            icon: Icon(Icons.info),
            splashRadius: 20,
            color: Theme.of(context).textTheme.subtitle1!.color,
          ),
        ],
        centerTitle: false,
      ),
      body: widget.child,
      floatingActionButton: Visibility(
        visible: Get.currentRoute == '/result',
        child: FloatingActionButton(
          onPressed: () => Get.offAndToNamed('/result', arguments: {
            ...(Get.arguments as Map<String, dynamic>),
            'force': true
          }),
          child: Icon(Icons.refresh),
        ),
      ),
    );
  }
}
