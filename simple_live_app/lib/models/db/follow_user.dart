import 'package:get/get.dart';
import 'package:hive/hive.dart';

part 'follow_user.g.dart';

@HiveType(typeId: 1)
class FollowUser {
  FollowUser({
    required this.id,
    required this.roomId,
    required this.siteId,
    required this.userName,
    required this.face,
    required this.addTime,
    this.tag = "全部",
    this.watchCount = 0,
  });

  ///id=siteId_roomId
  @HiveField(0)
  String id;

  @HiveField(1)
  String roomId;

  @HiveField(2)
  String siteId;

  @HiveField(3)
  String userName;

  @HiveField(4)
  String face;

  @HiveField(5)
  DateTime addTime;

  @HiveField(6, defaultValue: "全部")
  String tag;

  /// 个人累计观看次数
  @HiveField(7, defaultValue: 0)
  int watchCount;

  /// 直播状态
  /// 0=未知(加载中) 1=未开播 2=直播中
  Rx<int> liveStatus = 0.obs;

  /// 开播时间戳
  String? liveStartTime;

  /// 用直播间的最新资料更新昵称和头像，空值不覆盖已有资料。
  /// 返回是否有字段发生变化。
  bool updateProfile({String? userName, String? face}) {
    var changed = false;
    var newName = userName?.trim() ?? "";
    var newFace = face?.trim() ?? "";
    if (newName.isNotEmpty && this.userName != newName) {
      this.userName = newName;
      changed = true;
    }
    if (newFace.isNotEmpty && this.face != newFace) {
      this.face = newFace;
      changed = true;
    }
    return changed;
  }

  factory FollowUser.fromJson(Map<String, dynamic> json) => FollowUser(
        id: json['id'],
        roomId: json['roomId'],
        siteId: json['siteId'],
        userName: json['userName'],
        face: json['face'],
        addTime: DateTime.parse(json['addTime']),
        tag: json["tag"] ?? "全部",
        watchCount: (json["watchCount"] as num?)?.toInt() ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'roomId': roomId,
        'siteId': siteId,
        'userName': userName,
        'face': face,
        'addTime': addTime.toString(),
        'tag': tag,
        'watchCount': watchCount,
      };
}
