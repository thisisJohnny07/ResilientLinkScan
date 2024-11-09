import 'package:flutter/material.dart';
import 'package:resilientlinks/verification.dart';
import 'package:resilientlinks/verification_service.dart';

class PopMenu extends StatelessWidget {
  const PopMenu({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final VerificationService _verificationService = VerificationService();

    void _signOut() async {
      await _verificationService.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Verification()),
      );
    }

    return PopupMenuTheme(
      data: const PopupMenuThemeData(
        color: Colors.white,
      ),
      child: PopupMenuButton<int>(
        tooltip: '',
        itemBuilder: (BuildContext context) {
          return <PopupMenuEntry<int>>[
            PopupMenuItem<int>(
              value: 1,
              child: GestureDetector(
                onTap: () => _signOut(),
                child: SizedBox(
                  width: 60,
                  child: Row(
                    children: [
                      Icon(
                        Icons.logout,
                        color: const Color(0xFF015490),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Text("Exit"),
                    ],
                  ),
                ),
              ),
            ),
          ];
        },
        offset: Offset(0, 20),
        child: Icon(
          Icons.person,
          color: Colors.white,
        ),
      ),
    );
  }
}
