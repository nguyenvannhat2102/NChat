import 'package:chat/features/app/const/page_const.dart';
import 'package:chat/features/app/global/widgets/profile_widget.dart';
import 'package:chat/features/app/theme/style.dart';
import 'package:chat/features/chat/domain/entities/message_entity.dart';
import 'package:chat/features/user/presentation/cubit/get_single_user/cubit/get_single_user_cubit.dart';
import 'package:chat/features/user/presentation/cubit/user/cubit/user_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ContactsPage extends StatefulWidget {
  final String uid;

  const ContactsPage({super.key, required this.uid});

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  @override
  void initState() {
    BlocProvider.of<UserCubit>(context).getAllUsers();
    BlocProvider.of<GetSingleUserCubit>(context).getSingleUser(uid: widget.uid);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "chọn người liên hệ",
          style: TextStyle(
            color: textColor,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Colors.black, // Đổi màu icon nút back
        ),
      ),
      body: BlocBuilder<GetSingleUserCubit, GetSingleUserState>(
        builder: (context, state) {
          if (state is GetSingleUserLoaded) {
            final currentUser = state.singleUser;
            return BlocBuilder<UserCubit, UserState>(
              builder: (context, state) {
                if (state is UserLoaded) {
                  final contacts = state.users
                      .where((user) => user.uid != widget.uid)
                      .toList();
                  if (contacts.isEmpty) {
                    return Center(
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 50,
                          ),
                          Image.asset(
                            "assets/images/no.png",
                            width: 150,
                            height: 150,
                          ),
                          const Text(
                            "Chưa có người liên lạc nào",
                            style: TextStyle(
                              color: textColor,
                              fontSize: 20,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                      itemCount: contacts.length,
                      itemBuilder: (context, index) {
                        final contact = contacts[index];
                        return ListTile(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              PageConst.singleChatPage,
                              arguments: MessageEntity(
                                senderUid: currentUser.uid,
                                recipientUid: contact.uid,
                                senderName: currentUser.username,
                                recipientName: contact.username,
                                senderProfile: currentUser.profileUrl,
                                recipientProfile: contact.profileUrl,
                                uid: widget.uid,
                              ),
                            );
                          },
                          leading: SizedBox(
                            width: 50,
                            height: 50,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(25),
                              child: profileWidget(
                                imageUrl: contact.profileUrl,
                              ),
                            ),
                          ),
                          title: Text("${contact.username}"),
                          subtitle: Text("${contact.status}"),
                        );
                      });
                }
                return const Center(
                  child: CircularProgressIndicator(
                    color: tabColor,
                  ),
                );
              },
            );
          }
          return const Center(
            child: CircularProgressIndicator(
              color: tabColor,
            ),
          );
        },
      ),
    );
  }
}
