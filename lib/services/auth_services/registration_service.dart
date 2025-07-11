import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:p_chat/models/registration_model.dart';
import 'package:p_chat/screens/auth_screen/register/register_otp.dart';
import '../export.dart';

class RegistrationApi {
  static Future<void> userRegistration(
      WidgetRef ref, RegisterModel registerModel, BuildContext context) async {
    debugPrint('Registering user');
    try {
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
      String message;
      if (responseData.containsKey('detail') &&
          responseData['detail'] is Map<String, dynamic> &&
          responseData['detail'].containsKey('message')) {
        message = responseData['detail']['message'] as String;
      } else if (responseData.containsKey('message')) {
        message = responseData['message'] as String;
      } else {
        message = 'An unknown error occurred';
      }
      debugPrint(
          'Response on registration $prettyprint ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        Navigator.push<void>(
          context,
          MaterialPageRoute<void>(
            builder: (BuildContext context) => const RegisterOtpView(),
          ),
        );
        ref.read(loadingAnimationSpinkit.notifier).state = false;
        // EndpointUpdateUI.updateUi(message, ref, context);
      } else {
        EndpointUpdateUI.updateUi(message, ref, context);
      }
    } on TimeoutException catch (_) {
      debugPrint('The request timed out after 50 seconds $_');
      EndpointUpdateUI.updateUi(
          'Time-out please check your internet connection', ref, context);
    } on HandshakeException catch (error) {
      debugPrint('error its ${error.type} error $error');
      EndpointUpdateUI.updateUi('Internet connection not stable', ref, context);
    } on SocketException catch (_) {
      EndpointUpdateUI.updateUi('Internet connection its needed', ref, context);
    } catch (e) {
      debugPrint('Unexpected error on try : $e');
      EndpointUpdateUI.updateUi('$e', ref, context);
    }
  }
}


// v4y53r+20xhhultteymg@guerrillamail.com
// @Vuvu12345

//shellisaiah2020@gmail.com
// @Pchat123