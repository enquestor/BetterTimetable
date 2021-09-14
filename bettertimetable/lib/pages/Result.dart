import 'package:bettertimetable/api.dart';
import 'package:bettertimetable/controllers/UserController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class Result extends StatefulWidget {
  const Result({Key? key}) : super(key: key);

  @override
  State<Result> createState() => _ResultState();
}

class _ResultState extends State<Result> {
  var userController = UserController();
  String type = '', query = '';
  bool force = false;

  @override
  void initState() {
    super.initState();
    userController = Get.put(UserController());
    if (Get.arguments != null) {
      type = Get.arguments['type'];
      query = Get.arguments['query'];
      force = Get.arguments['force'];
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getCourses(
          acysem: userController.acysem,
          type: type,
          query: query,
          force: force),
      builder: (context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData) {
          final List? courses = snapshot.data['data'];
          if (courses == null) {
            Future.delayed(Duration(seconds: 2)).then((_) => Get.toNamed('/'));
            return Center(child: Text('No data, redirecting...'));
          } else {
            print(courses);
            return SingleChildScrollView(
              child: Center(
                child: Container(
                  padding: EdgeInsets.all(12.0),
                  constraints: BoxConstraints(maxWidth: 800),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: courses.length,
                    itemBuilder: (context, index) => CourseCard(
                      course: courses[index],
                    ),
                    separatorBuilder: (context, index) =>
                        SizedBox(height: 12.0),
                  ),
                ),
              ),
            );
          }
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}

class CourseCard extends StatelessWidget {
  final Map<String, dynamic> course;
  const CourseCard({Key? key, required this.course}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userController = Get.put(UserController());
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Obx(
                  () => Text(
                    course['name'][userController.language],
                    style: Theme.of(context)
                        .textTheme
                        .headline5!
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(width: 12.0),
                Expanded(
                  child: Text(
                    course['teacher'],
                    style: Theme.of(context)
                        .textTheme
                        .headline6!
                        .copyWith(fontSize: 18.0),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 12.0),
                TypeIndicator(type: course['type']),
              ],
            ),
            SizedBox(height: 12.0),
            Text(
              course['time'],
              style:
                  Theme.of(context).textTheme.caption!.copyWith(fontSize: 16.0),
            ),
            Visibility(
              visible: course['memo'] != '',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 24.0),
                  Text(course['memo'],
                      style: Theme.of(context).textTheme.subtitle1),
                ],
              ),
            ),
            SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {},
                  child: Text('詳細資訊'),
                ),
                Spacer(),
                Visibility(
                  visible: (course['teacherLink'] as String).isNotEmpty,
                  child: IconButton(
                    onPressed: () => launch(course['teacherLink']),
                    icon: Icon(Icons.account_circle_outlined),
                    splashRadius: 20.0,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                IconButton(
                  onPressed: () => launch(
                      'https://timetable.nycu.edu.tw/?r=main/crsoutline&Acy=${userController.acy}&Sem=${userController.sem}&CrsNo=${course['id']}&lang=${userController.language}'),
                  icon: Icon(Icons.info_outline),
                  splashRadius: 20.0,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class TypeIndicator extends StatelessWidget {
  final String type;
  const TypeIndicator({Key? key, required this.type}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).textTheme.bodyText1!.color;
    return Container(
      decoration: BoxDecoration(
          border: Border.all(width: 2.0, color: color!),
          borderRadius: BorderRadius.all(Radius.circular(4.0))),
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: Text(
          type,
          style: Theme.of(context).textTheme.headline6!.copyWith(
                fontSize: 16.0,
                color: color,
              ),
        ),
      ),
    );
  }
}
