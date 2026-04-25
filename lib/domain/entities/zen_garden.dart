import 'package:equatable/equatable.dart';

class Plant extends Equatable {
  final String id;
  final String type; // 'bonsai', 'flower', 'stone', 'bamboo'
  final double x;
  final double y;
  final int level;

  const Plant({
    required this.id,
    required this.type,
    required this.x,
    required this.y,
    this.level = 1,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'x': x,
    'y': y,
    'level': level,
  };

  factory Plant.fromJson(Map<String, dynamic> json) => Plant(
    id: json['id'],
    type: json['type'],
    x: json['x'].toDouble(),
    y: json['y'].toDouble(),
    level: json['level'],
  );

  @override
  List<Object?> get props => [id, type, x, y, level];
}

class ZenGarden extends Equatable {
  final int water;
  final int sunlight;
  final int exp;
  final List<Plant> plants;
  final DateTime? lastLogin;

  const ZenGarden({
    this.water = 0,
    this.sunlight = 0,
    this.exp = 0,
    this.plants = const [],
    this.lastLogin,
  });

  @override
  List<Object?> get props => [water, sunlight, exp, plants, lastLogin];

  ZenGarden copyWith({
    int? water,
    int? sunlight,
    int? exp,
    List<Plant>? plants,
    DateTime? lastLogin,
  }) {
    return ZenGarden(
      water: water ?? this.water,
      sunlight: sunlight ?? this.sunlight,
      exp: exp ?? this.exp,
      plants: plants ?? this.plants,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }
}
