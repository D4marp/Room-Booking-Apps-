class ApiConfig {
  static const String baseUrl = 'http://localhost:8080';
  
  // Auth endpoints
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String googleCallbackEndpoint = '/auth/google/callback';
  static const String microsoftCallbackEndpoint = '/auth/microsoft/callback';
  
  // Calendar endpoints
  static const String calendarEventsEndpoint = '/calendar/events';
  
  // Booking endpoints
  static const String bookingsEndpoint = '/bookings';
  
  // Room endpoints
  static const String roomsEndpoint = '/rooms';
  
  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
