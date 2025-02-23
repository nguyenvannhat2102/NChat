import 'package:chat/features/app/const/page_const.dart';
import 'package:chat/features/app/global/widgets/profile_widget.dart';
import 'package:chat/features/app/theme/style.dart';
import 'package:chat/features/chat/domain/entities/chat_entity.dart';
import 'package:chat/features/chat/domain/entities/message_entity.dart';
import 'package:chat/features/chat/presentation/cubit/chat/chat_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class ChatPage extends StatefulWidget {
  final String uid;
  const ChatPage({super.key, required this.uid});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  @override
  void initState() {
    BlocProvider.of<ChatCubit>(context)
        .getMyChat(chat: ChatEntity(senderUid: widget.uid));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<ChatCubit, ChatState>(
        builder: (context, state) {
          if (state is ChatLoaded) {
            final myChat = state.chatContacts;
            if (myChat.isEmpty) {
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
                      "Chưa có cuộc trò chuyện nào",
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
              itemCount: myChat.length,
              itemBuilder: (context, index) {
                final chat = myChat[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      PageConst.singleChatPage,
                      arguments: MessageEntity(
                        senderUid: chat.senderUid,
                        recipientUid: chat.recipientUid,
                        senderName: chat.senderName,
                        recipientName: chat.recipientName,
                        senderProfile: chat.senderProfile,
                        recipientProfile: chat.recipientProfile,
                        uid: widget.uid,
                      ),
                    );
                  },
                  child: ListTile(
                    leading: SizedBox(
                      width: 50,
                      height: 50,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(25),
                        child: profileWidget(imageUrl: chat.recipientProfile),
                      ),
                    ),
                    title: Text(
                      "${chat.recipientName}",
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                        color: textColor,
                      ),
                    ),
                    subtitle: Text(
                      "${chat.recentTextMessage}",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: greyColor,
                        fontSize: 15,
                      ),
                    ),
                    trailing: Text(
                      DateFormat.jm().format(chat.createdAt!.toDate()),
                      style: const TextStyle(color: greyColor, fontSize: 13),
                    ),
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
