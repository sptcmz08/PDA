import 'package:intl/intl.dart';

class DateHelper {
  const DateHelper._();

  static final _dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm:ss');
  static final _dateFormat = DateFormat('dd/MM/yyyy');
  static final _timeFormat = DateFormat('HH:mm:ss');
  static final _fileFormat = DateFormat('yyyy-MM-dd_HH-mm');

  static String formatDateTime(DateTime value) {
    return _dateTimeFormat.format(value);
  }

  static String formatDate(DateTime value) {
    return _dateFormat.format(value);
  }

  static String formatTime(DateTime value) {
    return _timeFormat.format(value);
  }

  static String formatCsvFileTimestamp(DateTime value) {
    return _fileFormat.format(value);
  }
}
