import 'package:p_chat/models/verify_emailotp_model.dart';
import 'package:p_chat/screens/auth_screen/export.dart';
import 'package:p_chat/services/verify_emailotp_service.dart';
import 'package:pinput/pinput.dart';

class RegisterOtpView extends ConsumerStatefulWidget {
  const RegisterOtpView({Key? key}) : super(key: key);

  @override
  ConsumerState<RegisterOtpView> createState() => _RegisterOtpViewState();
}

class _RegisterOtpViewState extends ConsumerState<RegisterOtpView> {
  TextEditingController pinController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColor.colorBlueBlack,
        body:
            ListView(padding: EdgeInsets.symmetric(horizontal: 6.w), children: [
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
            child: AppText.boldText('Enter otp code sent to ', FontWeight.w500,
                color: AppColor.colorWhite,
                fontSize: FontSize.font18,
                maxLine: 3),
          ),
          SizedBox(height: 3.h),
          Center(
            child: Pinput(
              length: 3,
              showCursor: true,
              controller: pinController,
              defaultPinTheme: PinTheme(
                width: 15.w,
                height: 6.h,
                textStyle: const TextStyle(
                  fontSize: 20,
                  color: AppColor.colorWhite,
                ),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: AppColor.colorWhite)),
              ),
              onCompleted: (pin) {
                setState(() {
                  pinController.text = pin;
                });
              },
              onChanged: (value) {
                setState(() {
                  pinController.text = value;
                });
              },
            ),
          ),
          SizedBox(height: 6.h),
          materialButton(
            buttonBkColor: AppColor.colorOrange.withOpacity(0.8),
            width: 100.w,
            height: 7.h,
            onPres: () {
              final data = VerifyEmailOtpModel(otp: pinController.text);
              VerifyEmailOtpApi.verifyOtp(ref, data, context);
            },
            widget: AppText.boldText(
              'Verify',
              FontWeight.bold,
              fontSize: FontSize.font16,
              color: AppColor.colorWhite,
            ),
          )
        ]));
  }
}
