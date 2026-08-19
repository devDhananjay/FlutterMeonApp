import 'package:flutter/material.dart';
import 'package:flutter_meon_digilocker/meon_digilocker_sdk.dart';

class MeonDigilockerLauncher extends StatelessWidget {
  const MeonDigilockerLauncher({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MeonDigilockerSdkScreen()),
          );
        },
        child: const Text('Open Meon DigiLocker'),
      ),
    );
  }
}

class MeonDigilockerSdkScreen extends StatelessWidget {
  const MeonDigilockerSdkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meon DigiLocker')),
      body: DigilockerForm(
        companyName: 'democapital',
        secretToken: 'cy7Kw2rWqdzVo2KPxlU0ymd9uRQKPSsb',
        onSuccess: (response) {
          debugPrint('Meon DigiLocker Success: ${response.toJson()}');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Meon DigiLocker completed successfully')),
          );
        },
        onError: (error) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Meon DigiLocker error: $error')));
        },
      ),
    );
  }
}
