/*
 * Copyright (c) 2022 Simform Solutions
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */
import 'dart:io' if (kIsWeb) 'dart:html';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:chatview/chatview.dart';
import 'package:chatview/src/extensions/extensions.dart';
import 'package:chatview/src/utils/package_strings.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../utils/constants/constants.dart';

class SendMessageWidget extends StatefulWidget {
  const SendMessageWidget({
    Key? key,
    required this.onSendTap,
    required this.chatController,
    this.sendMessageConfig,
    this.backgroundColor,
    this.sendMessageBuilder,
    this.onReplyCallback,
    this.onReplyCloseCallback,
    required this.items,
    this.onTextChanged,
    this.onMenuToggle,
    this.onMenuItemPressed,
  }) : super(key: key);

  final List<MenuItem> items;
  final void Function(String text)? onTextChanged;
  final void Function(bool)? onMenuToggle;
  final void Function(ActionType)? onMenuItemPressed;

  /// Provides call back when user tap on send button on text field.
  final StringMessageCallBack onSendTap;

  /// Provides configuration for text field appearance.
  final SendMessageConfiguration? sendMessageConfig;

  /// Allow user to set background colour.
  final Color? backgroundColor;

  /// Allow user to set custom text field.
  final ReplyMessageWithReturnWidget? sendMessageBuilder;

  /// Provides callback when user swipes chat bubble for reply.
  final ReplyMessageCallBack? onReplyCallback;

  /// Provides call when user tap on close button which is showed in reply pop-up.
  final VoidCallBack? onReplyCloseCallback;

  /// Provides controller for accessing few function for running chat.
  final ChatController chatController;

  @override
  State<SendMessageWidget> createState() => SendMessageWidgetState();
}

class SendMessageWidgetState extends State<SendMessageWidget> {
  final _textEditingController = TextEditingController();
  final ValueNotifier<ReplyMessage> _replyMessage =
      ValueNotifier(const ReplyMessage());

  ReplyMessage get replyMessage => _replyMessage.value;
  final _focusNode = FocusNode();

  ChatUser? get repliedUser => replyMessage.replyTo.isNotEmpty
      ? widget.chatController.getUserFromId(replyMessage.replyTo)
      : null;

  String _replyTo(ReplyMessage replyMessage) =>
      replyMessage.replyTo == currentUser?.id
          ? PackageStrings.you
          : repliedUser?.name ?? '';

  ChatUser? currentUser;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (provide != null) {
      currentUser = provide!.currentUser;
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.sendMessageBuilder != null
        ? Positioned(
            right: 0,
            left: 0,
            bottom: 0,
            child: widget.sendMessageBuilder!(replyMessage),
          )
        : Positioned(
            right: 0,
            left: 0,
            bottom: 0,
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Stack(
                children: [
                  Positioned(
                    right: 0,
                    left: 0,
                    bottom: 0,
                    child: Container(
                      height: MediaQuery.of(context).size.height /
                          ((!kIsWeb && Platform.isIOS) ? 24 : 28),
                      color: widget.backgroundColor ?? Colors.white,
                    ),
                  ),
                  Column(
                    children: [
                      const SizedBox(
                          height: 0.5,
                          child: Divider(
                            color: Colors.grey,
                          )),
                      ValueListenableBuilder<ReplyMessage>(
                        builder: (_, state, child) {
                          if (state.message.isNotEmpty) {
                            return Container(
                              color: Colors.black,
                              padding: const EdgeInsets.fromLTRB(
                                leftPadding,
                                0,
                                leftPadding,
                                leftPadding,
                              ),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 2),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                  horizontal: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "${PackageStrings.replyTo} ${_replyTo(state)}",
                                          style: TextStyle(
                                            color: widget.sendMessageConfig
                                                    ?.replyTitleColor ??
                                                Colors.black,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.25,
                                          ),
                                        ),
                                        IconButton(
                                          constraints: const BoxConstraints(),
                                          padding: EdgeInsets.zero,
                                          icon: Icon(
                                            Icons.close,
                                            color: widget.sendMessageConfig
                                                    ?.closeIconColor ??
                                                Colors.black,
                                            size: 16,
                                          ),
                                          onPressed: _onCloseTap,
                                        ),
                                      ],
                                    ),
                                    if (state.messageType.isVoice)
                                      _voiceReplyMessageView
                                    else if (state.messageType == MessageType.custom)
                                      _imageReplyMessageView
                                    else
                                      Text(
                                        state.message,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          } else {
                            return const SizedBox.shrink();
                          }
                        },
                        valueListenable: _replyMessage,
                      ),
                      ChatUITextField(
                        items: widget.items,
                        onTextChanged: widget.onTextChanged,
                        onMenuToggle: widget.onMenuToggle,
                        onMenuItemPressed: widget.onMenuItemPressed,
                        focusNode: _focusNode,
                        textEditingController: _textEditingController,
                        onPressed: _onPressed,
                        sendMessageConfig: widget.sendMessageConfig,
                        onRecordingComplete: _onRecordingComplete,
                        onImageSelected: _onImageSelected,
                      )
                    ],
                  ),
                ],
              ),
            ),
          );
  }

  Widget get _voiceReplyMessageView {
    return Row(
      children: [
        Icon(
          Icons.mic,
          color: widget.sendMessageConfig?.micIconColor,
        ),
        const SizedBox(width: 4),
        if (replyMessage.voiceMessageDuration != null)
          Text(
            replyMessage.voiceMessageDuration!.toHHMMSS(),
            style: TextStyle(
              fontSize: 12,
              color:
                  widget.sendMessageConfig?.replyMessageColor ?? Colors.black,
            ),
          ),
      ],
    );
  }

  Widget get _imageReplyMessageView {
    return const Row(
      children: [
        Icon(
          Icons.photo,
          size: 20,
          color: Colors.white,
        ),
        Text(
          PackageStrings.photo,
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  void _onRecordingComplete(String? path) {
    if (path != null) {
      widget.onSendTap.call(path, replyMessage, MessageType.voice);
      _assignRepliedMessage();
    }
  }

  void _onImageSelected(String imagePath, String error) {
    if (imagePath.isNotEmpty) {
      widget.onSendTap.call(imagePath, replyMessage, MessageType.image);
      _assignRepliedMessage();
    }
  }

  void _assignRepliedMessage() {
    if (replyMessage.message.isNotEmpty) {
      _replyMessage.value = const ReplyMessage();
    }
  }

  void _onPressed() {
    if (_textEditingController.text.isNotEmpty &&
        !_textEditingController.text.startsWith('\n')) {
      widget.onSendTap.call(
        _textEditingController.text.trim(),
        replyMessage,
        MessageType.text,
      );
      _assignRepliedMessage();
      _textEditingController.clear();
    }
  }

  void assignReplyMessage(Message message) {
    if (currentUser != null) {
      _replyMessage.value = ReplyMessage(
        message: message.message,
        replyBy: currentUser!.id,
        replyTo: message.sendBy,
        messageType: message.messageType,
        messageId: message.id,
        voiceMessageDuration: message.voiceMessageDuration,
      );
    }
    FocusScope.of(context).requestFocus(_focusNode);
    if (widget.onReplyCallback != null) widget.onReplyCallback!(replyMessage);
  }

  void _onCloseTap() {
    _replyMessage.value = const ReplyMessage();
    if (widget.onReplyCloseCallback != null) widget.onReplyCloseCallback!();
  }

  double get _bottomPadding => (!kIsWeb && Platform.isIOS)
      ? (_focusNode.hasFocus
          ? bottomPadding1
          : View.of(context).viewPadding.bottom > 0
              ? bottomPadding2
              : bottomPadding3)
      : bottomPadding3;

  @override
  void dispose() {
    _textEditingController.dispose();
    _focusNode.dispose();
    _replyMessage.dispose();
    super.dispose();
  }
}
