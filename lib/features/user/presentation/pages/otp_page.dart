import 'package:chat/features/app/theme/style.dart';
import 'package:chat/features/user/presentation/cubit/credential/cubit/credential_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_pin_code_fields/flutter_pin_code_fields.dart';

class OtpPage extends StatefulWidget {
  const OtpPage({super.key});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  late TextEditingController _otpController;
  @override
  void initState() {
    super.initState();
    _otpController = TextEditingController();
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Expanded(
              child: Column(
                children: [
                  const SizedBox(
                    height: 40,
                  ),
                  const Center(
                    child: Text(
                      "Xác minh OTP của bạn",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: tabColor,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      "Nhập OTP của bạn để Xác Minh vào ứng dụng (để bạn sẽ được chuyển sang các bước tiếp theo để hoàn thành)",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: textColor,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  _pinCodeWidget(),
                  const SizedBox(
                    height: 30,
                  ),
                  GestureDetector(
                    onTap: _submitSmsCode,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      width: 120,
                      height: 40,
                      decoration: BoxDecoration(
                        color: tabColor,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: const Center(
                        child: Text(
                          "Tiếp tục",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pinCodeWidget() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 50),
      child: Column(
        children: [
          PinCodeFields(
            controller: _otpController,
            length: 6,
            activeBorderColor: tabColor,
            obscureText: true,
            onComplete: (String value) {},
          ),
          const Text(
            "Nhập mã 6 chữ số của bạn",
            style: TextStyle(
              color: textColor,
            ),
          )
        ],
      ),
    );
  }

  void _submitSmsCode() {
    print("otpCode ${_otpController.text}");
    if (_otpController.text.isNotEmpty) {
      BlocProvider.of<CredentialCubit>(context)
          .submitSmsCode(smsCode: _otpController.text);
    }
  }
}
