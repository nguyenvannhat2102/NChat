import 'dart:io';
import 'package:chat/features/app/global/widgets/show_image_picker_widget.dart';
import 'package:chat/features/chat/presentation/widgets/chat_ulits.dart';
import 'package:chat/features/user/presentation/cubit/get_single_user/cubit/get_single_user_cubit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:swipe_to/swipe_to.dart';
import 'package:chat/features/app/const/app_const.dart';
import 'package:chat/features/app/const/message_type_const.dart';
import 'package:chat/features/app/global/widgets/dialog_widget.dart';
import 'package:chat/features/app/theme/style.dart';
import 'package:chat/features/chat/domain/entities/message_entity.dart';
import 'package:chat/features/chat/domain/entities/message_reply_entity.dart';
import 'package:chat/features/chat/presentation/cubit/message/message_cubit.dart';
import 'package:chat/features/chat/presentation/widgets/message_widgets/message_replay_preview_widget.dart';
import 'package:chat/features/chat/presentation/widgets/message_widgets/message_replay_type_widget.dart';
import 'package:chat/features/chat/presentation/widgets/message_widgets/message_type_widget.dart';
import 'package:chat/storage/storage_provider.dart';

class SingleChatPage extends StatefulWidget {
  final MessageEntity message;
  const SingleChatPage({super.key, required this.message});

  @override
  State<SingleChatPage> createState() => _SingleChatPageState();
}

class _SingleChatPageState extends State<SingleChatPage> {
  bool isShowEmojiKeyboard = false;
  FocusNode focusNode = FocusNode();

  void _hideEmojiContainer() {
    setState(() {
      isShowEmojiKeyboard = false;
    });
  }

  void _showEmojiContainer() {
    setState(() {
      isShowEmojiKeyboard = true;
    });
  }

  void _showKeyboard() => focusNode.requestFocus();
  void _hideKeyboard() => focusNode.unfocus();

  void toggleEmojiKeyboard() {
    if (isShowEmojiKeyboard) {
      _showKeyboard();
      _hideEmojiContainer();
    } else {
      _hideKeyboard();
      _showEmojiContainer();
    }
  }

  final TextEditingController _textMessageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _isDisplaySendButton = false;
  @override
  void dispose() {
    _textMessageController.dispose();
    super.dispose();
  }

  bool _isShowAttachWindow = false;

  FlutterSoundRecorder? _soundRecorder;
  bool _isRecording = false;
  bool _isRecordInit = false;

  @override
  void initState() {
    _soundRecorder = FlutterSoundRecorder();
    // _openAudioRecording();
    BlocProvider.of<GetSingleUserCubit>(context)
        .getSingleUser(uid: widget.message.recipientUid!);

    BlocProvider.of<MessageCubit>(context).getMessages(
        message: MessageEntity(
            senderUid: widget.message.senderUid,
            recipientUid: widget.message.recipientUid));

    super.initState();
  }

  Future<void> _scrollToBottom() async {
    if (_scrollController.hasClients) {
      await Future.delayed(const Duration(milliseconds: 100));
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  File? _image;

  Future selectImage() async {
    setState(() => _image = null);
    try {
      final pickedFile =
          await ImagePicker.platform.getImage(source: ImageSource.gallery);

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

  File? _video;

  Future selectVideo() async {
    setState(() => _image = null);
    try {
      final pickedFile =
          await ImagePicker.platform.pickVideo(source: ImageSource.gallery);

      setState(() {
        if (pickedFile != null) {
          _video = File(pickedFile.path);
        } else {
          print("no image has been selected");
        }
      });
    } catch (e) {
      toast("some error occured $e");
    }
  }

  void onMessageSwipe(
      {String? message, String? username, String? type, bool? isMe}) {
    BlocProvider.of<MessageCubit>(context).setMessageReplay =
        MessageReplayEntity(
      message: message,
      username: username,
      messageType: type,
      isMe: isMe,
    );
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });

    final provider = BlocProvider.of<MessageCubit>(context);

    bool _isReplying = provider.messageReplay.message != null;

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.black),
        title: Column(
          children: [
            Text(
              '${widget.message.recipientName}',
              style: TextStyle(color: textColor),
            ),
            BlocBuilder<GetSingleUserCubit, GetSingleUserState>(
                builder: (context, state) {
              if (state is GetSingleUserLoaded) {
                return state.singleUser.isOnline == true
                    ? const Text(
                        "Online",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          color: Colors.green,
                        ),
                      )
                    : const Text(
                        "Offline",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                        ),
                      );
              }
              return Container();
            }),
          ],
        ),
        actions: const [
          Icon(
            Icons.videocam_rounded,
            size: 25,
            color: Colors.black,
          ),
          SizedBox(
            width: 25,
          ),
          Icon(
            Icons.call,
            size: 22,
            color: Colors.black,
          ),
          SizedBox(
            width: 25,
          ),
          Icon(
            Icons.more_vert,
            size: 22,
            color: Colors.black,
          ),
          SizedBox(
            width: 15,
          ),
        ],
      ),
      body: BlocBuilder<MessageCubit, MessageState>(
        builder: (context, state) {
          if (state is MessageLoaded) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _scrollToBottom();
            });
            final messages = state.messages;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _isShowAttachWindow = false;
                });
              },
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    top: 0,
                    child: Image.asset("assets/images/background.png",
                        fit: BoxFit.cover),
                  ),
                  Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          controller: _scrollController,
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            final message = messages[index];
                            if (message.isSeen == false &&
                                message.recipientUid == widget.message.uid) {
                              provider.seenMessage(
                                message: MessageEntity(
                                  senderUid: widget.message.senderUid,
                                  recipientUid: widget.message.recipientUid,
                                  messageId: message.messageId,
                                ),
                              );
                            }
                            if (message.senderUid == widget.message.senderUid) {
                              return _messageLayout(
                                messageType: message.messageType,
                                message: message.message,
                                alignment: Alignment.centerRight,
                                createAt: message.createdAt,
                                isSeen: message.isSeen,
                                isShowTick: true,
                                messageBgColor: whiteColor,
                                rightPadding:
                                    message.repliedMessage == "" ? 85 : 5,
                                reply: MessageReplayEntity(
                                    message: message.repliedMessage,
                                    messageType: message.repliedMessageType,
                                    username: message.repliedTo),
                                onLongPress: () {
                                  focusNode.unfocus();
                                  displayAlertDialog(
                                    context,
                                    onTap: () {
                                      BlocProvider.of<MessageCubit>(context)
                                          .deleteMessage(
                                              message: MessageEntity(
                                                  senderUid:
                                                      widget.message.senderUid,
                                                  recipientUid: widget
                                                      .message.recipientUid,
                                                  messageId:
                                                      message.messageId));
                                      Navigator.pop(context);
                                    },
                                    confirmTitle: "Xoá",
                                    content:
                                        "Bạn có chắc chắn muốn xóa tin nhắn này không?",
                                  );
                                },
                                onSwipe: () {
                                  onMessageSwipe(
                                      message: message.message,
                                      username: message.senderName,
                                      type: message.messageType,
                                      isMe: true);
                                  setState(() {});
                                },
                              );
                            } else {
                              return _messageLayout(
                                messageType: message.messageType,
                                message: message.message,
                                alignment: Alignment.centerLeft,
                                createAt: message.createdAt,
                                isSeen: message.isSeen,
                                isShowTick: false,
                                messageBgColor: messageColor,
                                rightPadding:
                                    message.repliedMessage == "" ? 85 : 5,
                                reply: MessageReplayEntity(
                                    message: message.repliedMessage,
                                    messageType: message.repliedMessageType,
                                    username: message.repliedTo),
                                onLongPress: () {
                                  focusNode.unfocus();
                                  displayAlertDialog(
                                    context,
                                    onTap: () {
                                      BlocProvider.of<MessageCubit>(context)
                                          .deleteMessage(
                                              message: MessageEntity(
                                                  senderUid:
                                                      widget.message.senderUid,
                                                  recipientUid: widget
                                                      .message.recipientUid,
                                                  messageId:
                                                      message.messageId));
                                      Navigator.pop(context);
                                    },
                                    confirmTitle: "Xoá",
                                    content:
                                        "Bạn có chắc chắn muốn xóa tin nhắn này không?",
                                  );
                                },
                                onSwipe: () {
                                  onMessageSwipe(
                                    message: message.message,
                                    username: message.senderName,
                                    type: message.messageType,
                                    isMe: false,
                                  );
                                  setState(() {});
                                },
                              );
                            }
                          },
                        ),
                      ),
                      _isReplying == true
                          ? const SizedBox(
                              height: 5,
                            )
                          : const SizedBox(
                              height: 0,
                            ),
                      _isReplying == true
                          ? Row(
                              children: [
                                Expanded(
                                  child: MessageReplayPreviewWidget(
                                    onCancelReplayListener: () {
                                      provider.setMessageReplay =
                                          MessageReplayEntity();
                                      setState(() {});
                                    },
                                  ),
                                ),
                                Container(width: 60),
                              ],
                            )
                          : Container(),
                      Container(
                        margin: EdgeInsets.only(
                          left: 10,
                          right: 10,
                          top: _isReplying == true ? 0 : 5,
                          bottom: 5,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 20.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 5),
                                  decoration: BoxDecoration(
                                    color: appBarColor,
                                    borderRadius: _isReplying == true
                                        ? const BorderRadius.only(
                                            bottomLeft: Radius.circular(25),
                                            bottomRight: Radius.circular(25),
                                          )
                                        : BorderRadius.circular(25),
                                  ),
                                  height: 50,
                                  child: TextField(
                                    style: const TextStyle(
                                      color: textColor,
                                    ),
                                    focusNode: focusNode,
                                    onTap: () {
                                      setState(() {
                                        _isShowAttachWindow = false;
                                        isShowEmojiKeyboard = false;
                                      });
                                    },
                                    controller: _textMessageController,
                                    onChanged: (value) {
                                      if (value.isNotEmpty) {
                                        setState(() {
                                          _textMessageController.text = value;
                                          _isDisplaySendButton = true;
                                        });
                                      } else {
                                        setState(() {
                                          _isDisplaySendButton = false;
                                          _textMessageController.text = value;
                                        });
                                      }
                                    },
                                    decoration: InputDecoration(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        vertical: 15,
                                      ),
                                      prefixIcon: GestureDetector(
                                        onTap: toggleEmojiKeyboard,
                                        child: Icon(
                                          isShowEmojiKeyboard == false
                                              ? Icons.emoji_emotions
                                              : Icons.keyboard_outlined,
                                          color: greyColor,
                                        ),
                                      ),
                                      suffixIcon: Padding(
                                        padding:
                                            const EdgeInsets.only(top: 12.0),
                                        child: Wrap(
                                          children: [
                                            const SizedBox(
                                              width: 15,
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                selectImage().then(
                                                  (value) {
                                                    if (_image != null) {
                                                      WidgetsBinding.instance
                                                          .addPostFrameCallback(
                                                        (timeStamp) {
                                                          showImagePickedBottomModalSheet(
                                                            context,
                                                            recipientName: widget
                                                                .message
                                                                .recipientName,
                                                            file: _image,
                                                            onTap: () {
                                                              _sendImageMessage();
                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                          );
                                                        },
                                                      );
                                                    }
                                                  },
                                                );
                                              },
                                              child: const Icon(
                                                Icons.camera_alt,
                                                color: greyColor,
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                          ],
                                        ),
                                      ),
                                      hintText: 'Message',
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10.0),
                              GestureDetector(
                                onTap: () {
                                  _sendTextMessage();
                                },
                                child: Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(25),
                                      color: tabColor),
                                  child: Center(
                                    child: Icon(
                                      _isDisplaySendButton ||
                                              _textMessageController
                                                  .text.isNotEmpty
                                          ? Icons.send_outlined
                                          : _isRecording
                                              ? Icons.close
                                              : Icons.mic,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      isShowEmojiKeyboard
                          ? SizedBox(
                              height: 310,
                              child: Stack(
                                children: [
                                  EmojiPicker(
                                    config: const Config(),
                                    onEmojiSelected: ((category, emoji) {
                                      setState(
                                        () {
                                          _textMessageController.text =
                                              _textMessageController.text +
                                                  emoji.emoji;
                                        },
                                      );
                                    }),
                                  ),
                                  Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Container(
                                      width: double.infinity,
                                      height: 40,
                                      decoration: const BoxDecoration(
                                          color: appBarColor),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Icon(
                                              Icons.search,
                                              size: 20,
                                              color: greyColor,
                                            ),
                                            const Row(
                                              children: [
                                                Icon(
                                                  Icons.emoji_emotions_outlined,
                                                  size: 20,
                                                  color: tabColor,
                                                ),
                                                SizedBox(
                                                  width: 15,
                                                ),
                                                Icon(
                                                  Icons.gif_box_outlined,
                                                  size: 20,
                                                  color: greyColor,
                                                ),
                                                SizedBox(
                                                  width: 15,
                                                ),
                                                Icon(
                                                  Icons.ad_units,
                                                  size: 20,
                                                  color: greyColor,
                                                ),
                                              ],
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                setState(
                                                  () {
                                                    _textMessageController
                                                            .text =
                                                        _textMessageController
                                                            .text
                                                            .substring(
                                                      0,
                                                      _textMessageController
                                                              .text.length -
                                                          2,
                                                    );
                                                  },
                                                );
                                              },
                                              child: const Icon(
                                                Icons.backspace_outlined,
                                                size: 20,
                                                color: greyColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            )
                          : const SizedBox(),
                    ],
                  ),
                ],
              ),
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

  Widget _messageLayout(
      {Color? messageBgColor,
      Alignment? alignment,
      Timestamp? createAt,
      void Function()? onSwipe,
      String? message,
      String? messageType,
      bool? isShowTick,
      bool? isSeen,
      VoidCallback? onLongPress,
      MessageReplayEntity? reply,
      double? rightPadding}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: SwipeTo(
        onRightSwipe: (details) => onSwipe?.call(),
        child: GestureDetector(
          onLongPress: onLongPress,
          child: Container(
            alignment: alignment,
            child: Stack(
              children: [
                Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      padding: EdgeInsets.only(
                        left: 5,
                        right: messageType == MessageTypeConst.textMessage
                            ? rightPadding!
                            : 5,
                        top: 5,
                        bottom: 5,
                      ),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.80,
                      ),
                      decoration: BoxDecoration(
                        color: messageBgColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          reply?.message == null || reply?.message == ""
                              ? const SizedBox()
                              : Container(
                                  height: reply!.messageType ==
                                          MessageTypeConst.textMessage
                                      ? 70
                                      : 80,
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        height: double.infinity,
                                        width: 4.5,
                                        decoration: BoxDecoration(
                                          color: reply.username ==
                                                  widget.message.recipientName
                                              ? Colors.deepPurpleAccent
                                              : tabColor,
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(15),
                                            bottomLeft: Radius.circular(15),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 5.0, vertical: 5),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "${reply.username == widget.message.recipientName ? reply.username : "You"}",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: reply.username ==
                                                          widget.message
                                                              .recipientName
                                                      ? Colors.deepPurpleAccent
                                                      : tabColor,
                                                ),
                                              ),
                                              MessageReplayTypeWidget(
                                                message: reply.message,
                                                type: reply.messageType,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                          const SizedBox(
                            height: 3,
                          ),
                          MessageTypeWidget(
                            message: message,
                            type: messageType,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 3),
                  ],
                ),
                Positioned(
                  bottom: 4,
                  right: 10,
                  child: Row(
                    children: [
                      Text(
                        DateFormat.jm().format(createAt!.toDate()),
                        style: const TextStyle(fontSize: 10, color: blackColor),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      isShowTick == true
                          ? Icon(
                              isSeen == true ? Icons.done_all : Icons.done,
                              size: 16,
                              color: isSeen == true ? Colors.green : greyColor,
                            )
                          : Container()
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future _sendTextMessage() async {
    final provider = BlocProvider.of<MessageCubit>(context);

    if (_isDisplaySendButton || _textMessageController.text.isNotEmpty) {
      if (provider.messageReplay.message != null) {
        _sendMessage(
            message: _textMessageController.text,
            type: MessageTypeConst.textMessage,
            repliedMessage: provider.messageReplay.message,
            repliedTo: provider.messageReplay.username,
            repliedMessageType: provider.messageReplay.messageType);
      } else {
        _sendMessage(
            message: _textMessageController.text,
            type: MessageTypeConst.textMessage);
      }

      provider.setMessageReplay = MessageReplayEntity();
      setState(() {
        _textMessageController.clear();
      });
    } else {
      final temporaryDir = await getTemporaryDirectory();
      final audioPath = '${temporaryDir.path}/flutter_sound.aac';
      if (!_isRecordInit) {
        return;
      }

      if (_isRecording == true) {
        await _soundRecorder!.stopRecorder();
        StorageProviderRemoteDataSource.uploadMessageFile(
          file: File(audioPath),
          onComplete: (value) {},
          uid: widget.message.senderUid,
          otherUid: widget.message.recipientUid,
          type: MessageTypeConst.audioMessage,
        ).then((audioUrl) {
          _sendMessage(message: audioUrl, type: MessageTypeConst.audioMessage);
        });
      } else {
        await _soundRecorder!.startRecorder(
          toFile: audioPath,
        );
      }

      setState(() {
        _isRecording = !_isRecording;
      });
    }
  }

  void _sendImageMessage() {
    StorageProviderRemoteDataSource.uploadMessageFile(
      file: _image!,
      onComplete: (value) {},
      uid: widget.message.senderUid,
      otherUid: widget.message.recipientUid,
      type: MessageTypeConst.photoMessage,
    ).then((photoImageUrl) {
      _sendMessage(message: photoImageUrl, type: MessageTypeConst.photoMessage);
    });
  }

  void _sendMessage(
      {required String message,
      required String type,
      String? repliedMessage,
      String? repliedTo,
      String? repliedMessageType}) {
    _scrollToBottom();

    ChatUtils.sendMessage(
      context,
      messageEntity: widget.message,
      message: message,
      type: type,
      repliedTo: repliedTo,
      repliedMessageType: repliedMessageType,
      repliedMessage: repliedMessage,
    ).then((value) {
      _scrollToBottom();
    });
  }
}
