import 'package:flutter/material.dart';

enum Season { spring, summer, autumn, winter }

class SeasonPalette {
  SeasonPalette._({
    required this.season,
    required this.label,
    required this.icon,
    required this.primary,
    required this.gradient,
    required this.softBg,
  });

  final Season season;
  final String label;
  final String icon;
  final Color primary;
  final List<Color> gradient;
  final Color softBg;

  static SeasonPalette of(int month) {
    if (month >= 3 && month <= 5) return _spring;
    if (month >= 6 && month <= 8) return _summer;
    if (month >= 9 && month <= 11) return _autumn;
    return _winter;
  }

  static final _spring = SeasonPalette._(
    season: Season.spring,
    label: '春',
    icon: '🌸',
    primary: const Color(0xFFEC7B8C),
    gradient: const [Color(0xFFFFE4EC), Color(0xFFFFC1D2)],
    softBg: const Color(0xFFFFF5F8),
  );

  static final _summer = SeasonPalette._(
    season: Season.summer,
    label: '夏',
    icon: '☀️',
    primary: const Color(0xFFFFA94D),
    gradient: const [Color(0xFFFFEFD9), Color(0xFFFFD18A)],
    softBg: const Color(0xFFFFF8EC),
  );

  static final _autumn = SeasonPalette._(
    season: Season.autumn,
    label: '秋',
    icon: '🍁',
    primary: const Color(0xFFE17055),
    gradient: const [Color(0xFFFFE3D5), Color(0xFFF6B98B)],
    softBg: const Color(0xFFFFF3EC),
  );

  static final _winter = SeasonPalette._(
    season: Season.winter,
    label: '冬',
    icon: '❄️',
    primary: const Color(0xFF6FA8DC),
    gradient: const [Color(0xFFE3F0FF), Color(0xFFB6D3F2)],
    softBg: const Color(0xFFF1F7FF),
  );
}
