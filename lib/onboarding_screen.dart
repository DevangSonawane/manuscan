import 'package:flutter/material.dart';
import 'login_page.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Stack(
          children: <Widget>[
            Positioned(
              top: 50,
              left: 20,
              child: Text(
                'WELCOME TO',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            Positioned(
              top: 70,
              left: 20,
              child: Text(
                'ManuScan',
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'Midnights on the Shore',
                  color: Colors.black,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Image.asset(
                      'assets/images/image1.png',
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.only(left: 15.0),
                      child: Text(
                        'Manage Inventory',
                        style: const TextStyle(
                          color: Color.fromRGBO(27, 27, 30, 1),
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'DMSans-VariableFont_opsz,wght',
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 15),
                      child: Text(
                        'Track & organize your inventory with ease',
                        style: const TextStyle(
                          color: Color.fromRGBO(27, 27, 30, 1),
                          fontSize: 16,
                          fontFamily: 'Roboto-Regular',
                        ),
                      ),
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 80, // Changed from 50 to 100 to shift the button upwards
              left: 20,
              right: 20,
              child: Column(
                children: <Widget>[
                  const SizedBox(height: 200),
                  // Commented out the 'Create Account' functionality
                  /*
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Createaccount()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: Color.fromRGBO(55, 63, 81, 1),
                        elevation: 5,
                        shadowColor: Colors.black.withOpacity(0.2)),
                    child: const Text(
                          'CREATE ACCOUNT',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      */
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => login_account()),
                          );
                        },
                        style: TextButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          backgroundColor: Color.fromRGBO(55, 63, 81, 1),
                          elevation: 5,
                          shadowColor: Colors.black.withOpacity(0.2),
                        ),
                        child: const Text(
                          'LOG IN',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Add dana.png image at the top right
                Positioned(
                  top: 40,
                  right: 20,
                  child: Image.asset(
                    'assets/images/dana.png',
                    width: 80, // Adjust size as needed
                    height: 80,
                  ),
                ),
              ],
            ),
          ),
        );
  }
}
