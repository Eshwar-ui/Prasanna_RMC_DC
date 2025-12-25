import 'package:url_launcher/url_launcher.dart';

class WhatsAppService {
  static final WhatsAppService instance = WhatsAppService._init();
  WhatsAppService._init();

  Future<bool> sendPDF(
    String phoneNumber,
    String pdfPath,
    String message,
  ) async {
    try {
      // Remove any non-numeric characters from phone number
      final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');

      // Format message
      final encodedMessage = Uri.encodeComponent(message);

      // Note: WhatsApp Web API doesn't support file sending directly
      // This opens WhatsApp chat. User needs to manually attach the PDF
      final whatsappUrl = 'https://wa.me/$cleanNumber?text=$encodedMessage';

      final uri = Uri.parse(whatsappUrl);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);

        // Optionally, you can show the PDF location to user
        print('PDF saved at: $pdfPath');
        print('Please attach this file manually in WhatsApp');

        return true;
      }
      return false;
    } catch (e) {
      print('Error sending to WhatsApp: $e');
      return false;
    }
  }

  Future<bool> sendMessage(String phoneNumber, String message) async {
    try {
      final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
      final encodedMessage = Uri.encodeComponent(message);
      final whatsappUrl = 'https://wa.me/$cleanNumber?text=$encodedMessage';

      final uri = Uri.parse(whatsappUrl);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return true;
      }
      return false;
    } catch (e) {
      print('Error sending WhatsApp message: $e');
      return false;
    }
  }

  String formatChallanMessage(String dcNo, String date, String customerName) {
    return '''
Hello,

Your Delivery Challan has been generated.

DC No: $dcNo
Date: $date
Customer: $customerName

Thank you for your business!
- Prasanna RMC
''';
  }
}
