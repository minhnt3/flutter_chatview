import 'package:chatview/chatview.dart';
import 'package:example/data.dart';
import 'package:example/models/theme.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const Example());
}

class Example extends StatelessWidget {
  const Example({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Chat UI Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xffEE5366),
        colorScheme:
            ColorScheme.fromSwatch(accentColor: const Color(0xffEE5366)),
      ),
      home: const ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  AppTheme theme = LightTheme();
  bool isDarkTheme = false;
  final currentUser = ChatUser(
    id: '1',
    name: 'Flutter',
    profilePhoto: Data.profileImage,
  );
  final _chatController = ChatController(
    scrollController: ScrollController(),
    chatUsers: [
      ChatUser(
        id: '2',
        name: 'Simform',
        profilePhoto: Data.profileImage,
      ),
      ChatUser(
        id: '3',
        name: 'Jhon',
        profilePhoto: Data.profileImage,
      ),
      ChatUser(
        id: '4',
        name: 'Mike',
        profilePhoto: Data.profileImage,
      ),
      ChatUser(
        id: '5',
        name: 'Rich',
        profilePhoto: Data.profileImage,
      ),
    ],
  );

  void _showHideTypingIndicator() {
    _chatController.setTypingIndicator = !_chatController.showTypingIndicator;
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 0), () {
      _chatController.messageList = Data.messageList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ChatView(
        onSendTap: _onSendTap,
        onMenuToggle: (open) => print('Menu is ${open ? 'open' : 'closed'}'),
        onTextChanged: (text) => print('Text is $text'),
        onMenuItemPressed: (item) => print('Menu item pressed $item'),
        onMoreTap: (m, i) => print('More button tapped $m $i'),
        items: [
          MenuItem(
            text: 'Secure the chat',
            action: () async {},
          ),
          MenuItem(
            text: 'Unlock that chat',
            action: () async {},
          ),
        ],
        appBar: _buildAppBar(),
        currentUser: currentUser,
        chatController: _chatController,
        loadingWidget: const SizedBox(
          height: 3,
          child: LinearProgressIndicator(
            backgroundColor: Colors.white,
            color: Colors.black,
          ),
        ),
        featureActiveConfig: featureActiveConfig(false),
        chatViewState: chatViewState,
        chatViewStateConfig: chatViewStateConfig,
        chatBackgroundConfig: chatBackgroundConfig,
        sendMessageConfig: sendMessageConfig,
        chatBubbleConfig: chatBubbleConfig,
        replyPopupConfig: replyPopupConfig,
        repliedMessageConfig: repliedMessageConfig,
        swipeToReplyConfig: swipeToReplyConfig,
      ),
    );
  }

  void _onSendTap(
    String message,
    ReplyMessage replyMessage,
    MessageType messageType,
  ) {
    final id = int.parse(Data.messageList.last.id) + 1;
    _chatController.messageList = [
      ..._chatController.messageList,
      Message(
        id: id.toString(),
        createdAt: DateTime.now(),
        message: message,
        sendBy: currentUser.id,
        replyMessage: replyMessage,
        messageType: messageType,
      ),
      Message(
        id: (id + 1).toString(),
        createdAt: DateTime.now(),
        message: message,
        sendBy: currentUser.id,
        replyMessage: replyMessage,
        messageType: messageType,
      ),
      Message(
        id: (id + 2).toString(),
        createdAt: DateTime.now(),
        message: message,
        sendBy: currentUser.id,
        replyMessage: replyMessage,
        messageType: messageType,
      ),
      Message(
        id: (id + 3).toString(),
        createdAt: DateTime.now(),
        message: message,
        sendBy: currentUser.id,
        replyMessage: replyMessage,
        messageType: messageType,
      ),
    ];
    Future.delayed(const Duration(milliseconds: 300), () {
      _chatController.messageList.last.setStatus = MessageStatus.undelivered;
    });
    Future.delayed(const Duration(seconds: 1), () {
      _chatController.messageList.last.setStatus = MessageStatus.read;
    });
  }

  void _onThemeIconTap() {
    setState(() {
      if (isDarkTheme) {
        theme = LightTheme();
        isDarkTheme = false;
      } else {
        theme = DarkTheme();
        isDarkTheme = true;
      }
    });
  }

  Widget _buildAppBar() {
    return AppBar(
      centerTitle: false,
      backgroundColor: Colors.black,
      actions: [],
    );
  }

  FeatureActiveConfig featureActiveConfig(bool enablePagination) =>
      FeatureActiveConfig(
        lastSeenAgoBuilderVisibility: false,
        receiptsBuilderVisibility: true,
        enablePagination: enablePagination,
        enableSwipeToSeeTime: false,
        enableDoubleTapToLike: false,
        enableReactionPopup: false,
        enableChatSeparator: false,
        enableOtherUserProfileAvatar: false,
      );

  ChatViewState get chatViewState => ChatViewState.hasMessages;

  ChatViewStateConfiguration get chatViewStateConfig =>
      ChatViewStateConfiguration(
        loadingWidgetConfig: const ChatViewStateWidgetConfiguration(
          loadingIndicatorColor: Colors.black,
        ),
        onReloadButtonTap: () {},
      );

  ChatBackgroundConfiguration get chatBackgroundConfig =>
      const ChatBackgroundConfiguration(
        listViewPadding: EdgeInsets.only(
          bottom: 16,
          top: 16,
        ),
        backgroundColor: Colors.transparent,
      );

  SendMessageConfiguration get sendMessageConfig =>
      const SendMessageConfiguration(
        replyMessageColor: Colors.grey,
        replyDialogColor: Color(0xff272336),
        replyTitleColor: Colors.white,
        closeIconColor: Colors.white,
        allowRecordingVoice: false,
        enableCameraImagePicker: true,
        enableGalleryImagePicker: true,
      );

  ChatBubbleConfiguration get chatBubbleConfig => ChatBubbleConfiguration(
        outgoingChatBubbleConfig: const ChatBubble(
          linkPreviewConfig: LinkPreviewConfiguration(
            backgroundColor: Color(0xff272336),
            bodyStyle: TextStyle(color: Colors.white),
            titleStyle: TextStyle(color: Colors.white),
          ),
          receiptsWidgetConfig:
              ReceiptsWidgetConfig(showReceiptsIn: ShowReceiptsIn.all),
          color: Colors.black,
        ),
        inComingChatBubbleConfig: ChatBubble(
          linkPreviewConfig: const LinkPreviewConfiguration(
            linkStyle: TextStyle(
              color: Color(0xff9f85ff),
              decoration: TextDecoration.underline,
            ),
            backgroundColor: Color(0xff9f85ff),
            bodyStyle: TextStyle(color: Colors.white),
            titleStyle: TextStyle(color: Colors.black),
          ),
          textStyle: const TextStyle(color: Colors.black),
          onMessageRead: (message) {
            /// send your message reciepts to the other client
            debugPrint('Message Read');
          },
          senderNameTextStyle: const TextStyle(color: Colors.black),
          color: const Color(0xFFEBEAF4),
        ),
      );

  ReplyPopupConfiguration get replyPopupConfig => const ReplyPopupConfiguration(
        backgroundColor: Colors.black,
        buttonTextStyle: TextStyle(color: Colors.white),
        topBorderColor: Colors.black54,
      );

  RepliedMessageConfiguration get repliedMessageConfig =>
      RepliedMessageConfiguration(
        backgroundColor: const Color(0xff595959),
        verticalBarColor: const Color(0xFFDEDEDE),
        repliedMsgAutoScrollConfig: RepliedMsgAutoScrollConfig(
          enableHighlightRepliedMsg: true,
          highlightColor: Colors.pinkAccent.shade100,
          highlightScale: 1.1,
        ),
        textStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.25,
        ),
        replyTitleTextStyle: const TextStyle(color: Colors.white),
      );

  SwipeToReplyConfiguration get swipeToReplyConfig =>
      const SwipeToReplyConfiguration(
        replyIconColor: Colors.white,
      );
}
