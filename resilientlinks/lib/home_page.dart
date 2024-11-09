import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:resilientlinks/pop_menu.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _QrScannerState();
}

class _QrScannerState extends State<HomePage> with WidgetsBindingObserver {
  late MobileScannerController controller;
  String barcodeResult = 'No QR Code detected';
  bool hasScanned = false;
  bool isAlreadyOne = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Initialize the scanner controller
    controller = MobileScannerController(
      facing: CameraFacing.back, // Use the back camera
      torchEnabled: false, // Disable torch initially
    );

    // Start the scanner
    controller.start();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    controller.dispose(); // Dispose the controller when done
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!controller.value.isInitialized) return;

    if (state == AppLifecycleState.paused) {
      controller.stop();
    } else if (state == AppLifecycleState.resumed) {
      controller.start();
    }
  }

  // Function to handle scanning logic
  void _onBarcodeScanned(BarcodeCapture barcodeCapture) async {
    if (!hasScanned) {
      final barcode = barcodeCapture.barcodes.first;
      final barcodeData = barcode.rawValue ?? 'Unknown QR Code';

      if (barcodeData != 'Unknown QR Code') {
        // Prevent further scanning until reset
        setState(() {
          hasScanned = true;
          barcodeResult = 'Processing QR Code...';
        });

        // Check if the document exists in Firestore
        try {
          DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
              .collection('aid_donation')
              .doc(barcodeData)
              .get();

          if (documentSnapshot.exists) {
            if (documentSnapshot['status'] == 1) {
              controller.stop();
              setState(() {
                isAlreadyOne = true;
              });

              _showFailDialog("Aid pack already recorded", Icons.warning,
                  Color(0xFFFFBB33));
            } else {
              await FirebaseFirestore.instance
                  .collection('aid_donation')
                  .doc(barcodeData)
                  .set({
                'status': 1,
                'collectedOn': FieldValue.serverTimestamp(),
              }, SetOptions(merge: true));

              // Stop the scanner after successful scan
              controller.stop();

              // Fetch items collection
              QuerySnapshot itemsSnapshot = await FirebaseFirestore.instance
                  .collection('aid_donation')
                  .doc(barcodeData)
                  .collection('items')
                  .get();

              List<String> itemsList = [];
              for (var item in itemsSnapshot.docs) {
                String itemName = item['itemName'];
                int quantity = item['quantity'];
                itemsList.add('$itemName: $quantity');
              }

              // Show success dialog
              _showQrDialog(barcodeData, itemsList);
            }
          } else {
            print('Document does not exist');
            setState(() {
              hasScanned = false; // Allow scanning again
            });
            controller.stop();

            _showFailDialog(
                "No record Found", Icons.error_outline, Color(0xFFFF4444));
          }
        } catch (e) {
          print('Error updating status: $e');
          setState(() {
            barcodeResult = 'Error updating status';
            hasScanned = false; // Allow scanning again
          });
        }
      }
    }
  }

  // Function to show the dialog with QR code information
  void _showQrDialog(String qrCode, List<String> items) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Column(
            mainAxisSize: MainAxisSize.min, // Use only necessary space
            children: [
              Icon(
                Icons.check,
                color: Colors.green,
                size: 80,
              ),
              const Text('Aid Pack Received'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Ref Id: $qrCode',
                  style: TextStyle(color: Colors.black45),
                ),
                const SizedBox(height: 10),
                ...items.map((item) => Text(item)).toList(),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  hasScanned = false;
                  barcodeResult = 'No QR Code detected';
                  controller.start();
                });
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Function to show the dialog with fail code information
  void _showFailDialog(String message, IconData icon, Color color) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Icon(
            icon,
            color: color,
            size: 80,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(message),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  hasScanned = false;
                  barcodeResult = 'No QR Code detected';
                  controller.start();
                });
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF015490),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF015490),
        title: Image.asset(
          "images/whitelogo.png",
          height: 30,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: PopMenu(),
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Expanded(
              flex: 1,
              child: Column(
                children: [
                  Text(
                    "ResilientLink Scanner",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                      fontSize: 24,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 6,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(20), // Circular border radius
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          "Place the QR code in the area",
                          style: TextStyle(
                            color:
                                Colors.black, // Adjusted color for visibility
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            letterSpacing: 1,
                          ),
                        ),
                        Text(
                          "Scanning will be started automatically",
                          style: TextStyle(
                            color:
                                Colors.black, // Adjusted color for visibility
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20), // Add spacing
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: SizedBox(
                          height: 300, // Define height for scanner area
                          child: MobileScanner(
                            controller: controller,
                            onDetect:
                                _onBarcodeScanned, // Trigger scan handling
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(
                alignment: Alignment.center,
                child: Text(
                  barcodeResult,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
