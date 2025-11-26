enum TimeBlock {
  one_day(duration: Duration(hours: 24));

  final Duration duration;

  const TimeBlock({required this.duration});
}
