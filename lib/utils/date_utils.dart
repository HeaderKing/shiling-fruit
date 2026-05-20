// 日期与旬段相关工具。
// 旬段定义：1-10 上旬, 11-20 中旬, 21-月末 下旬。

const periodNames = ['上旬', '中旬', '下旬'];

String periodOfDay(int day) {
  if (day <= 10) return '上旬';
  if (day <= 20) return '中旬';
  return '下旬';
}

String currentPeriod([DateTime? now]) {
  final t = now ?? DateTime.now();
  return periodOfDay(t.day);
}

int currentMonth([DateTime? now]) => (now ?? DateTime.now()).month;
