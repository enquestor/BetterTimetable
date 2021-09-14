import 'dart:math';

double matchScore(String str1, String str2) {
  // ignore white spaces
  str1.replaceAll(' ', '');
  str2.replaceAll(' ', '');

  var l1 = str1.runes.toList();
  var l2 = str2.runes.toList();
  int i = 0, j = 0;
  double score = 0;

  while (i < l1.length && j < l2.length) {
    if (l1[i] == l2[j]) {
      double ip = (i + 1) / (l1.length + 1);
      double jp = (j + 1) / (l2.length + 1);
      double closeness = 1 - (ip - jp).abs();
      score += (1 + closeness);
      j++;
    }
    i++;
  }

  score +=
      1 - (str2.length - str1.length).abs() / max(str2.length, str1.length);

  if (score >= str2.length && str1.contains(str2)) {
    // give close length higher points
    score *= 1.4;
  }

  return score;
}

List<Map<String, dynamic>> matchStrings(List<String> data, String match) {
  var scores =
      data.map((e) => {'name': e, 'score': matchScore(e, match)}).toList();
  scores
      .sort((a, b) => -(a['score'] as double).compareTo(b['score'] as double));
  return scores;
}

class Matcher {
  static double match(String str1, String str2) {
    List<String> pairs1 = _wordLetterPairs(str1);
    List<String> pairs2 = _wordLetterPairs(str2);
    int intersection = 0;
    int union = pairs1.length + pairs2.length;
    pairs1.forEach((pair1) {
      for (int j = 0; j < pairs2.length; j++) {
        var pair2 = pairs2[j];
        if (pair1 == pair2) {
          intersection++;
          pairs2.removeAt(j);
          break;
        }
      }
    });
    return (2 * intersection) / union;
  }

  static List<String> _wordLetterPairs(String str) {
    List<String> allPairs = [];
    var words = str.split('\\s');
    words.forEach((word) {
      List<String> pairsInWord = _letterPairs(word);
      pairsInWord.forEach((pair) {
        allPairs.add(pair);
      });
    });
    return allPairs;
  }

  static List<String> _letterPairs(String str) {
    int numPairs = str.length - 1;
    List<String> pairs = [];
    for (int i = 0; i < numPairs; i++) {
      pairs.add(str.substring(i, i + 2));
    }
    return pairs;
  }
}
