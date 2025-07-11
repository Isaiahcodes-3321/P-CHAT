import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:p_chat/global_content/global_varable.dart';
import 'package:p_chat/global_content/internet_checks.dart';
import 'package:p_chat/global_content/snack_bar.dart';
import 'package:p_chat/models/login_model.dart';
import 'package:p_chat/screens/auth_screen/forgot_password/forgot_password_email.dart';
import 'package:p_chat/screens/auth_screen/register/registration.dart';
import 'package:p_chat/services/auth_services/login_service.dart';
import 'package:p_chat/srorage/pref_storage.dart';
import 'export.dart';

class LoginView extends ConsumerStatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.colorBlueBlack,
      body: ListView(
        children: [
          SizedBox(height: 17.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppText.boldText('P - ', FontWeight.bold,
                  color: AppColor.colorWhite, fontSize: FontSize.font50),
              AppText.boldText('CHAT', FontWeight.bold,
                  color: AppColor.colorOrange, fontSize: FontSize.font50),
            ],
          ),
          Center(
            child: AppText.boldText(
                'Enter email and password to continue', FontWeight.w500,
                color: AppColor.colorWhite,
                fontSize: FontSize.font18,
                maxLine: 3),
          ),
          SizedBox(height: 5.h),
          const LoginInputs(),
          SizedBox(height: 3.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppText.boldText(
                'Dont have an account? ',
                FontWeight.bold,
                color: AppColor.colorWhite,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pushReplacement<void, void>(
                    context,
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) => const RegisterView(),
                    ),
                  );
                },
                child: AppText.boldText(
                  'Register',
                  FontWeight.bold,
                  color: AppColor.colorOrange,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.5.h),
          Center(
            child: GestureDetector(
              onTap: () {
                Navigator.push<void>(
                  context,
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) =>
                        const ForgotPasswordView(),
                  ),
                );
              },
              child: Text(
                'Forgot password ?',
                style: TextStyle(
                    fontSize: FontSize.font16,
                    fontFamily: AppText.familyFont,
                    color: AppColor.colorWhite,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                    decorationColor: AppColor.colorWhite,
                    decorationThickness: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LoginInputs extends ConsumerStatefulWidget {
  const LoginInputs({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginInputs> createState() => _LoginInputsState();
}

class _LoginInputsState extends ConsumerState<LoginInputs> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadLoginCredentials();
  }

  String? getUserPass;
  String? getUserEmail;
  bool? isSaveRememberPassword;

  bool _passwordVisible = true;
  bool _rememberPassword = false;

  Future<void> _loadLoginCredentials() async {
    getUserEmail = await Pref.getStringValue(rememberEmailKey);
    getUserPass = await Pref.getStringValue(rememberPasswordKey);
    isSaveRememberPassword =
        await Pref.getBoolValue(rememberLoginCredentialBoolValueKey);

    setState(() {
      _emailController.text = getUserEmail ?? '';
      _passwordController.text = getUserPass ?? '';

      _rememberPassword = isSaveRememberPassword ?? false;
      // _rememberPassword = getUserEmail != null && getUserPass != null ;
    });
  }

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 3.w),
      padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 3.w),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: AppColor.colorLightGray.withOpacity(0.5)),
      child: Column(
        children: [
          TextInput(
            borderColor: AppColor.colorLightGray,
            hintText: 'Enter email address',
            textInput: _emailController,
            inputColor: AppColor.colorWhite,
            textType: TextInputType.emailAddress,
            validate: (p0) {
              return null;
            },
          ),
          SizedBox(height: 2.h),
          TextInputPassword(
            borderColor: AppColor.colorLightGray,
            hintText: 'Enter password ',
            textInput: _passwordController,
            inputColor: AppColor.colorWhite,
            textType: TextInputType.text,
            onPress: () {
              setState(() {
                _passwordVisible = !_passwordVisible;
              });
            },
            isVisible: _passwordVisible,
            icon: Icon(
              _passwordVisible ? Icons.visibility : Icons.visibility_off,
            ),
            fieldFocusNode: _passwordFocusNode,
            validate: (p0) {
              return null;
            },
          ),
          Row(
            children: [
              Checkbox(
                value: _rememberPassword,
                onChanged: (bool? newValue) {
                  setState(() {
                    _rememberPassword = newValue!;
                    ref
                        .read(LoginApi.isRememberPasswordActivated.notifier)
                        .state = _rememberPassword;

                    debugPrint(' remember value its $_rememberPassword');
                  });
                },
                checkColor: AppColor.colorWhite,
                fillColor: MaterialStateProperty.resolveWith<Color>(
                  (Set<MaterialState> states) {
                    if (states.contains(MaterialState.selected)) {
                      return AppColor.colorOrange;
                    }
                    return AppColor.colorWhite;
                  },
                ),
                activeColor: AppColor.colorOrange,
              ),
              AppText.boldText(
                'Remember password',
                FontWeight.bold,
                fontSize: FontSize.font16,
                color: AppColor.colorWhite,
              ),
            ],
          ),
          SizedBox(height: 1.h),
          materialButton(
            buttonBkColor: AppColor.colorOrange.withOpacity(0.8),
            width: 100.w,
            height: 7.h,
            onPres: () {
              if (_emailController.text.isEmpty ||
                  _passwordController.text.isEmpty) {
                SnackBarView.showSnackBar(context, "All input are required");
              } else {
                InternetChecks.loginInternetCheck(ref, context);
                Future.delayed(const Duration(seconds: 1), () async {
                  if (ref.watch(isUserConnected)) {
                    ref.read(loadingAnimationSpinkit.notifier).state = true;
                    final data = LoginModel(
                        email: _emailController.text,
                        password: _passwordController.text);
                    ref
                        .read(LoginApi.isRememberPasswordActivated.notifier)
                        .state = _rememberPassword;
                    LoginApi.userLogin(ref, data, context);
                  }
                });
              }
            },
            widget: ref.watch(loadingAnimationSpinkit)
                ? const SpinKitCircle(
                    color: AppColor.colorWhite,
                  )
                : AppText.boldText(
                    'Login',
                    FontWeight.bold,
                    fontSize: FontSize.font16,
                    color: AppColor.colorWhite,
                  ),
          )
        ],
      ),
    );
  }
}
