import 'package:flutter_riverpod/flutter_riverpod.dart';

class PlayerState {
  final int level;
  final double exp;
  final double maxExp;
  final double energy;
  final double maxEnergy;

  const PlayerState({
    this.level = 1,
    this.exp = 350,
    this.maxExp = 1000,
    this.energy = 80,
    this.maxEnergy = 100,
  });

  PlayerState copyWith({
    int? level,
    double? exp,
    double? maxExp,
    double? energy,
    double? maxEnergy,
  }) {
    return PlayerState(
      level: level ?? this.level,
      exp: exp ?? this.exp,
      maxExp: maxExp ?? this.maxExp,
      energy: energy ?? this.energy,
      maxEnergy: maxEnergy ?? this.maxEnergy,
    );
  }

  double get expPercent => exp / maxExp;
  double get energyPercent => energy / maxEnergy;
}

class PlayerNotifier extends Notifier<PlayerState> {
  @override
  PlayerState build() => const PlayerState();

  void addExp(double amount) {
    var newExp = state.exp + amount;
    var newLevel = state.level;
    var newMaxExp = state.maxExp;

    while (newExp >= newMaxExp) {
      newExp -= newMaxExp;
      newLevel++;
      newMaxExp = newMaxExp * 1.2;
    }

    state = state.copyWith(level: newLevel, exp: newExp, maxExp: newMaxExp);
  }

  void setEnergy(double value) {
    state = state.copyWith(energy: value.clamp(0, state.maxEnergy));
  }
}

final playerProvider = NotifierProvider<PlayerNotifier, PlayerState>(
  PlayerNotifier.new,
);
