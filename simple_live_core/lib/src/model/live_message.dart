import 'dart:convert';

enum LiveMessageType {
  /// 聊天
  chat,

  /// 礼物,暂时不支持
  gift,

  /// 在线人数
  online,

  /// 醒目留言
  superChat,
}

class LiveMessage {
  /// 消息类型
  final LiveMessageType type;

  /// 用户名
  final String userName;

  /// 信息
  final String message;

  /// 数据
  /// 单Type=Online时，Data为人气值(long)
  final dynamic data;

  /// 弹幕颜色
  final LiveMessageColor color;
  LiveMessage({
    required this.type,
    required this.userName,
    required this.message,
    this.data,
    required this.color,
  });

  @override
  String toString() {
    return json.encode({
      "type": type.index,
      "userName": userName,
      "message": message,
      "data": data.toString(),
      "color": color.toString(),
    });
  }
}

class LiveMessageColor {
  final int r, g, b;
  LiveMessageColor(this.r, this.g, this.b);
  static LiveMessageColor get white => LiveMessageColor(255, 255, 255);
  static LiveMessageColor numberToColor(int intColor) {
    var obj = intColor.toRadixString(16);

    LiveMessageColor color = LiveMessageColor.white;
    if (obj.length == 4) {
      obj = "00$obj";
    }
    if (obj.length == 6) {
      var R = int.parse(obj.substring(0, 2), radix: 16);
      var G = int.parse(obj.substring(2, 4), radix: 16);
      var B = int.parse(obj.substring(4, 6), radix: 16);

      color = LiveMessageColor(R, G, B);
    }
    if (obj.length == 8) {
      var R = int.parse(obj.substring(2, 4), radix: 16);
      var G = int.parse(obj.substring(4, 6), radix: 16);
      var B = int.parse(obj.substring(6, 8), radix: 16);
      //var A = int.parse(obj.substring(0, 2), radix: 16);
      color = LiveMessageColor(R, G, B);
    }

    return color;
  }

  @override
  String toString() {
    return "#${r.toRadixString(16).padLeft(2, '0')}${g.toRadixString(16).padLeft(2, '0')}${b.toRadixString(16).padLeft(2, '0')}";
  }
}

class LiveSuperChatMessage {
  final String id;
  final String userName;
  final String face;
  final String message;
  final int price;
  final DateTime startTime;
  final DateTime endTime;
  final String backgroundColor;
  final String backgroundBottomColor;
  LiveSuperChatMessage({
    required this.id,
    required this.backgroundBottomColor,
    required this.backgroundColor,
    required this.endTime,
    required this.face,
    required this.message,
    required this.price,
    required this.startTime,
    required this.userName,
  });

  /// 缺少平台 id 时用于兜底判重的内容标识。
  String get _contentKey =>
      '$userName|${startTime.millisecondsSinceEpoch}|${endTime.millisecondsSinceEpoch}|$price|$message';

  /// 展示用稳定标识，优先使用平台 id。
  String get dedupKey => id.isNotEmpty ? id : _contentKey;

  /// 判断是否为同一条 SC。
  /// 优先使用平台提供的 id；缺少 id 时按内容和时间兜底。
  bool sameAs(LiveSuperChatMessage other) {
    if (id.isNotEmpty && other.id.isNotEmpty) {
      return id == other.id;
    }
    return _contentKey == other._contentKey;
  }

  @override
  String toString() {
    return json.encode({
      "id": id,
      "userName": userName,
      "face": face,
      "message": message,
      "price": price,
      "startTime": startTime,
      "endTime": endTime,
      "backgroundColor": backgroundColor,
      "backgroundBottomColor": backgroundBottomColor,
    });
  }
}
