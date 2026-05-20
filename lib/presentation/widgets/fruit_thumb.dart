import 'package:flutter/material.dart';

/// 圆形色块占位图 + 中心首字。颜色由 fruit.colorHex 给出。
class FruitThumb extends StatelessWidget {
  const FruitThumb({
    super.key,
    required this.colorHex,
    required this.name,
    this.size = 48,
  });

  final String colorHex;
  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    final color = _hexToColor(colorHex);
    final lum = color.computeLuminance();
    final fg = lum > 0.55 ? Colors.black87 : Colors.white;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        name.isEmpty ? '?' : name.characters.first,
        style: TextStyle(
          color: fg,
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
