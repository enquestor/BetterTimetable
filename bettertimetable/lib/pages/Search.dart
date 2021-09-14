import 'package:bettertimetable/api.dart';
import 'package:bettertimetable/consts.dart';
import 'package:bettertimetable/controllers/UserController.dart';
import 'package:bettertimetable/helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class Search extends StatefulWidget {
  const Search({Key? key}) : super(key: key);

  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  var _focus = FocusNode();

  String searchTarget = Consts.availableSearchTargets.first['value']!;
  String searchTerm = '';
  int selectedId = 0;
  dynamic departments;
  List<String> recommendations = [];

  void handleSearchTermChange(String newSearchTerm) {
    setState(() => searchTerm = newSearchTerm);
    if (searchTarget != 'department') {
      return;
    }
    var departmentNames = List<String>.from(
        departments['data'].map((department) => department['name']));
    var matches = matchStrings(departmentNames, newSearchTerm);
    matches.removeWhere((e) => (e['score'] as double) == 0);
    setState(() {
      recommendations = matches
          .map((e) => e['name'] as String)
          .toList()
          .take(Consts.recommendationCount)
          .toList();
      selectedId = 0;
    });
  }

  void handleSearchTargetChange({required int offset}) {
    var currentIndex = Consts.availableSearchTargets.indexWhere(
        (availableSearchTarget) =>
            availableSearchTarget['value'] == searchTarget);
    var newIndex =
        (currentIndex + offset) % Consts.availableSearchTargets.length;
    setState(() {
      searchTarget = Consts.availableSearchTargets[newIndex]['value']!;
    });
  }

  void handleSubmission() {
    String queryString;
    if (searchTarget == 'department') {
      queryString = (departments['data'] as List<dynamic>)
          .where(
              (department) => department['name'] == recommendations[selectedId])
          .first['id'];
    } else {
      queryString = searchTerm;
    }
    Get.toNamed('/result', arguments: {
      'type': searchTarget,
      'query': queryString,
      'force': false
    });
    setState(() => recommendations = []);
  }

  @override
  void initState() {
    final userController = Get.put(UserController());
    getDepartments(acysem: userController.acysem).then((result) {
      setState(() => departments = result);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('NYCU Timetable',
              style: Theme.of(context)
                  .textTheme
                  .headline2
                  ?.copyWith(color: Theme.of(context).textTheme.button?.color)),
          SizedBox(height: 24),
          Container(
            constraints: BoxConstraints(maxWidth: 800),
            child: Row(
              children: [
                SizedBox(width: 128),
                Flexible(
                  child: RawKeyboardListener(
                    onKey: (event) {
                      if (event.isKeyPressed(LogicalKeyboardKey.pageDown)) {
                        handleSearchTargetChange(offset: 1);
                      } else if (event
                          .isKeyPressed(LogicalKeyboardKey.pageUp)) {
                        handleSearchTargetChange(offset: -1);
                      } else if (event
                          .isKeyPressed(LogicalKeyboardKey.arrowDown)) {
                        setState(() => selectedId =
                            (selectedId + 1) % Consts.recommendationCount);
                      } else if (event
                          .isKeyPressed(LogicalKeyboardKey.arrowUp)) {
                        setState(() => selectedId =
                            (selectedId - 1) % Consts.recommendationCount);
                      }
                    },
                    focusNode: FocusNode(),
                    child: TextField(
                      autofocus: true,
                      focusNode: _focus,
                      onChanged: (newValue) => handleSearchTermChange(newValue),
                      onSubmitted: (_) => handleSubmission(),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                SizedBox(
                  width: 120,
                  height: 50,
                  child: DropdownButtonFormField(
                    onChanged: (String? newValue) =>
                        setState(() => searchTarget = newValue!),
                    value: searchTarget,
                    style: Theme.of(context).textTheme.bodyText1,
                    decoration: InputDecoration(border: OutlineInputBorder()),
                    icon: Icon(Icons.expand_more),
                    items: Consts.availableSearchTargets
                        .map(
                          (availableSearchTarget) => DropdownMenuItem(
                            value: availableSearchTarget['value'],
                            child: Text(availableSearchTarget['name']!),
                          ),
                        )
                        .toList(),
                  ),
                )
              ],
            ),
          ),
          Container(
            height: 280,
            constraints: BoxConstraints(maxWidth: 552),
            child: AnimatedCrossFade(
              firstChild: Recents(),
              secondChild: Recommendations(
                  recommendations: recommendations,
                  selectedId: selectedId,
                  onTap: () => handleSubmission()),
              crossFadeState:
                  recommendations.isEmpty || searchTarget != 'department'
                      ? CrossFadeState.showFirst
                      : CrossFadeState.showSecond,
              duration: Duration(milliseconds: 150),
            ),
          )
        ],
      ),
    );
  }
}

class Recents extends StatelessWidget {
  const Recents({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(42, 12, 24, 0),
      child: ListView.separated(
        controller: ScrollController(),
        shrinkWrap: true,
        itemCount: 5,
        itemBuilder: (context, index) => RecentItem(),
        separatorBuilder: (context, index) => Padding(
          padding: const EdgeInsets.only(right: 40.0),
          child: Divider(height: 1),
        ),
      ),
    );
  }
}

class RecentItem extends StatelessWidget {
  const RecentItem({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: InkWell(
            onTap: () => {},
            child: SizedBox(
              height: 40,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(width: 16),
                  Text("Recent Item"),
                ],
              ),
            ),
          ),
        ),
        IconButton(
          onPressed: () => {},
          icon: Icon(Icons.close),
          iconSize: 14,
          splashRadius: 18,
        ),
      ],
    );
  }
}

class Recommendations extends StatelessWidget {
  final List<String> recommendations;
  final int selectedId;
  final Function onTap;

  const Recommendations(
      {Key? key,
      required this.recommendations,
      required this.selectedId,
      required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: ListView.builder(
        shrinkWrap: true,
        controller: ScrollController(),
        itemCount: recommendations.length,
        itemBuilder: (context, index) => ListTile(
          selected: index == selectedId,
          onTap: () => onTap(),
          title: Text(recommendations[index]),
        ),
      ),
    );
  }
}
