import 'package:flutter/material.dart';
import 'package:resilientlinks/home_page.dart';
import 'package:resilientlinks/verification_service.dart';

class Verification extends StatefulWidget {
  const Verification({super.key});

  @override
  State<Verification> createState() => _VerificationState();
}

class _VerificationState extends State<Verification> {
  final TextEditingController _code = TextEditingController();
  String errorMessage = '';

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  final VerificationService _verificationService = VerificationService();

  // Function to handle verification
  Future<void> _verifyUID() async {
    String uid = _code.text;

    bool isVerified = await _verificationService.verifyUID(uid);

    if (isVerified) {
      // Navigate to HomePage if verified
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } else {
      setState(() {
        errorMessage = 'Invalid UID. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF015490),
              Color(0xFF428CD4),
              Color(0xFF015490),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  spreadRadius: 1,
                  blurRadius: 1,
                  offset: const Offset(0.5, 1),
                ),
              ],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      "images/mainlogo.png",
                      height: 50,
                    ),
                    const SizedBox(width: 15),
                    const Icon(Icons.close),
                    const SizedBox(width: 15),
                    Image.asset(
                      "images/pdrrmo.png",
                      height: 80,
                    ),
                  ],
                ),
                const SizedBox(height: 50),
                TextField(
                  controller: _code,
                  decoration: InputDecoration(
                    labelText: "Enter Verification Code",
                    border: const OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey.shade300,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Color(0xFF015490),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF015490),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    elevation: 2,
                    shadowColor: Colors.black,
                  ),
                  onPressed: () => _verifyUID(),
                  child: const Text("Verify"),
                ),
                if (errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Text(
                      errorMessage,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                      ),
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
