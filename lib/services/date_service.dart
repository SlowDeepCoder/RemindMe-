class DateService {
  static int getCurrentTimestamp() {
    DateTime date = DateTime.now();
    return date.millisecondsSinceEpoch;
  }
}
