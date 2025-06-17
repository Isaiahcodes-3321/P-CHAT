import 'package:http/http.dart' as http;

import 'export.dart';
import 'dart:async';

class LoginApi {
  static final isRememberPasswordActivated = StateProvider((ref) => false);

  static Future<void> userLogin(
      WidgetRef ref, LoginModel loginModel, BuildContext context) async {
    try {
      debugPrint('Login User Now');
      final response = await http
          .post(
            Uri.parse(loginEndpoint),
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode(loginModel.toJson()),
          )
          .timeout(const Duration(seconds: 50));

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

      debugPrint('Response on login $prettyprint');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final tokenData = responseData['data']['token'] as Map<String, dynamic>;
        final userData = responseData['data']['user'] as Map<String, dynamic>;
        String userId = userData['id'] as String;
        String userName = userData['fullname'] as String;

        String accessToken = tokenData['access_token'] as String;
        String refreshToken = tokenData['refresh_token'] as String;

        // debugPrint(' Access token its $accessToken');
        debugPrint('User Name its $userName');
        Pref.setStringValue(tokenKey, accessToken);
        Pref.setStringValue(refreshTokenKey, refreshToken);
        Pref.setStringValue(userIdKey, userId);
        Pref.setStringValue(userNameKey, userName);

        if (ref.watch(isRememberPasswordActivated)) {
          Pref.setStringValue(rememberPasswordKey, loginModel.password);
          Pref.setStringValue(rememberEmailKey, loginModel.email);
          Pref.setBoolValue(rememberLoginCredentialBoolValueKey, true);
        } else {
          Pref.setStringValue(rememberPasswordKey, '');
          Pref.setStringValue(rememberEmailKey, '');
          Pref.setBoolValue(rememberLoginCredentialBoolValueKey, false);
        }

        Navigator.pushReplacement<void, void>(
          context,
          MaterialPageRoute<void>(
            builder: (BuildContext context) => const ChatView(),
          ),
        );
        ref.read(loadingAnimationSpinkit.notifier).state = false;
        // EndpointUpdateUI.updateUi(message, ref, context);
      } else {
        debugPrint('Failed ${response.statusCode}');
        EndpointUpdateUI.updateUi(message, ref, context);
        debugPrint('Failed ${response.statusCode}');
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

class EndpointUpdateUI {
  static updateUi(String message, WidgetRef ref, BuildContext context) {
    ref.read(loadingAnimationSpinkit.notifier).state = false;
    SnackBarView.showSnackBar(context, message);
  }
}
