import 'package:flutter/material.dart';
import 'package:manuscan/widgets/custom_bottom_navigation_bar.dart';
import 'package:manuscan/controllers/auth_controller.dart';
import 'package:get/get.dart';
import 'palletreturn/qr_return.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final authController = Get.find<AuthController>(); // Use find instead of put

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    print('HomeScreen initState called');
    print('AuthController firstName: ${authController.firstName}');
    print('AuthController role: ${authController.role}');
    print('AuthController isLoggedIn: ${authController.isLoggedIn}');
    if (authController.role == 'security') {
      Future.microtask(() => Get.offAllNamed('/security'));
      return;
    }
    _screens = [
      HomeScreenContent(authController: authController),
      const NotificationsScreen(),
      const SettingsScreen(),
      ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    print('HomeScreen build method called');
    print('Current index: $_currentIndex');
    print('AuthController isLoading: ${authController.isLoading}');
    print('AuthController isLoggedIn: ${authController.isLoggedIn}');

    return WillPopScope(
      onWillPop: () async => false, // Disable back button
      child: Scaffold(
        backgroundColor: Colors.white,
        bottomNavigationBar: CustomBottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            print('Bottom nav tapped: $index');
            setState(() {
              _currentIndex = index;
            });
          },
        ),
        body: SafeArea(
          child: Obx(
            () {
              print('HomeScreen Obx rebuild triggered');
              if (authController.isLoading) {
                print('Showing loading indicator');
                return const Center(child: CircularProgressIndicator());
              }
              if (_currentIndex == 0) {
                print('Showing HomeScreenContent');
                return HomeScreenContent(authController: authController);
              }
              print('Showing screen at index: $_currentIndex');
              return _screens[_currentIndex];
            },
          ),
        ),
      ),
    );
  }
}

class HomeScreenContent extends StatelessWidget {
  final AuthController authController;

  const HomeScreenContent({Key? key, required this.authController})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('HomeScreenContent build method called');
    print('AuthController firstName: ${authController.firstName}');
    print('AuthController role: ${authController.role}');

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() => _buildHeader(userName: authController.firstName)),
          const SizedBox(height: 20),
          const Text(
            "What would you like to do ?",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _buildActionCard(
            context: context,
            imagePath: 'assets/images/pd.png', // Add your image path here
            title: "Pallet Dispatch",
            description:
                "Manage the outbound movement of pallets by tracking dispatch details and ensuring accurate inventory updates.",
            onTap: () {
              print(
                  'Pallet Dispatch tapped - navigating to PalletDispatchScreen1');
              Get.toNamed('/palletdispatch');
            },
          ),
          _buildActionCard(
            context: context,
            imagePath: 'assets/images/pr.png', // Add your image path here
            title: "Pallet Return",
            description:
                "Handle the return of pallets efficiently by recording inbound shipments, verifying conditions, and updating stock levels.",
            onTap: () {
              print('Pallet Return tapped');
              // Call showChallanIdPopup to start the return process.
              showChallanIdPopup(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeader({required String userName}) {
    print('_buildHeader called with userName: $userName');
    return Container(
      padding: const EdgeInsets.all(16),
      child: Stack(
        children: [
          Image.asset('assets/images/textbg.png'), // Add your image here
          Positioned(
            left: 16,
            top: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Welcome, $userName",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "Manage your inventory seamlessly. Navigate through dispatch, returns, and defect detection with ease",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required BuildContext context,
    required String imagePath,
    required String title,
    required String description,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 10),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(imagePath, width: 40, height: 40),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      description,
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none,
              size: 80,
              color: Colors.black54,
            ),
            SizedBox(height: 10),
            Text(
              "You have no notifications",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthController authController = Get.find();

  String _getRoleDisplay() {
    final role = authController.role;
    return role;
  }

  String _getLastLoginDisplay() {
    if (authController.lastLogin.isNotEmpty) {
      try {
        final dateTime = DateTime.parse(authController.lastLogin);
        return "${dateTime.toLocal().toString().split('.')[0]}";
      } catch (e) {
        return "N/A";
      }
    } else {
      return "N/A";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Removed BottomNavigationBar
      body: Container(
        color: Colors.white,
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 40,
                backgroundColor: Colors.teal.shade200,
                child: Icon(Icons.person, size: 50, color: Colors.white),
              ),
            ),
            SizedBox(height: 10),
            Center(
              child: Text(
                "${authController.firstName} ${authController.lastName}",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 5),
            Center(
              child: Column(
                children: [
                  Text("Username: ${authController.userName}"),
                  Text("Last Login: ${_getLastLoginDisplay()}"),
                ],
              ),
            ),
            SizedBox(height: 15),
            Divider(),
            sectionTitle("Account Status"),
            profileDetail("Role", _getRoleDisplay()),
          ],
        ),
      ),
    );
  }

  Widget sectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(top: 10, bottom: 5),
      child: Text(
        title,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget profileDetail(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Text("$label: $value"),
    );
  }
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AuthController authController = Get.find();
  // State variables
  bool notificationsEnabled = true;
  String selectedLanguage = 'English';
  int selectedIndex = 2; // For bottom navigation
  bool isDarkMode = false;

  // Language options

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                authController.logout();
              },
              child: const Text('Logout', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildProfileSettings(),
                  _buildNotificationSettings(),
                  _buildLanguageSettings(),
                  _buildSecuritySettings(),
                  _buildHelpAndSupport(),
                  _buildPrivacyPolicy(),
                  const Spacer(),
                  _buildLogoutButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSettings() {
    return _buildSettingItem(
      icon: Icons.person_outline,
      title: 'Profile Settings',
    );
  }

  Widget _buildNotificationSettings() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading:
            const Icon(Icons.notifications_outlined, color: Colors.black87),
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageSettings() {
    return _buildSettingItem(
      icon: Icons.language_outlined,
      title: 'Language Preferences',
      trailing: Text(
        selectedLanguage,
        style: const TextStyle(color: Colors.grey),
      ),
    );
  }

  String _getRoleDisplay() {
    final role = authController.role;
    return role;
  }

  Widget _buildSecuritySettings() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: const Icon(Icons.lock_outline, color: Colors.black87),
        title: Text(
          _getRoleDisplay(),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildHelpAndSupport() {
    return _buildSettingItem(
      icon: Icons.help_outline,
      title: 'Help & Support',
    );
  }

  Widget _buildPrivacyPolicy() {
    return _buildSettingItem(
      icon: Icons.privacy_tip_outlined,
      title: 'Privacy Policy',
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.black87, size: 24),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: const Icon(Icons.logout, color: Colors.red, size: 24),
        title: const Text(
          'Logout',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.red,
          ),
        ),
        onTap: _handleLogout,
      ),
    );
  }

  void showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text(
            "Logout Confirmation",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text("Are you sure you want to log out?"),
          actions: [
            TextButton(
              onPressed: () {
                authController.logout();
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.black87,
                foregroundColor: Colors.white,
              ),
              child: const Text("CONFIRM"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.grey[300],
                foregroundColor: Colors.black,
              ),
              child: const Text("CANCEL"),
            ),
          ],
        );
      },
    );
  }
}
