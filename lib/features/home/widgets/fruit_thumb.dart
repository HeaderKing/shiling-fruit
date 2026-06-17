import 'package:flutter/material.dart';

/// 圆形渐变底色 + emoji 字符显示。
class FruitThumb extends StatelessWidget {
  const FruitThumb({
    super.key,
    required this.colorHex,
    required this.name,
    this.emoji,
    this.size = 48,
  });

  final String colorHex;
  final String name;
  final String? emoji;
  final double size;

  @override
  Widget build(BuildContext context) {
    final color = _hexToColor(colorHex);
    final hsl = HSLColor.fromColor(color);
    final lighter = hsl
        .withLightness((hsl.lightness + 0.2).clamp(0.0, 1.0))
        .toColor();
    final softer = hsl
        .withLightness((hsl.lightness + 0.35).clamp(0.0, 1.0))
        .withSaturation((hsl.saturation * 0.6).clamp(0.0, 1.0))
        .toColor();
    final useEmoji = (emoji ?? '').isNotEmpty;
    final lum = color.computeLuminance();
    final fallbackFg = lum > 0.55 ? Colors.black87 : Colors.white;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [softer, lighter],
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.18),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: useEmoji
          ? Text(
              emoji!,
              style: TextStyle(fontSize: size * 0.58, height: 1),
            )
          : Text(
              name.isEmpty ? '?' : name.characters.first,
              style: TextStyle(
                color: fallbackFg,
                fontSize: size * 0.42,
                fontWeight: FontWeight.w700,
              ),
            ),
    );
  }

  static Color _hexToColor(String hex) {
    var h = hex.replaceAll('#', '');
    if (h.length == 6) h = 'FF$h';
    return Color(int.parse(h, radix: 16));
  }
}