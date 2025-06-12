

import 'package:http/http.dart' as http;
import 'package:p_chat/models/registration_model.dart';
import 'export.dart';


class RegistrationApi {
  static Future<void> userRegistration(
      WidgetRef ref,  RegisterModel registerModel, BuildContext context) async {
    final response = await http
        .post(
          Uri.parse(registerEndpoint),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode(registerModel.toJson()),
        )
        .timeout(const Duration(seconds: 50));

    final Map<String, dynamic> responseData = json.decode(response.body);
    JsonEncoder encoder = const JsonEncoder.withIndent('  ');
    String prettyprint = encoder.convert(responseData);
    final message = responseData['message'];
        debugPrint('Response on registration $prettyprint');


    if (response.statusCode == 200 || response.statusCode == 201) {
      EndpointUpdateUI.updateUi(message, ref, context);
    } else {
      EndpointUpdateUI.updateUi(message, ref, context);
    }
  }
}


