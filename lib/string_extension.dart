import 'package:intl/intl.dart';

extension StringNumberExtension on DateTime {
  String timestampYandex() {
    return "$year-$month-${day}T$hour:$minute:$second.$millisecond-04:00";
  }

  String oldTimestampYandex() {
    return DateFormat("yyyy-MM-ddTHH:mm:ss.mmm").format(DateTime.now()) + "Z";
  }

  String formatISOTime() {
    var duration = timeZoneOffset;
    if (duration.isNegative) {
      String time = (DateFormat("yyyy-MM-ddTHH:mm:ss.mmm").format(DateTime.now()) +
          "-${duration.inHours.toString().padLeft(2, '0')}${(duration.inMinutes - (duration.inHours * 60)).toString().padLeft(2, '0')}");
      print(time);
      return time;
    } else {
      String time = (DateFormat("yyyy-MM-ddTHH:mm:ss.mmm").format(DateTime.now()));
      print(time);
      return time;
    }
  }
}
