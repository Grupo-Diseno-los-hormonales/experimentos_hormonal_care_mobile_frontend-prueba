import 'dart:math';

class JitsiMeetingLinkGenerator {
  static const String _baseUrl = 'https://meet.jit.si/';

  /// Genera un enlace único para una reunión Jitsi
  static String generateMeetingLink({String? roomPrefix}) {
    final String randomString = _generateRandomString(10);
    final String roomName = roomPrefix != null ? '$roomPrefix-$randomString' : randomString;
    return '$_baseUrl$roomName';
  }

  /// Crea una cadena aleatoria para garantizar unicidad
  static String _generateRandomString(int length) {
    const String chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final Random random = Random();
    return List.generate(length, (index) => chars[random.nextInt(chars.length)]).join();
  }
}
