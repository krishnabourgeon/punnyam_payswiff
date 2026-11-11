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
  static String psMerchantKey = 'A329C0400B3E';
  static String psPartnerKey = 'B01408266464';
  static String psMerchantApiKey = 'A329C0400B3E';
  static String psSecureKey = '97A9DE902103592A46E712C2502606E';
  static String? psMid = '2430535'; 
  static String? psTid;
  static String? psSerialNo;
}
