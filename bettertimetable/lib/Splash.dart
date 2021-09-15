import 'package:bettertimetable/consts.dart';
import 'package:flutter/material.dart';

class Splash extends StatelessWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Container(
          height: double.infinity,
          width: double.infinity,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.event_available,
                  color: Theme.of(context).brightness == Brightness.light
                      ? Theme.of(context).colorScheme.primary
                      : Colors.white,
                  size: 120.0,
                ),
                SizedBox(height: 32.0),
                Text(
                  Consts.appName,
                  style: Theme.of(context).textTheme.headline4!.copyWith(
                        color: Theme.of(context).brightness == Brightness.light
                            ? Theme.of(context).colorScheme.primary
                            : Colors.white,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
