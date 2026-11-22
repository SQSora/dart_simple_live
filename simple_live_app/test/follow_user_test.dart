import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:simple_live_app/models/db/follow_user.dart';
import 'package:simple_live_app/services/db_service.dart';
import 'package:simple_live_app/services/follow_service.dart';

class _FakeDBService extends DBService {
  final Map<String, FollowUser> follows = {};

  @override
  List<FollowUser> getFollowList() => follows.values.toList();

  @override
  Future<void> addFollow(FollowUser follow) async {
    follows[follow.id] = follow;
  }
}

void main() {
  FollowUser createFollowUser({
    String id = 'demo_site_10001',
    String userName = '测试主播',
    DateTime? addTime,
    int watchCount = 0,
  }) =>
      FollowUser(
        id: id,
        roomId: '10001',
        siteId: 'demo_site',
        userName: userName,
        face: 'https://example.com/old.jpg',
        addTime: addTime ?? DateTime(2026, 1, 1),
        watchCount: watchCount,
      );

  group('FollowUser.updateProfile', () {
    test('更新昵称和头像', () {
      var user = createFollowUser();
      expect(
        user.updateProfile(
          userName: '测试主播（新）',
          face: 'https://example.com/new.jpg',
        ),
        isTrue,
      );
      expect(user.userName, '测试主播（新）');
      expect(user.face, 'https://example.com/new.jpg');
    });

    test('空白昵称和头像不会覆盖已有资料', () {
      var user = createFollowUser();
      expect(user.updateProfile(userName: '  ', face: ''), isFalse);
      expect(user.userName, '测试主播');
      expect(user.face, 'https://example.com/old.jpg');
    });

    test('只更新发生变化的字段', () {
      var user = createFollowUser();
      expect(
        user.updateProfile(
          userName: '测试主播',
          face: 'https://example.com/new.jpg',
        ),
        isTrue,
      );
      expect(user.userName, '测试主播');
      expect(user.face, 'https://example.com/new.jpg');
    });

    test('资料没有变化时返回 false', () {
      var user = createFollowUser();
      expect(
        user.updateProfile(
          userName: '测试主播',
          face: 'https://example.com/old.jpg',
        ),
        isFalse,
      );
    });

    test('昵称会去除首尾空白', () {
      var user = createFollowUser();
      expect(user.updateProfile(userName: '  新昵称  '), isTrue);
      expect(user.userName, '新昵称');
    });
  });

  group('FollowService.compareFollowUser', () {
    test('先按直播状态降序，再按关注时间降序', () {
      var liveOld = createFollowUser(
        id: 'demo_site_1',
        userName: '测试主播A',
        addTime: DateTime(2026, 1, 1),
      )..liveStatus.value = 2;
      var liveNew = createFollowUser(
        id: 'demo_site_2',
        userName: '测试主播B',
        addTime: DateTime(2026, 2, 1),
      )..liveStatus.value = 2;
      var offline = createFollowUser(
        id: 'demo_site_3',
        userName: '测试主播C',
        addTime: DateTime(2026, 1, 15),
      )..liveStatus.value = 1;
      var unknown = createFollowUser(
        id: 'demo_site_4',
        userName: '测试主播D',
        addTime: DateTime(2025, 12, 1),
      );
      var users = [unknown, liveNew, offline, liveOld];

      users.sort(FollowService.compareFollowUser);

      expect(
        users.map((e) => e.userName).toList(),
        ['测试主播B', '测试主播A', '测试主播C', '测试主播D'],
      );
    });

    test('开启观看次数排序后，直播状态优先，再按观看次数降序', () {
      var liveFew = createFollowUser(
        id: 'demo_site_5',
        userName: '测试主播E',
        addTime: DateTime(2026, 1, 1),
        watchCount: 3,
      )..liveStatus.value = 2;
      var liveMany = createFollowUser(
        id: 'demo_site_6',
        userName: '测试主播F',
        addTime: DateTime(2026, 2, 1),
        watchCount: 8,
      )..liveStatus.value = 2;
      var offlineMany = createFollowUser(
        id: 'demo_site_7',
        userName: '测试主播G',
        addTime: DateTime(2026, 3, 1),
        watchCount: 99,
      )..liveStatus.value = 1;
      var unknown = createFollowUser(
        id: 'demo_site_8',
        userName: '测试主播H',
        addTime: DateTime(2025, 12, 1),
        watchCount: 50,
      );
      var users = [unknown, offlineMany, liveFew, liveMany];

      users.sort(
        (a, b) => FollowService.compareFollowUser(
          a,
          b,
          byWatchCount: true,
        ),
      );

      expect(
        users.map((e) => e.userName).toList(),
        ['测试主播F', '测试主播E', '测试主播G', '测试主播H'],
      );
    });
  });

  group('FollowService.syncFollowUserInfo', () {
    late FollowService service;
    late _FakeDBService db;

    setUp(() {
      Get.reset();
      db = _FakeDBService();
      Get.put<DBService>(db);
      service = FollowService();
    });

    tearDown(() => Get.reset());

    test('更新关注列表并持久化最新资料', () async {
      var user = createFollowUser();
      service.followList.assignAll([user]);

      await service.syncFollowUserInfo(
        user.id,
        userName: '新昵称',
        face: 'https://example.com/new.jpg',
      );

      expect(user.userName, '新昵称');
      expect(user.face, 'https://example.com/new.jpg');
      expect(db.follows[user.id]!.userName, '新昵称');
      expect(db.follows[user.id]!.face, 'https://example.com/new.jpg');
    });

    test('空资料不会覆盖已有资料', () async {
      var user = createFollowUser();
      service.followList.assignAll([user]);

      await service.syncFollowUserInfo(user.id, userName: '  ', face: '');

      expect(user.userName, '测试主播');
      expect(user.face, 'https://example.com/old.jpg');
      expect(db.follows, isEmpty);
    });

    test('列表持有不同实例时也能一起更新', () async {
      var followUser = createFollowUser();
      var liveUser = createFollowUser();
      service.followList.assignAll([followUser]);
      service.liveList.assignAll([liveUser]);

      await service.syncFollowUserInfo(
        followUser.id,
        userName: '新昵称',
        face: 'https://example.com/new.jpg',
      );

      expect(followUser.userName, '新昵称');
      expect(liveUser.userName, '新昵称');
      expect(followUser.face, 'https://example.com/new.jpg');
      expect(liveUser.face, 'https://example.com/new.jpg');
      expect(db.follows[followUser.id]!.userName, '新昵称');
    });
  });

  group('FollowService.incrementWatchCount', () {
    late FollowService service;
    late _FakeDBService db;

    setUp(() {
      Get.reset();
      db = _FakeDBService();
      Get.put<DBService>(db);
      service = FollowService();
    });

    tearDown(() => Get.reset());

    test('累加观看次数并持久化', () async {
      var user = createFollowUser();
      service.followList.assignAll([user]);

      await service.incrementWatchCount(user.id);
      await service.incrementWatchCount(user.id);

      expect(user.watchCount, 2);
      expect(db.follows[user.id]!.watchCount, 2);
    });
  });
}
