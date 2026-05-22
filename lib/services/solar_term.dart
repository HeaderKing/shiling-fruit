/// 二十四节气计算（21 世纪通用公式，精度 ±1 天）。
/// 索引顺序：0=小寒, 1=大寒, 2=立春, 3=雨水, 4=惊蛰, 5=春分,
///          6=清明, 7=谷雨, 8=立夏, 9=小满,10=芒种,11=夏至,
///         12=小暑,13=大暑,14=立秋,15=处暑,16=白露,17=秋分,
///         18=寒露,19=霜降,20=立冬,21=小雪,22=大雪,23=冬至
class SolarTerm {
  static const names = [
    '小寒', '大寒', '立春', '雨水', '惊蛰', '春分',
    '清明', '谷雨', '立夏', '小满', '芒种', '夏至',
    '小暑', '大暑', '立秋', '处暑', '白露', '秋分',
    '寒露', '霜降', '立冬', '小雪', '大雪', '冬至',
  ];

  static const emojis = [
    '❄️','🧊','🌱','🌧️','🐛','🌸',
    '🌿','🌾','🌞','🌾','🌾','☀️',
    '🌻','🔥','🍂','🍃','💧','🌕',
    '🍁','🌫️','🍃','❄️','☃️','🎍',
  ];

  // 21 世纪 (2000-2099) 通用 C 值，公式：
  // day = floor(Y * 0.2422 + C - floor(Y/4)), Y = year - 2000
  static const _c = [
    5.4055, 20.12,
    3.87, 18.73,
    5.63, 20.646,
    4.81, 20.1,
    5.52, 21.04,
    5.678, 21.37,
    7.108, 22.83,
    7.5, 23.13,
    7.646, 23.042,
    8.318, 23.438,
    7.438, 22.36,
    7.18, 21.94,
  ];

  /// 节气所在月份：每两个节气依次在 1..12 月
  static int monthOf(int termIndex) => termIndex ~/ 2 + 1;

  static DateTime dateOf(int year, int termIndex) {
    final y = year - 2000;
    final c = _c[termIndex];
    final d = (y * 0.2422 + c - (y / 4).floor()).floor();
    return DateTime(year, monthOf(termIndex), d);
  }

  static List<({String name, String emoji, DateTime date})> ofMonth(
      int year, int month) {
    final out = <({String name, String emoji, DateTime date})>[];
    for (var i = 0; i < 24; i++) {
      if (monthOf(i) == month) {
        out.add((
          name: names[i],
          emoji: emojis[i],
          date: dateOf(year, i),
        ));
      }
    }
    return out;
  }

  /// 给定日期，返回所处节气 + 距下一节气的天数。
  static ({String name, String emoji, DateTime date, String next, int daysToNext})
      current(DateTime now) {
    final year = now.year;
    final list = <({int idx, DateTime date})>[];
    for (var i = 0; i < 24; i++) {
      list.add((idx: i, date: dateOf(year, i)));
    }
    list.add((idx: 0, date: dateOf(year + 1, 0)));

    var curIdx = 0;
    DateTime curDate = list.first.date;
    DateTime nextDate = list[1].date;
    int nextIdx = 1;
    for (var i = 0; i < list.length - 1; i++) {
      if (!now.isBefore(list[i].date) && now.isBefore(list[i + 1].date)) {
        curIdx = list[i].idx;
        curDate = list[i].date;
        nextIdx = list[i + 1].idx;
        nextDate = list[i + 1].date;
        break;
      }
    }
    if (now.isBefore(list.first.date)) {
      curIdx = 23;
      curDate = dateOf(year - 1, 23);
      nextIdx = 0;
      nextDate = list.first.date;
    }
    final days =
        nextDate.difference(DateTime(now.year, now.month, now.day)).inDays;
    return (
      name: names[curIdx],
      emoji: emojis[curIdx],
      date: curDate,
      next: names[nextIdx],
      daysToNext: days,
    );
  }
}
