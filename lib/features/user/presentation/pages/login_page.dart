import 'package:chat/features/app/const/app_const.dart';
import 'package:chat/features/app/home/home_page.dart';
import 'package:chat/features/app/theme/style.dart';
import 'package:chat/features/user/presentation/cubit/auth/cubit/auth_cubit.dart';
import 'package:chat/features/user/presentation/cubit/credential/cubit/credential_cubit.dart';
import 'package:chat/features/user/presentation/pages/initial_profile_submit_page.dart';
import 'package:chat/features/user/presentation/pages/otp_page.dart';
import 'package:country_pickers/country.dart';
import 'package:country_pickers/country_picker_dialog.dart';
import 'package:country_pickers/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _phoneController = TextEditingController();

  static Country _selectedFilteredDialogCountry =
      CountryPickerUtils.getCountryByPhoneCode("84");
  String _countryCode = _selectedFilteredDialogCountry.phoneCode;
  String _phoneNumber = "";

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CredentialCubit, CredentialState>(
      listener: (context, state) {
        if (state is CredentialSuccess) {
          BlocProvider.of<AuthCubit>(context).loggedIn();
        }
        if (state is CredentialFailure) {
          toast("gặp sự cố đăng nhập");
        }
      },
      builder: (context, state) {
        if (state is CredentialLoading) {
          return const Center(
            child: CircularProgressIndicator(color: tabColor),
          );
        }
        if (state is CredentialPhoneAuthSmsCodeReceived) {
          return const OtpPage();
        }
        if (state is CredentialPhoneAuthProfileInfo) {
          return InitialProfileSubmitPage(phoneNumber: _phoneNumber);
        }
        if (state is CredentialSuccess) {
          return BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              if (state is Authenticated) {
                return HomePage(uid: state.uid);
              }
              return _bodyWidget();
            },
          );
        }
        return _bodyWidget();
      },
    );
  }

  _bodyWidget() {
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 30),
        child: Column(
          children: [
            Column(
              children: [
                const SizedBox(
                  height: 40,
                ),
                const Center(
                  child: Text(
                    "xác minh số điện thoại",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: tabColor,
                    ),
                  ),
                ),
                const Text(
                  "ứng dụng sẽ gửi cho bạn tin nhắn SMS để xác minh số điện thoại của bạn. Nhập mã quốc gia và số điện thoại",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: tabColor),
                ),
                const SizedBox(
                  height: 30,
                ),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 2),
                  onTap: _openFilteredCountryPickerDialog,
                  title: _buildDialogItem(_selectedFilteredDialogCountry),
                ),
                Row(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            width: 1.50,
                            color: tabColor,
                          ),
                        ),
                      ),
                      width: 80,
                      height: 42,
                      alignment: Alignment.center,
                      child: Text(
                        _countryCode,
                        style: const TextStyle(
                          fontSize: 15,
                          color: textColor,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 8.0,
                    ),
                    Expanded(
                      child: Container(
                        height: 40,
                        margin: const EdgeInsets.only(top: 1.5),
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: tabColor, width: 1.5),
                          ),
                        ),
                        child: TextField(
                          style: const TextStyle(
                            color: textColor,
                          ),
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            hintText: "số điện thoại",
                            hintStyle: TextStyle(
                              color: textColor,
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            GestureDetector(
              onTap: () => _submitVerifyPhoneNumber(),
              child: Container(
                margin: const EdgeInsets.only(bottom: 20, top: 10),
                width: 120,
                height: 40,
                decoration: BoxDecoration(
                  color: tabColor,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: const Center(
                  child: Text(
                    "tiếp tục",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _openFilteredCountryPickerDialog() {
    showDialog(
      context: context,
      builder: (_) => Theme(
        data: Theme.of(context).copyWith(
          primaryColor: whiteColor,
        ),
        child: CountryPickerDialog(
          titlePadding: const EdgeInsets.all(8),
          searchCursorColor: blackColor,
          searchInputDecoration: const InputDecoration(
            hintText: "tìm kiếm",
            hintStyle: TextStyle(
              color: blackColor,
            ),
          ),
          isSearchable: true,
          title: const Text(
            "chọn mã số điện thoại",
            style: TextStyle(color: blackColor),
          ),
          onValuePicked: (value) {
            setState(() {
              _selectedFilteredDialogCountry = value;
              _countryCode = value.phoneCode;
            });
          },
          itemBuilder: _buildDialogItem,
        ),
      ),
    );
  }

  Widget _buildDialogItem(Country country) {
    return Container(
      height: 40,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
          border: Border(
        bottom: BorderSide(color: tabColor, width: 1.5),
      )),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          CountryPickerUtils.getDefaultFlagImage(country),
          Text(
            " +${country.phoneCode}",
            style: const TextStyle(fontSize: 15, color: textColor),
          ),
          Expanded(
            child: Text(
              " ${country.name}",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 15, color: textColor),
            ),
          ),
          const Spacer(),
          const Icon(
            Icons.arrow_drop_down,
            color: blackColor,
          )
        ],
      ),
    );
  }

  void _submitVerifyPhoneNumber() {
    if (_phoneController.text.isNotEmpty) {
      _phoneNumber = "+$_countryCode${_phoneController.text}";
      BlocProvider.of<CredentialCubit>(context).submitVerifyPhoneNumber(
        phoneNumber: _phoneNumber,
      );
    } else {
      toast("Nhập số điện thoại của bạn");
    }
  }
}
