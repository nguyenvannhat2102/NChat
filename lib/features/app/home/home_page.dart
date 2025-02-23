import 'package:chat/features/app/const/page_const.dart';
import 'package:chat/features/app/theme/style.dart';
import 'package:chat/features/chat/presentation/pages/chat_page.dart';
import 'package:chat/features/user/domain/entities/user_entity.dart';
import 'package:chat/features/user/presentation/cubit/get_single_user/cubit/get_single_user_cubit.dart';
import 'package:chat/features/user/presentation/cubit/user/cubit/user_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatefulWidget {
  final String uid;
  final int? index;
  const HomePage({super.key, required this.uid, this.index});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  int _currentTabIndex = 0;

  @override
  void initState() {
    BlocProvider.of<GetSingleUserCubit>(context).getSingleUser(uid: widget.uid);
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        BlocProvider.of<UserCubit>(context)
            .updateUser(user: UserEntity(uid: widget.uid, isOnline: true));
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.paused:
        BlocProvider.of<UserCubit>(context)
            .updateUser(user: UserEntity(uid: widget.uid, isOnline: false));
        break;
      case AppLifecycleState.hidden:
        // TODO: Handle this case.
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GetSingleUserCubit, GetSingleUserState>(
      builder: (context, state) {
        if (state is GetSingleUserLoaded) {
          final currentUser = state.singleUser;
          return Scaffold(
            appBar: AppBar(
              elevation: 4,
              shadowColor: Colors.black,
              title: const Text(
                "NChat",
                style: TextStyle(
                    fontSize: 25,
                    color: textColor,
                    fontWeight: FontWeight.w600),
              ),
              actions: [
                Row(
                  children: [
                    const SizedBox(
                      width: 10,
                    ),
                    PopupMenuButton<String>(
                      icon: const Icon(
                        Icons.more_vert,
                        color: blackColor,
                        size: 28,
                      ),
                      color: appBarColor,
                      iconSize: 28,
                      onSelected: (value) {},
                      itemBuilder: (context) => <PopupMenuEntry<String>>[
                        PopupMenuItem<String>(
                          value: "Settings",
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(
                                  context, PageConst.settingsPage,
                                  arguments: widget.uid);
                            },
                            child: const Text(
                              'Cài đặt',
                              style: TextStyle(color: textColor),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            floatingActionButton: switchFloatingActionButtonOnTabIndex(
              _currentTabIndex,
              currentUser,
            ),
            body: ChatPage(uid: widget.uid),
          );
        }
        return const Center(
          child: CircularProgressIndicator(
            color: tabColor,
          ),
        );
      },
    );
  }

  switchFloatingActionButtonOnTabIndex(int index, UserEntity currentUser) {
    switch (index) {
      case 0:
        {
          return FloatingActionButton(
            backgroundColor: tabColor,
            onPressed: () {
              Navigator.pushNamed(context, PageConst.contactUsersPage,
                  arguments: widget.uid);
            },
            child: const Icon(
              Icons.message,
              color: Colors.white,
            ),
          );
        }
      default:
        {
          return FloatingActionButton(
            backgroundColor: tabColor,
            onPressed: () {},
            child: const Icon(
              Icons.message,
              color: Colors.white,
            ),
          );
        }
    }
  }
}
