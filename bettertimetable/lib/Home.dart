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
          ],
        ),
        actions: [
          HomeButton(
              text: '使用說明',
              onPressed: () => ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text('快...快做出來了...再等一下罷拖')))),
          HomeButton(
            text: '關於',
            onPressed: () => ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text('快...快做出來了...再等一下罷拖'))),
          )
        ],
        centerTitle: false,
      ),
      body: widget.child,
      floatingActionButton: Visibility(
        visible: Get.currentRoute == '/result',
        child: FloatingActionButton(
          tooltip: '強制重新整理',
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

class HomeButton extends StatelessWidget {
  final String text;
  final Function onPressed;
  const HomeButton({Key? key, required this.text, required this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => onPressed(),
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
        child: Text(
          text,
          style: Theme.of(context).textTheme.button,
        ),
      ),
    );
  }
}
