import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:simple_live_app/app/app_style.dart';
import 'package:simple_live_app/app/sites.dart';
import 'package:simple_live_app/app/utils.dart';
import 'package:simple_live_app/models/db/history.dart';
import 'package:simple_live_app/modules/live_room/live_room_controller.dart';
import 'package:simple_live_app/services/db_service.dart';
import 'package:simple_live_app/services/follow_service.dart';
import 'package:simple_live_app/widgets/desktop_refresh_button.dart';
import 'package:simple_live_app/widgets/follow_user_item.dart';
import 'package:simple_live_app/widgets/net_image.dart';

/// 全屏播放时切换直播间的面板，包含关注列表和播放历史
class RoomSwitchPanel extends StatelessWidget {
  final LiveRoomController controller;

  /// 切换房间前关闭当前弹层的回调
  final VoidCallback onClose;

  const RoomSwitchPanel({
    required this.controller,
    required this.onClose,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            _buildHeader(),
            Divider(
              height: 1,
              color: Colors.grey.withAlpha(25),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildFollowList(),
                  _buildHistoryList(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        IconButton(
          onPressed: onClose,
          tooltip: "返回",
          icon: const Icon(Icons.arrow_back),
        ),
        const Expanded(
          child: TabBar(
            indicatorSize: TabBarIndicatorSize.tab,
            labelPadding: EdgeInsets.zero,
            tabs: [
              Tab(text: "关注列表"),
              Tab(text: "播放历史"),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFollowList() {
    return Obx(
      () {
        var list = FollowService.instance.liveList;
        return Stack(
          children: [
            RefreshIndicator(
              onRefresh: FollowService.instance.loadData,
              child: list.isEmpty
                  ? _buildEmptyPlaceholder("暂无正在直播的关注主播")
                  : ListView.builder(
                      itemCount: list.length,
                      itemBuilder: (_, i) {
                        var item = list[i];
                        return Obx(
                          () => FollowUserItem(
                            item: item,
                            playing:
                                controller.rxSite.value.id == item.siteId &&
                                    controller.rxRoomId.value == item.roomId,
                            onTap: () {
                              onClose();
                              controller.resetRoom(
                                Sites.allSites[item.siteId]!,
                                item.roomId,
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),
            if (Platform.isLinux || Platform.isWindows || Platform.isMacOS)
              Positioned(
                right: 12,
                bottom: 12,
                child: Obx(
                  () => DesktopRefreshButton(
                    refreshing: FollowService.instance.updating.value,
                    onPressed: FollowService.instance.loadData,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildHistoryList(BuildContext context) {
    return ValueListenableBuilder<Box<History>>(
      valueListenable: DBService.instance.historyBox.listenable(),
      builder: (_, box, __) {
        var list = box.values
            .where((item) => Sites.allSites.containsKey(item.siteId))
            .toList()
          ..sort((a, b) => b.updateTime.compareTo(a.updateTime));
        if (list.isEmpty) {
          return _buildEmptyPlaceholder("暂无播放历史");
        }
        return ListView.builder(
          itemCount: list.length,
          itemBuilder: (_, i) {
            var item = list[i];
            var site = Sites.allSites[item.siteId]!;
            var playing = controller.rxSite.value.id == item.siteId &&
                controller.rxRoomId.value == item.roomId;
            return ListTile(
              contentPadding: AppStyle.edgeInsetsL16.copyWith(right: 16),
              leading: NetImage(
                item.face,
                width: 48,
                height: 48,
                borderRadius: 24,
              ),
              title: Text(item.userName),
              subtitle: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 4,
                children: [
                  Image.asset(
                    site.logo,
                    width: 20,
                  ),
                  Text(
                    site.name,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    Utils.parseTime(item.updateTime),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  if (playing)
                    Text(
                      "正在观看",
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
              trailing: playing ? const Icon(Icons.play_arrow) : null,
              onTap: () {
                onClose();
                controller.resetRoom(site, item.roomId);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyPlaceholder(String text) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Text(
              text,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ),
      ],
    );
  }
}
