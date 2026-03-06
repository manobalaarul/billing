class AppConfig {
  static const String appName = 'Jewellery Manager';
  static const String apiBaseUrl =
      'https://srijewellery.aadhiandcomarket.com/api/v1';

  // API Endpoints
  static const String loginEndpoint = '/auth/login';
  static const String logoutEndpoint = '/auth/logout';
  static const String refreshTokenEndpoint = '/auth/refresh';

  // Dashboard
  static const String dashboardEndpoint = '/dashboard';

  // Gold Rate
  static const String goldRateEndpoint = '/gold-rates';
  static const String goldRateCreateEndpoint = '/gold-rates/create';
  static const String goldRateUpdateEndpoint = '/gold-rates/update';

  // Customer
  static const String customerEndpoint = '/customers';
  static const String customerCreateEndpoint = '/customers/create';
  static const String customerUpdateEndpoint = '/customers/update';
  static const String customerDeleteEndpoint = '/customers/delete';

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String isLoggedInKey = 'is_logged_in';

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Pagination
  static const int defaultPageSize = 20;
}
