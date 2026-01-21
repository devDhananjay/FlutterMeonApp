import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'kyc_verification_screen.dart';
import 'aadhar_pan_screen.dart';
import 'meon_kyc_screen.dart';
import 'digilocker_screen.dart';
import 'meon_ipo_screen.dart';

// Landing Page - Home Screen with Navigation Cards
class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HOME Screen'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                // Top Row: KYC Verification and Aadhar & Pan API
                Row(
                children: [
                  // Card 1: KYC Verification
                  Expanded(
                    child: _buildNavigationCard(
                      context: context,
                      icon: Icons.verified_user,
                      title: 'KYC Verification',
                      color: Colors.deepPurple,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const KYCVerificationScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Card 2: Aadhar & Pan API
                  Expanded(
                    child: _buildNavigationCard(
                      context: context,
                      icon: Icons.credit_card,
                      title: 'Aadhar & Pan API',
                      color: Colors.blue,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AadharPanScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Bottom Row: KYC Package and Digi Locker
              Row(
                children: [
                  // Card 3: KYC Package
                  Expanded(
                    child: _buildNavigationCard(
                      context: context,
                      icon: Icons.security,
                      title: 'KYC Package',
                      color: Colors.green,
                      onTap: () async {
                        // Request permissions before navigating
                        bool permissionsGranted = await _requestPermissions(context);
                        if (permissionsGranted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MeonKYCScreen(),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Card 4: Digi Locker
                  Expanded(
                    child: _buildNavigationCard(
                      context: context,
                      icon: Icons.folder_shared,
                      title: 'Digi Locker',
                      color: Colors.orange,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const DigiLockerScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Third Row: Meon IPO (centered single card)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: _buildNavigationCard(
                      context: context,
                      icon: Icons.trending_up,
                      title: 'Meon IPO',
                      color: Colors.teal,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MeonIPOScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildNavigationCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.8),
                color,
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 60,
                color: Colors.white,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Request permissions for KYC Package
  Future<bool> _requestPermissions(BuildContext context) async {
    print("🔐 Requesting permissions for KYC Package...");
    
    final cameraStatus = await Permission.camera.status;
    final microphoneStatus = await Permission.microphone.status;
    final locationStatus = await Permission.location.status;

    bool cameraGranted = cameraStatus.isGranted;
    bool microphoneGranted = microphoneStatus.isGranted;
    bool locationGranted = locationStatus.isGranted;

    // Request Camera permission
    if (!cameraGranted) {
      final cameraResult = await Permission.camera.request();
      cameraGranted = cameraResult.isGranted;
    }

    // Request Microphone permission
    if (!microphoneGranted) {
      final micResult = await Permission.microphone.request();
      microphoneGranted = micResult.isGranted;
    }

    // Request Location permission
    if (!locationGranted) {
      final locationResult = await Permission.location.request();
      locationGranted = locationResult.isGranted;
    }

    if (!cameraGranted || !microphoneGranted || !locationGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Some permissions were denied. KYC may not work properly.'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );
    }

    return true; // Continue anyway
  }
}

