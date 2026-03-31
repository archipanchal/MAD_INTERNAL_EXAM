import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:smart_attendance/models/session_model.dart';
import 'package:smart_attendance/theme/app_theme.dart';
import 'package:uuid/uuid.dart';
import 'dart:async';

class QrGenerateScreen extends StatefulWidget {
  const QrGenerateScreen({super.key});

  @override
  State<QrGenerateScreen> createState() => _QrGenerateScreenState();
}

class _QrGenerateScreenState extends State<QrGenerateScreen> {
  final _subjectController = TextEditingController();
  final _durationController = TextEditingController(text: '15');
  AttendanceSession? _session;
  Timer? _timer;
  Duration _timeLeft = Duration.zero;

  void _generateQr() {
    if (_subjectController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a subject name')),
      );
      return;
    }

    final durationMin = int.tryParse(_durationController.text) ?? 15;
    
    // For Phase 3, we'll fetch real GPS coords. For now, mock them.
    const mockLat = 23.022505;
    const mockLng = 72.571362;

    setState(() {
      _session = AttendanceSession(
        sessionId: const Uuid().v4(),
        subject: _subjectController.text.trim(),
        expiresAt: DateTime.now().add(Duration(minutes: durationMin)),
        latitude: mockLat,
        longitude: mockLng,
      );
    });

    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_session == null || !_session!.isValid) {
        timer.cancel();
        setState(() {
          _timeLeft = Duration.zero;
        });
      } else {
        setState(() {
          _timeLeft = _session!.expiresAt.difference(DateTime.now());
        });
      }
    });
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _durationController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Generate Session Code')),
      body: SafeArea(
        child: _session == null ? _buildForm() : _buildQrView(),
      ),
    );
  }

  Widget _buildForm() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _subjectController,
            decoration: const InputDecoration(
              labelText: 'Subject Name',
              hintText: 'e.g. Mobile Application Development',
              prefixIcon: Icon(Icons.class_rounded),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _durationController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Validity Duration (minutes)',
              prefixIcon: Icon(Icons.timer_rounded),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _generateQr,
            child: const Text('Generate QR Code'),
          ),
        ],
      ),
    );
  }

  Widget _buildQrView() {
    final isValid = _session!.isValid;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _session!.subject,
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontSize: 24,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              isValid ? 'Scan to mark attendance' : 'Session Expired',
              style: TextStyle(
                color: isValid ? AppTheme.successColor : AppTheme.errorColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: QrImageView(
                data: _session!.toJson(),
                version: QrVersions.auto,
                size: 250.0,
                backgroundColor: Colors.white,
                eyeStyle: const QrEyeStyle(
                  eyeShape: QrEyeShape.circle,
                  color: AppTheme.primaryColor,
                ),
                dataModuleStyle: const QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.circle,
                  color: AppTheme.surfaceColor,
                ),
              ),
            ),
            const SizedBox(height: 32),
            if (isValid)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.timer_outlined, color: AppTheme.secondaryColor),
                  const SizedBox(width: 8),
                  Text(
                    'Expires in: ${_formatDuration(_timeLeft)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.mono,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 48),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _session = null;
                });
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Create New Session'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.surfaceColor,
                foregroundColor: AppTheme.textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
