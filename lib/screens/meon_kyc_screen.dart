import 'package:flutter/material.dart';
import 'package:flutter_meon_kyc/flutter_meon_kyc.dart';

// Screen 3: Meon KYC Package Screen (Full Screen)
class MeonKYCScreen extends StatelessWidget {
  const MeonKYCScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KYC Package SDK'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: MeonKYC(
        companyName: 'democapital', // TODO: Replace with your actual company name
        workflow: 'individual', // TODO: Replace with your actual workflow type
        enableIPV: true,
        enablePayments: true,
        autoRequestPermissions: true,
        showHeader: true,
        headerTitle: 'Complete Your KYC',
        onSuccess: (data) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'KYC completed at ${data['timestamp'] ?? 'unknown time'}',
              ),
            ),
          );
          Navigator.pop(context);
        },
        onError: (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $error')),
          );
        },
        onClose: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}

