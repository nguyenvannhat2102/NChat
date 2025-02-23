import 'package:chat/features/app/const/page_const.dart';
import 'package:chat/features/app/global/widgets/dialog_widget.dart';
import 'package:chat/features/app/global/widgets/profile_widget.dart';
import 'package:chat/features/app/theme/style.dart';
import 'package:chat/features/user/presentation/cubit/auth/cubit/auth_cubit.dart';
import 'package:chat/features/user/presentation/cubit/get_single_user/cubit/get_single_user_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsPage extends StatefulWidget {
  final String uid;
  const SettingsPage({super.key, required this.uid});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  void initState() {
    BlocProvider.of<GetSingleUserCubit>(context).getSingleUser(uid: widget.uid);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: blackColor),
        title: const Text(
          "cài đặt",
          style: TextStyle(color: textColor),
        ),
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: BlocBuilder<GetSingleUserCubit, GetSingleUserState>(
              builder: (context, state) {
                if (state is GetSingleUserLoaded) {
                  final user = state.singleUser;
                  return Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            PageConst.editProfilePage,
                            arguments: user,
                          );
                        },
                        child: SizedBox(
                          height: 65,
                          width: 65,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(32.5),
                            child: profileWidget(imageUrl: user.profileUrl),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${user.username}",
                              style: const TextStyle(
                                fontSize: 16,
                                color: textColor,
                              ),
                            ),
                            Text(
                              "${user.status}",
                              style: const TextStyle(color: textColor),
                            )
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.qr_code,
                        color: tabColor,
                      )
                    ],
                  );
                }
                return Row(
                  children: [
                    GestureDetector(
                      onTap: () {},
                      child: SizedBox(
                        height: 65,
                        width: 65,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(32.5),
                          child: profileWidget(),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "name",
                            style: TextStyle(
                              fontSize: 16,
                              color: textColor,
                            ),
                          ),
                          Text(
                            "...",
                            style: TextStyle(color: textColor),
                          )
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.qr_code,
                      color: tabColor,
                    )
                  ],
                );
              },
            ),
          ),
          const SizedBox(
            height: 2,
          ),
          Container(
            width: double.infinity,
            height: 0.5,
            color: greyColor,
          ),
          const SizedBox(
            height: 10,
          ),
          _settingsItemWidget(
            title: "Tài Khoản",
            description: "bảo mật ứng dụng, thay đổi số điện thoại",
            iconData: Icons.key,
            onTap: () {},
          ),
          _settingsItemWidget(
            title: "Riêng tư",
            description: "chặn liên lạc, tin nhắn biến mất",
            iconData: Icons.lock,
            onTap: () {},
          ),
          _settingsItemWidget(
            title: "Tin Nhắn",
            description: "chủ đề, lịch sử tin nhắn",
            iconData: Icons.message,
            onTap: () {},
          ),
          _settingsItemWidget(
            title: "Đăng Xuất",
            description: "bảo mật ứng dụng, thay đổi số điện thoại",
            iconData: Icons.exit_to_app,
            onTap: () {
              displayAlertDialog(
                context,
                onTap: () {
                  BlocProvider.of<AuthCubit>(context).loggedOut();
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    PageConst.welcomePage,
                    (route) => false,
                  );
                },
                confirmTitle: "đăng xuất",
                content: "bạn có chắc muốn đăng xuất không ?",
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _settingsItemWidget(
      {String? title,
      String? description,
      IconData? iconData,
      VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          SizedBox(
            width: 100,
            height: 100,
            child: Icon(
              iconData,
              color: greyColor,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "$title",
                  style: const TextStyle(
                    fontSize: 17,
                    color: textColor,
                  ),
                ),
                const SizedBox(
                  height: 3,
                ),
                Text(
                  "$description",
                  style: const TextStyle(
                    color: blackColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
