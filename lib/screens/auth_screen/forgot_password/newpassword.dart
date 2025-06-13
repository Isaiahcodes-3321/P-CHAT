import 'package:p_chat/models/reset_password_model.dart';
import 'package:p_chat/screens/auth_screen/export.dart';
import 'package:p_chat/services/reset_password_service.dart';

class NewPasswordView extends ConsumerStatefulWidget {
  const NewPasswordView({Key? key}) : super(key: key);

  @override
  ConsumerState<NewPasswordView> createState() => _NewPasswordViewState();
}

class _NewPasswordViewState extends ConsumerState<NewPasswordView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.colorBlueBlack,
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 4.w),
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
                'Enter otp sent to your mail and new password ',
                FontWeight.w500,
                color: AppColor.colorWhite,
                fontSize: FontSize.font18,
                maxLine: 3),
          ),
          SizedBox(height: 5.h),
          const RegisterInputs(),
          SizedBox(height: 3.h),
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

  final TextEditingController _emailOtpController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FocusNode _emailOtpFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  @override
  void dispose() {
    _emailOtpController.dispose();
    _passwordController.dispose();
    _emailOtpFocusNode.dispose();
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
            hintText: 'Enter your otp',
            textInput: _emailOtpController,
            inputColor: AppColor.colorWhite,
            textType: TextInputType.text,
            validate: (p0) {
              return null;
            },
          ),
          SizedBox(height: 2.h),
          SizedBox(height: 2.h),
          TextInputPassword(
            borderColor: AppColor.colorLightGray,
            hintText: 'Enter new password ',
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
              final data = ResetPasswordModel(
                emailOtp: _emailOtpController.text,
                confirmPassword: _passwordController.text,
              );
              ResetPasswordApi.resetPassword(ref, data, context);
            },
            widget: AppText.boldText(
              'Continue',
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
