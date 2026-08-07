import 'package:flutter/material.dart';

import '../../../../shared/widgets/udo_design_system.dart';
import '../widgets/auth_experience_shell.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: UdoDesign.bg,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AuthMark(),
                SizedBox(height: 34),
                _SplashTitle(),
                SizedBox(height: 12),
                Text(
                  'Your wedding, beautifully managed.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: UdoDesign.muted),
                ),
                SizedBox(height: 42),
                SizedBox(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(
                    color: authAccent,
                    strokeWidth: 2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SplashTitle extends StatelessWidget {
  const _SplashTitle();

  @override
  Widget build(BuildContext context) {
    return Text('Udo', style: UdoDesign.serif(size: 52));
  }
}
