/// Kayan noktalı sayı (floating-point) hatasını önlemek için
/// tüm parasal tutarları kuruş (int) cinsinden tutan değer nesnesi.
class Money {
  const Money(this.kurus);

  const Money.zero() : kurus = 0;

  /// Kuruş cinsinden tam sayı tutar. Örn: 125075 -> 1.250,75 ₺
  final int kurus;

  bool get isNegative => kurus < 0;
  bool get isZero => kurus == 0;
  bool get isPositive => kurus > 0;

  Money operator +(Money other) => Money(kurus + other.kurus);
  Money operator -(Money other) => Money(kurus - other.kurus);
  Money operator -() => Money(-kurus);

  /// Kullanıcı girdisini (örn: "1.250,75", "1250.75", "1250", "-50,5")
  /// kayan noktalı sayı kullanmadan kuruş cinsine çevirir.
  static Money? tryParse(String raw) {
    final cleaned = raw.trim().replaceAll('₺', '').replaceAll(' ', '');
    if (cleaned.isEmpty) return null;

    final isNeg = cleaned.startsWith('-');
    final unsigned = isNeg ? cleaned.substring(1) : cleaned;
    if (unsigned.isEmpty) return null;

    // Hem virgül hem nokta varsa: son ayırıcı ondalık, diğeri binlik ayırıcıdır.
    String normalized = unsigned;
    final hasComma = normalized.contains(',');
    final hasDot = normalized.contains('.');

    if (hasComma && hasDot) {
      final lastComma = normalized.lastIndexOf(',');
      final lastDot = normalized.lastIndexOf('.');
      if (lastComma > lastDot) {
        normalized = normalized.replaceAll('.', '').replaceAll(',', '.');
      } else {
        normalized = normalized.replaceAll(',', '');
      }
    } else if (hasComma) {
      normalized = normalized.replaceAll(',', '.');
    } else if (hasDot) {
      // Birden fazla nokta varsa binlik ayırıcıdır.
      final dotCount = '.'.allMatches(normalized).length;
      if (dotCount > 1) {
        normalized = normalized.replaceAll('.', '');
      }
    }

    final parts = normalized.split('.');
    if (parts.length > 2) return null;

    final wholeStr = parts[0].isEmpty ? '0' : parts[0];
    final whole = int.tryParse(wholeStr);
    if (whole == null) return null;

    int frac = 0;
    if (parts.length == 2 && parts[1].isNotEmpty) {
      final fracRaw = parts[1];
      if (int.tryParse(fracRaw) == null) return null;
      if (fracRaw.length == 1) {
        frac = int.parse(fracRaw) * 10;
      } else {
        frac = int.parse(fracRaw.substring(0, 2));
      }
    }

    final totalKurus = whole * 100 + frac;
    return Money(isNeg ? -totalKurus : totalKurus);
  }

  /// Tutarın Türkçe para birimi formatında gösterimi: "1.250,75 ₺"
  String format({bool showSign = false}) {
    final absKurus = kurus.abs();
    final whole = absKurus ~/ 100;
    final frac = absKurus % 100;

    final wholeDigits = whole.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < wholeDigits.length; i++) {
      final reverseIndex = wholeDigits.length - i;
      buffer.write(wholeDigits[i]);
      if (reverseIndex > 1 && reverseIndex % 3 == 1) {
        buffer.write('.');
      }
    }

    final fracStr = frac.toString().padLeft(2, '0');
    final prefix = kurus < 0
        ? '-'
        : (showSign && kurus > 0 ? '+' : '');
    return '$prefix${buffer.toString()},$fracStr ₺';
  }

  @override
  bool operator ==(Object other) => other is Money && other.kurus == kurus;

  @override
  int get hashCode => kurus.hashCode;

  @override
  String toString() => format();
}
