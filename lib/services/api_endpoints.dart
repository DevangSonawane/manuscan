class ApiEndpoints {
  static const String baseUrl = 'YOUR_BASE_URL';

  // Dispatch endpoints
  static const String activeChallans = '$baseUrl/dispatch/active-challans';
  static const String challanDetails = '$baseUrl/dispatch/challan';
  static const String processDispatch = '$baseUrl/dispatch/process';
  static const String confirmDispatch = '$baseUrl/dispatch/confirm';

  // Security endpoints
  static const String approveDispatch = '$baseUrl/security/approve';
  static const String rejectDispatch = '$baseUrl/security/reject';
}
