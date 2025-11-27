enum TimeBlock {
  six_hours(duration: Duration(hours: 6)),
  one_day(duration: Duration(hours: 24)),
  one_week(duration: Duration(days: 7));

  final Duration duration;

  const TimeBlock({required this.duration});
}
