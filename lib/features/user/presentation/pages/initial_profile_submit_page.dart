import 'dart:io';
import 'package:chat/features/user/domain/entities/user_entity.dart';
import 'package:chat/features/user/presentation/cubit/credential/cubit/credential_cubit.dart';
import 'package:chat/storage/storage_provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:chat/features/app/const/app_const.dart';
import 'package:chat/features/app/global/widgets/profile_widget.dart';
import 'package:chat/features/app/theme/style.dart';
import 'package:flutter/material.dart';

class InitialProfileSubmitPage extends StatefulWidget {
  final String phoneNumber;
  const InitialProfileSubmitPage({super.key, required this.phoneNumber});

  @override
  State<InitialProfileSubmitPage> createState() =>
      _InitialProfileSubmitPageState();
}

class _InitialProfileSubmitPageState extends State<InitialProfileSubmitPage> {
  final TextEditingController _usernameController = TextEditingController();
  File? _image;
  bool _isProfileUpdating = false;

  Future selectImage() async {
    try {
      // ignore: invalid_use_of_visible_for_testing_member
      final pickedFile = await ImagePicker.platform
          .getImageFromSource(source: ImageSource.gallery);

      setState(() {
        if (pickedFile != null) {
          _image = File(pickedFile.path);
        } else {
          print("no image has been selected");
        }
      });
    } catch (e) {
      toast("some error occured $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 30),
        child: Column(
          children: [
            const SizedBox(
              height: 30,
            ),
            const Center(
              child: Text(
                "Thông tin hồ sơ",
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold, color: tabColor),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            const Text(
              "Vui lòng cung cấp tên của bạn và ảnh hồ sơ tùy chọn",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: textColor),
            ),
            const SizedBox(
              height: 30,
            ),
            GestureDetector(
              onTap: selectImage,
              child: SizedBox(
                width: 50,
                height: 50,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: profileWidget(image: _image),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              height: 40,
              margin: const EdgeInsets.only(top: 1.5),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: tabColor,
                    width: 1.5,
                  ),
                ),
              ),
              child: TextField(
                style: const TextStyle(
                  fontSize: 15,
                  color: textColor,
                ),
                controller: _usernameController,
                decoration: const InputDecoration(
                  hintText: "Username",
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            GestureDetector(
              onTap: () async => await submitProfileInfo(),
              child: Container(
                width: 150,
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
            )
          ],
        ),
      ),
    );
  }

  Future<void> submitProfileInfo() async {
    if (_image != null) {
      await StorageProviderRemoteDataSource.uploadProfileImage(
        file: _image!,
        onComplete: (onProfileUpdateComplete) {
          setState(() {
            _isProfileUpdating = onProfileUpdateComplete;
          });
        },
      ).then(
        (profileImageUrl) {
          _profileInfo(profileUrl: profileImageUrl);
        },
      );
    } else {
      _profileInfo(profileUrl: "");
    }
  }

  void _profileInfo({String? profileUrl}) {
    if (_usernameController.text.isNotEmpty) {
      BlocProvider.of<CredentialCubit>(context).submitProfileInfo(
          user: UserEntity(
        email: "",
        username: _usernameController.text,
        phoneNumber: widget.phoneNumber,
        status: "Xin chào! Tôi đang sử dụng NChat",
        isOnline: false,
        profileUrl: profileUrl,
      ));
    }
  }
}
