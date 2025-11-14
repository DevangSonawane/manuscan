import 'package:manuscan/services/api_endpoints.dart';
import 'package:manuscan/services/api_urls.dart';
// ignore_for_file: avoid_print
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../onboarding_screen.dart';
import 'package:flutter/foundation.dart'; 

class AuthController extends GetxController {
  final _isLoggedIn = false.obs;
  final _currentUser = Rx<Map<String, dynamic>?>(null);
  final _isLoading = false.obs;
  final _errorMessage = ''.obs;
  final _token = RxString('');
  final RxString username = 'Security Guard'.obs;

  // Change from RxString to getter/setter pattern
  final _firstName = RxString('Security Guard');
  String get firstName => _firstName.value;
  set firstName(String value) => _firstName.value = value;

  final RxString _lastName = ''.obs;
  final RxString _email = ''.obs;
  final RxString _role = ''.obs;
  final RxString _userName = ''.obs;
  final RxString _lastLogin = ''.obs;

  bool get isLoggedIn => _isLoggedIn.value;
  RxBool get isLoggedInRx => _isLoggedIn;
  Map<String, dynamic>? get currentUser => _currentUser.value;
  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;
  String get token => _token.value;
  String get userFirstName => firstName;
  String get lastName => _lastName.value;
  String get email => _email.value;
  String get role => _role.value;
  String get userName => _userName.value;
  String get lastLogin => _lastLogin.value;

  @override
  void onInit() {
    super.onInit();
    checkAuth();
  }

  Future<String> checkAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    if (isLoggedIn) {
      _isLoggedIn.value = true;
      _firstName.value = prefs.getString('firstName') ?? 'Security Guard';
      _lastName.value = prefs.getString('lastName') ?? '';
      _email.value = prefs.getString('email') ?? '';
      _role.value = prefs.getString('role') ?? '';
      _userName.value = prefs.getString('userName') ?? '';
      _lastLogin.value = prefs.getString('lastLogin') ?? '';
      _currentUser.value = {
        'firstName': _firstName.value,
        'lastName': _lastName.value,
        'email': _email.value,
        'role': _role.value,
        'userName': _userName.value,
        'lastLogin': _lastLogin.value,
      };
      print('User is logged in from saved session.');
      if (_role.value == 'securityguard' || _role.value == 'security') {
        return '/security';
      } else {
        return '/home';
      }
    } else {
      print('User is not logged in.');
      return '/';
    }
  }

  // 🔧 NEW: Method to get device MAC address
  Future<String> getDeviceMacAddress() async {
    try {
      final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      String macAddress = '';

      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        // For Android, we'll use device ID as MAC address might not be accessible
        macAddress = androidInfo.id;
        print('Android Device ID (used as MAC): $macAddress');
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        // For iOS, use identifierForVendor
        macAddress = iosInfo.identifierForVendor ?? 'unknown_ios_device';
        print('iOS Identifier (used as MAC): $macAddress');
      }

      // Alternative: Try to get actual WiFi MAC address (may not work on newer devices due to privacy restrictions)
      try {
        final NetworkInfo networkInfo = NetworkInfo();
        String? wifiBSSID = await networkInfo.getWifiBSSID();
        if (wifiBSSID != null &&
            wifiBSSID.isNotEmpty &&
            wifiBSSID != '02:00:00:00:00:00') {
          macAddress = wifiBSSID;
          print('WiFi BSSID (MAC): $macAddress');
        }
      } catch (e) {
        print('Could not get WiFi BSSID: $e');
      }

      // Fallback if no MAC address found
      if (macAddress.isEmpty) {
        macAddress = 'device_${DateTime.now().millisecondsSinceEpoch}';
        print('Using fallback MAC: $macAddress');
      }

      return macAddress;
    } catch (e) {
      print('Error getting device MAC address: $e');
      return 'unknown_device_${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  // 🔧 UPDATED: Login method with MAC address validation
  Future<void> login(String email, String password) async {
    try {
      String macAddress =
          kIsWeb ? 'web_dummy_mac' : await getDeviceMacAddress();

      final response = await http
          .post(
            Uri.parse('${ApiUrls.palletDispatchBase}/Login'),
            headers: {'Content-Type': 'application/json; charset=UTF-8'},
            body: jsonEncode({
              'user_name': email,
              'password': password,
              'mac_address': macAddress,
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        _currentUser.value = responseData['user'];
        _role.value = responseData['user']['role']?.toLowerCase() ?? 'user';
        _isLoggedIn.value = true;
        Get.offNamed(_role.value == 'securityguard' || _role.value == 'security'
            ? '/security'
            : '/home');
      } else {
        final responseData = jsonDecode(response.body);
        _errorMessage.value = responseData['error'] ?? 'Login failed';
      }
    } catch (e) {
      _errorMessage.value = 'Network error. Please try again.';
    } finally {
      _isLoading.value = false;
    }
  }
  //

  Future<void> _saveLoginState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('firstName', _firstName.value);
    await prefs.setString('lastName', _lastName.value);
    await prefs.setString('email', _email.value);
    await prefs.setString('role', _role.value);
    await prefs.setString('userName', _userName.value);
    await prefs.setString('lastLogin', _lastLogin.value);
  }

// Add this method to your AuthController for testing
  Future<void> testMacAddress() async {
    String mac = await getDeviceMacAddress();
    print('Fetched MAC Address: $mac');
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _isLoggedIn.value = false;
    _currentUser.value = null;
    _token.value = ''; // Clear the token on logout
    _lastLogin.value = '';
    // Restore navigation functionality
    Get.offAll(() => const OnboardingScreen());
    print('Logout - navigating to OnboardingScreen');
  }

  // Update setUserData method
  void setUserData({
    required String firstName,
    required String lastName,
    required String email,
    required String role,
  }) {
    _firstName.value = firstName;
    _lastName.value = lastName;
    _email.value = email;
    _role.value = role;
  }

  // Method to clear user data on logout
  void clearUserData() {
    _firstName.value = '';
    _lastName.value = '';
    _email.value = '';
    _role.value = '';
    _userName.value = '';
  }

  void setAdminRole() {
    _role.value = 'admin';
    _isLoggedIn.value = true;
    username.value = 'Admin';
    _firstName.value = 'Admin';
    update();
  }
}
