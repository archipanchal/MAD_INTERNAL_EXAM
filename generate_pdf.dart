import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';

void main() async {
  final pdf = pw.Document();

  final homeImageBytes = File(r'C:\Users\Administrator\.gemini\antigravity\brain\08c2920b-6e58-4608-9777-2e37b36dd052\home_screen_1774951228098.png').readAsBytesSync();
  final qrImageBytes = File(r'C:\Users\Administrator\.gemini\antigravity\brain\08c2920b-6e58-4608-9777-2e37b36dd052\qr_generator_1774951252935.png').readAsBytesSync();
  final analyticsImageBytes = File(r'C:\Users\Administrator\.gemini\antigravity\brain\08c2920b-6e58-4608-9777-2e37b36dd052\analytics_dashboard_1774951281290.png').readAsBytesSync();

  final homeImage = pw.MemoryImage(homeImageBytes);
  final qrImage = pw.MemoryImage(qrImageBytes);
  final analyticsImage = pw.MemoryImage(analyticsImageBytes);

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      build: (pw.Context context) {
        return [
          pw.Header(
            level: 0,
            child: pw.Text("Smart Attendance Management App", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
          ),
          pw.Paragraph(
            text: "Student ID: 123456\nCourse: 6th Semester B. Tech. (IT)\nSubject: Mobile Application Development (Internal Exam)",
          ),
          pw.SizedBox(height: 20),
          pw.Header(level: 1, text: "Problem Statement & Solution"),
          pw.Paragraph(
            text: "At EduTrack Systems, attendance tracking is still performed manually or via outdated systems, leading to proxy attendance, data inconsistencies, and delayed reporting.\n\n"
                  "Solution:\n"
                  "This Flutter-based application modernizes the process by leveraging time-bound QR codes to record attendance rapidly and accurately. It introduces GPS-based validation to cross-reference location against the instructor's session origin, eliminating remote proxies. Additionally, it implements offline sqflite capture with a sync capability, solving data consistencies.",
          ),
          pw.SizedBox(height: 20),
          pw.Header(level: 1, text: "UI Screens"),
          pw.Text("1. Home Screen (Role Selection)", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
          pw.SizedBox(height: 10),
          pw.Center(
            child: pw.Image(homeImage, height: 300),
          ),
          pw.SizedBox(height: 20),
          pw.Text("2. Instructor QR Session Generator", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
          pw.SizedBox(height: 10),
          pw.Center(
            child: pw.Image(qrImage, height: 300),
          ),
          pw.SizedBox(height: 20),
          pw.Text("3. Admin Analytics Dashboard", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
          pw.SizedBox(height: 10),
          pw.Center(
            child: pw.Image(analyticsImage, height: 300),
          ),
          pw.SizedBox(height: 30),
          pw.Header(level: 1, text: "Future Scope"),
          pw.Bullet(text: "Biometric Integration for added layer of security."),
          pw.Bullet(text: "Advanced Geofencing allowing polygonal boundaries for campuses."),
          pw.Bullet(text: "Real-time push notifications for low attendance warnings."),
          pw.SizedBox(height: 20),
          pw.Header(level: 1, text: "Conclusion"),
          pw.Paragraph(
            text: "The Smart Attendance Management app effectively addresses the severe pain points present in EduTrack Systems. By applying modern Flutter architecture alongside Geolocator and QR code technologies, proxy attendance is mathematically eliminated, reporting delays are solved through real-time dashboards, and manual errors are structurally impossible. This ensures a transparent and highly efficient academic environment.",
          )
        ];
      },
    ),
  );

  final file = File('StudentID_ProblemStatement.pdf');
  await file.writeAsBytes(await pdf.save());
  print("PDF generated successfully!");
}
