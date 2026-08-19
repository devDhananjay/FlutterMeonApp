import 'package:flutter/material.dart';

class RekycInfoScreen extends StatelessWidget {
  const RekycInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          'Re-KYC flow is temporarily disabled in this build.\n\nUse other tabs to test active SDKs.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
