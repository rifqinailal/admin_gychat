// models/away_message_model.dart

// Enum untuk membedakan tipe jadwal
enum ScheduleType { always, custom }

class AwayMessage {
  bool isEnabled;
  String message;
  ScheduleType scheduleType;
  DateTime? startTime;
  DateTime? endTime;

  AwayMessage({
    this.isEnabled = false,
    this.message = 'Thank you for your message. We\'re unavailable right now but will respond as soon as possible.',
    this.scheduleType = ScheduleType.always,
    this.startTime,
    this.endTime,
  });
}