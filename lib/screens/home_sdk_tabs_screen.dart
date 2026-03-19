import 'package:flutter/material.dart';
import 'package:kyc_flutter_app/screens/digilocker_ap_screen.dart';
import 'package:kyc_flutter_app/screens/face_sdk_screen.dart';
import 'package:kyc_flutter_app/screens/ipo_sdk_screen.dart';
import 'package:kyc_flutter_app/screens/kyc_sdk_screen.dart';
import 'package:kyc_flutter_app/screens/meon_digilocker_sdk_screen.dart';

class HomeSdkTabsScreen extends StatelessWidget {
  const HomeSdkTabsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('SDK Hub'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'KYC'),
              Tab(text: 'Face-Finder'),
              Tab(text: 'E -doc Retrieval'),
              Tab(text: 'Digilocker A/P'),
              Tab(text: 'IPO'),
             
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            KycSdkLauncher(),
            FaceSdkLauncher(),
            DigiLockerApLauncher(),
            MeonDigilockerLauncher(),
            IpoSdkLauncher(),
           
          ],
        ),
      ),
    );
  }
}
