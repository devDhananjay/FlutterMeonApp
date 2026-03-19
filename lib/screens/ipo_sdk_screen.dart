import 'package:flutter/material.dart';
import 'package:meon_ipo_flutter/meon_ipo_flutter.dart';

class IpoSdkLauncher extends StatefulWidget {
  const IpoSdkLauncher({super.key});

  @override
  State<IpoSdkLauncher> createState() => _IpoSdkLauncherState();
}

class _IpoSdkLauncherState extends State<IpoSdkLauncher> {
  final TextEditingController _companyController = TextEditingController(
    text: 'ndaindia',
  );

  @override
  void dispose() {
    _companyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _companyController,
              decoration: const InputDecoration(
                labelText: 'Enter IPO Company Name',
                hintText: 'ndaindia',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final company = _companyController.text.trim();
                if (company.isEmpty) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Error'),
                      content: const Text('Please enter a company name.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                  return;
                }

                await MeonIPO.instance.open(
                  context,
                  config: MeonIPOConfig(
                    companyName: company,
                    baseUrl: 'https://ipo.meon.co.in',
                    mode: MeonIPOMode.inapp,
                    headerTitle: 'IPO Portal',
                    headerStartColor: const Color(0xFF1976D2),
                    headerEndColor: const Color(0xFF0D47A1),
                  ),
                );
              },
              child: const Text('Open IPO SDK'),
            ),
          ],
        ),
      ),
    );
  }
}
