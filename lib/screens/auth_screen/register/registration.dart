import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:p_chat/global_content/internet_checks.dart';
import 'package:p_chat/global_content/snack_bar.dart';
import 'package:p_chat/models/registration_model.dart';
import 'package:p_chat/screens/auth_screen/login_view.dart';
import 'package:p_chat/services/registration_service.dart';

import '../export.dart';

class RegisterView extends ConsumerStatefulWidget {
  const RegisterView({Key? key}) : super(key: key);

  @override
  ConsumerState<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends ConsumerState<RegisterView> {
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
            child: AppText.boldText('Fill in your details', FontWeight.w500,
                color: AppColor.colorWhite,
                fontSize: FontSize.font18,
                maxLine: 3),
          ),
          SizedBox(height: 5.h),
          const RegisterInputs(),
          SizedBox(height: 3.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppText.boldText(
                'Already have an account? ',
                FontWeight.bold,
                color: AppColor.colorWhite,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pushReplacement<void, void>(
                    context,
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) => const LoginView(),
                    ),
                  );
                },
                child: AppText.boldText(
                  'Login',
                  FontWeight.bold,
                  color: AppColor.colorOrange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class RegisterInputs extends ConsumerStatefulWidget {
  const RegisterInputs({Key? key}) : super(key: key);

  @override
  ConsumerState<RegisterInputs> createState() => _RegisterInputsState();
}

class _RegisterInputsState extends ConsumerState<RegisterInputs> {
  bool _passwordVisible = true;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();

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
            hintText: 'Enter your full-name',
            textInput: _fullNameController,
            inputColor: AppColor.colorWhite,
            textType: TextInputType.emailAddress,
            validate: (p0) {
              return null;
            },
          ),
          SizedBox(height: 2.h),
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
          SizedBox(height: 2.h),
          materialButton(
            buttonBkColor: AppColor.colorOrange.withOpacity(0.8),
            width: 100.w,
            height: 7.h,
            onPres: () {
              if (_fullNameController.text.isEmpty ||
                  _emailController.text.isEmpty ||
                  _passwordController.text.isEmpty) {
                SnackBarView.showSnackBar(context, "All input are required");
              } else {
                if (_passwordController.text.length < 8) {
                  SnackBarView.showSnackBar(
                      context, "Password length must be 8 and above");
                } else {
                  InternetChecks.loginInternetCheck(ref, context);
                  Future.delayed(const Duration(seconds: 1), () async {
                    if (ref.watch(isUserConnected)) {
                      ref.read(loadingAnimationSpinkit.notifier).state = true;
                      final data = RegisterModel(
                          fullName: _fullNameController.text,
                          email: _emailController.text,
                          password: _passwordController.text);
                      RegistrationApi.userRegistration(ref, data, context);
                    }
                  });
                }
              }
            },
            widget: ref.watch(loadingAnimationSpinkit)
                ? const SpinKitCircle(
                    color: AppColor.colorWhite,
                  )
                : AppText.boldText(
                    'Register',
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
