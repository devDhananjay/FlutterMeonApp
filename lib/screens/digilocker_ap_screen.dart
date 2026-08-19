import 'package:flutter/material.dart';
import 'package:flutter_digilocker_aadhar_pan/flutter_digilocker_aadhar_pan.dart';

class DigiLockerApLauncher extends StatelessWidget {
  const DigiLockerApLauncher({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () async {
          const config = DigiLockerConfig(
            companyName: 'democapital',
            secretToken: 'cy7Kw2rWqdzVo2KPxlU0ymd9uRQKPSsb',
            redirectUrl: 'https://meon.co.in',
          );

          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const DigiLockerApScreen(config: config),
            ),
          );

          if (!context.mounted) return;
          if (result is DigiLockerResponse) {
            debugPrint('DigiLocker Success: ${result.toJson()}');
            debugPrint('Name: ${result.data?.name}');
            debugPrint('Aadhar: ${result.data?.aadharNo}');
            debugPrint('PAN: ${result.data?.panNumber}');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('DigiLocker (Aadhar/PAN) success')),
            );
          }
        },
        child: const Text('Open DigiLocker Aadhar/PAN'),
      ),
    );
  }
}

class DigiLockerApScreen extends StatelessWidget {
  final DigiLockerConfig config;

  const DigiLockerApScreen({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('DigiLocker Aadhar/PAN')),
      body: DigiLockerWidget(
        config: config,
        onSuccess: (response) => Navigator.of(context).pop(response),
        onError: (error) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('DigiLocker error: $error')));
        },
        onClose: () => Navigator.of(context).pop(),
      ),
    );
  }
}
