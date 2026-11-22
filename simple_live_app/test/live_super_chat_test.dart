import 'package:flutter_test/flutter_test.dart';
import 'package:simple_live_core/simple_live_core.dart';

void main() {
  LiveSuperChatMessage createSuperChat({
    String id = '',
    String userName = '测试用户',
    String message = '测试 SC',
    int price = 30,
    DateTime? startTime,
    DateTime? endTime,
  }) =>
      LiveSuperChatMessage(
        id: id,
        backgroundBottomColor: '#000000',
        backgroundColor: '#000000',
        endTime: endTime ?? DateTime(2026, 1, 1, 12, 1),
        face: 'https://example.com/face.jpg',
        message: message,
        price: price,
        startTime: startTime ?? DateTime(2026, 1, 1, 12, 0),
        userName: userName,
      );

  group('LiveSuperChatMessage.sameAs', () {
    test('相同 id 视为同一条 SC', () {
      var a = createSuperChat(id: 'sc-1', message: 'A');
      var b = createSuperChat(id: 'sc-1', message: 'B');
      expect(a.sameAs(b), isTrue);
    });

    test('都没有 id 时按内容、时间和价格判断', () {
      var a = createSuperChat();
      var b = createSuperChat();
      expect(a.sameAs(b), isTrue);
    });

    test('都没有 id 且内容不同视为不同 SC', () {
      var a = createSuperChat(message: 'A');
      var b = createSuperChat(message: 'B');
      expect(a.sameAs(b), isFalse);
    });

    test('一方缺少 id 时按内容兜底判断', () {
      var a = createSuperChat(id: 'sc-1');
      var b = createSuperChat();
      expect(a.sameAs(b), isTrue);
    });

    test('双方 id 不同视为不同 SC', () {
      var a = createSuperChat(id: 'sc-1');
      var b = createSuperChat(id: 'sc-2');
      expect(a.sameAs(b), isFalse);
    });
  });
}
