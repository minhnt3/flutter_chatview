import 'package:chatview/chatview.dart';
import 'package:flutter/material.dart';
import 'package:popup_menu/popup_menu.dart' as p;

class MoreMenuIconButton extends StatelessWidget {
  MoreMenuIconButton({
    Key? key,
    required this.message,
    required this.index,
  }) : super(key: key);

  final Message message;
  final int index;

  final globalKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return IconButton(
      key: globalKey,
      onPressed: () {
        _showPopupMenu(context);
      },
      icon: const Icon(
        Icons.more_horiz,
        color: Colors.grey,
      ),
    );
  }

  void _showPopupMenu(BuildContext context) {
    const transfer = 'Transfer';
    const edit = 'Edit';
    const delete = 'Delete';
    final menu = p.PopupMenu(
      context: context,
      config: const p.MenuConfig(
        backgroundColor: Colors.black,
        lineColor: Colors.white,
        type: p.MenuType.list,
        itemWidth: 150,
      ),
      items: [
        p.MenuItem(
          title: transfer,
          image: const Icon(
            Icons.sync_alt,
            color: Colors.white,
          ),
          textStyle: TextStyle(color: Colors.white, fontSize: 12),
        ),
        p.MenuItem(
          title: edit,
          image: const Icon(
            Icons.edit,
            color: Colors.white,
          ),
          textStyle: TextStyle(color: Colors.white, fontSize: 12),
        ),
        p.MenuItem(
          title: delete,
          image: const Icon(
            Icons.delete,
            color: Colors.white,
          ),
          textStyle: TextStyle(color: Colors.white, fontSize: 12),
        ),
      ],
      onClickMenu: (item) {
        switch (item.menuTitle) {
          case transfer:
            break;
          case edit:
            break;
          case delete:
            break;
        }
      },
    );

    menu.show(widgetKey: globalKey);
  }
}