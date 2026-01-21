import 'package:flutter/material.dart';
import 'package:flutter_meon_digilocker/meon_digilocker_sdk.dart';

// DigiLocker Screen
class DigiLockerScreen extends StatelessWidget {
  const DigiLockerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Digi Locker'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: DigilockerForm(
          companyName: 'democapital',
          secretToken: 'cy7Kw2rWqdzVo2KPxlU0ymd9uRQKPSsb',
          onSuccess: (data) {
            // Show success dialog
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => AlertDialog(
                title: const Text('Success'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Document verification completed successfully!'),
                    const SizedBox(height: 16),
                    Text(
                      'Verified data: ${data.toString()}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close dialog
                      Navigator.of(context).pop(); // Go back to home
                    },
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          },
          onError: (error) {
            // Show error snackbar
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: $error'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 5),
              ),
            );
          },
        ),
      ),
    );
  }
}
