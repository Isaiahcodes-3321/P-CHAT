import 'package:http/http.dart' as http;

import '../export.dart';
import 'dart:async';

class DeleteChatsServices {
  static Future<void> deleteChat(
      WidgetRef ref, BuildContext context, String docId) async {
    String token = await Pref.getStringValue(tokenKey);
    String yourToken = token.trim();
    debugPrint('Deleting pdf now');
    final response = await http.delete(
      Uri.parse(deleteEndpoint + docId),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $yourToken',
      },
    );

    final Map<String, dynamic> responseData = json.decode(response.body);
    JsonEncoder encoder = const JsonEncoder.withIndent('  ');
    String prettyprint = encoder.convert(responseData);
    String message;
    if (responseData.containsKey('detail') &&
        responseData['detail'] is Map &&
        responseData['detail'].containsKey('message')) {
      message = responseData['detail']['message'];
    } else if (responseData.containsKey('message')) {
      message = responseData['message'];
    } else {
      message = 'Unknown error occurred';
    }
    debugPrint('Response on resend email otp $prettyprint');

    if (response.statusCode == 200 || response.statusCode == 201) {
      ref.read(ProviderUserDetails.showHistorySidebar.notifier).state = false;
      EndpointUpdateUI.updateUi(message, ref, context);
      Navigator.pushReplacement<void, void>(
        context,
        MaterialPageRoute<void>(
          builder: (BuildContext context) => const ChatView(),
        ),
      );
    } else {
      EndpointUpdateUI.updateUi(message, ref, context);
    }
  }
}
