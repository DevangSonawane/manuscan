class ApiEndpoints {
  static const String baseUrl = 'http://10.200.32.43:8800';  //your-base-url

  // Dispatch endpoints
  static const String activeChallans = '$baseUrl/dispatch/active-challans';
  static const String challanDetails = '$baseUrl/dispatch/challan';
  static const String processDispatch = '$baseUrl/dispatch/process';
  static const String confirmDispatch = '$baseUrl/dispatch/confirm';

  // Security endpoints
  static const String approveDispatch = '$baseUrl/security/approve';
  static const String rejectDispatch = '$baseUrl/security/reject';
}
