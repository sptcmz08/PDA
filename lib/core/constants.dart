class AppConstants {
  const AppConstants._();

  static const appTitle = 'สแกนเลขพัสดุ';
  static const databaseName = 'pda_tracking_scanner.db';
  static const trackingTable = 'tracking_logs';
  static const sessionTable = 'scan_sessions';
  static final trackingRegex = RegExp(r'^\d{12}$');
}
