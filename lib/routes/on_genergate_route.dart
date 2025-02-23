import 'package:chat/features/app/const/page_const.dart';
import 'package:chat/features/app/home/contacs_page.dart';
import 'package:chat/features/chat/domain/entities/message_entity.dart';
import 'package:chat/features/chat/presentation/pages/single_chat_page.dart';
import 'package:chat/features/app/settings/setting_page.dart';
import 'package:chat/features/user/domain/entities/user_entity.dart';
import 'package:chat/features/user/presentation/pages/edit_profile_page.dart';

import 'package:flutter/material.dart';

class OnGenerateRouter {
  static Route<dynamic>? route(RouteSettings settings) {
    final args = settings.arguments;
    final name = settings.name;
    switch (name) {
      case PageConst.contactUsersPage:
        {
          if (args is String) {
            return materialPageRoute(ContactsPage(
              uid: args,
            ));
          } else {
            return materialPageRoute(const ErrorPage());
          }
        }
      case PageConst.settingsPage:
        {
          if (args is String) {
            return materialPageRoute(SettingsPage(uid: args));
          } else {
            return materialPageRoute(const ErrorPage());
          }
        }
      case PageConst.editProfilePage:
        {
          if (args is UserEntity) {
            return materialPageRoute(EditProfilePage(currentUser: args));
          } else {
            return materialPageRoute(const ErrorPage());
          }
        }
      case PageConst.singleChatPage:
        {
          if (args is MessageEntity) {
            return materialPageRoute(SingleChatPage(message: args));
          } else {
            return materialPageRoute(const ErrorPage());
          }
        }
    }
    return null;
  }
}

dynamic materialPageRoute(Widget widget) {
  return MaterialPageRoute(
    builder: (context) => widget,
  );
}

class ErrorPage extends StatelessWidget {
  const ErrorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lỗi"),
      ),
      body: const Center(
        child: Text("Lỗi"),
      ),
    );
  }
}
