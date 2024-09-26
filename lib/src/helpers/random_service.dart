import 'dart:math';

class RandomService {
  static String generateRandomId() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final rand = Random();
    return List.generate(8, (index) => chars[rand.nextInt(chars.length)])
        .join();
  }
}
