import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:smart_attendance/models/session_model.dart';
import 'package:smart_attendance/theme/app_theme.dart';
import 'package:smart_attendance/services/location_service.dart';
import 'package:smart_attendance/services/database_service.dart';
import 'package:smart_attendance/services/sync_service.dart';
import 'package:uuid/uuid.dart';

class QrScanScreen extends StatefulWidget {
  const QrScanScreen({super.key});

  @override
  State<QrScanScreen> createState() => _QrScanScreenState();
}

class _QrScanScreenState extends State<QrScanScreen> {
  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );
  bool _isProcessing = false;

  void _processScannedData(String payload) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      final session = AttendanceSession.fromJson(payload);
      
      if (!session.isValid) {
        _showResult(
          "Session Expired", 
          "The QR code for ${session.subject} has expired.", 
          false,
        );
        return;
      }

      // Check GPS
      bool isWithinDomain = false;
      try {
        isWithinDomain = await LocationService.isWithinRange(
          session.latitude, 
          session.longitude, 
          allowedRadiusMeters: 200.0, // generous 200m radius
        );
      } catch (e) {
         _showResult("Location Error", e.toString(), false);
         return;
      }

      if (!isWithinDomain) {
         _showResult(
          "Out of Bounds", 
          "You are too far from the session's designated location.", 
          false,
        );
        return;
      }

      // Record offline attendance
      final db = DatabaseService();
      await db.insertRecord(
        AttendanceRecord(
          sessionId: session.sessionId,
          subject: session.subject,
          studentId: const Uuid().v4(), // Mocked student ID since we don't have login
          timestamp: DateTime.now().millisecondsSinceEpoch,
        ),
      );

      // Trigger background sync conditionally
      SyncService().syncPendingRecords();

      _showResult(
        "Attendance Marked",
        "Successfully recorded attendance for ${session.subject}.",
        true,
      );

    } catch (e) {
      _showResult("Invalid QR Code", "Please scan a valid EduTrack Session QR code.", false);
    }
  }

  void _showResult(String title, String message, bool isSuccess) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle_rounded : Icons.error_rounded,
              color: isSuccess ? AppTheme.successColor : AppTheme.errorColor,
            ),
            const SizedBox(width: 12),
            Text(title, style: const TextStyle(color: AppTheme.textColor)),
          ],
        ),
        content: Text(message, style: const TextStyle(color: AppTheme.textSecondaryColor)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _isProcessing = false);
              _scannerController.start();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan QR Code')),
      body: Stack(
        children: [
          MobileScanner(
            controller: _scannerController,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  _scannerController.stop();
                  _processScannedData(barcode.rawValue!);
                  break;
                }
              }
            },
          ),
          // Overlay UI for scanning
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundColor.withOpacity(0.9),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.qr_code_scanner_rounded,
                      size: 48,
                      color: AppTheme.primaryColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Position QR code within the frame',
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Attendance will be marked automatically',
                      style: TextStyle(color: AppTheme.textSecondaryColor),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_isProcessing)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
