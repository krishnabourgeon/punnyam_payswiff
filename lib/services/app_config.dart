class AppConfig {
  static final AppConfig _instance = AppConfig._internal();
  factory AppConfig() => _instance;
  AppConfig._internal();

  static String baseUrl = "http://appuser.templesoftware.in/public/api/";
  static String? accessToken;
  static String? counterID;
  static int? customerId;
  static String? customerName;
  static String? customerNumber;
  static String? settings;
  static int? version = 1;
  static String psMerchantKey = 'A0229BB8B4E0';
  static String psPartnerKey = 'A0229BB8B4E0';
  static String psMerchantApiKey = 'A0229BB8B4E0';
  static String psSecureKey = 'B9555252F36195836D54EAEEDED6A7BF';
  static String? psMid = '1006080'; 
  static String? psTid;
  static String? psSerialNo;
}
