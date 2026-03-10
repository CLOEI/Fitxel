import 'package:flutter_riverpod/flutter_riverpod.dart';

class Mission {
  final String id;
  final String title;
  final String description;
  final String icon;
  final double progress; // 0.0 – 1.0
  final int reward;

  const Mission({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    this.progress = 0.0,
    this.reward = 50,
  });

  Mission copyWith({double? progress}) {
    return Mission(
      id: id,
      title: title,
      description: description,
      icon: icon,
      progress: progress ?? this.progress,
      reward: reward,
    );
  }
}

final missionProvider = Provider<List<Mission>>((ref) {
  return const [
    Mission(
      id: '1',
      title: 'Morning Jog',
      description: 'Run 2 km to earn bonus EXP',
      icon: '🏃',
      progress: 0.6,
      reward: 100,
    ),
    Mission(
      id: '2',
      title: 'Push-Up Challenge',
      description: 'Complete 30 push-ups',
      icon: '💪',
      progress: 0.3,
      reward: 75,
    ),
    Mission(
      id: '3',
      title: 'Hydration Goal',
      description: 'Drink 8 glasses of water today',
      icon: '💧',
      progress: 0.85,
      reward: 50,
    ),
    Mission(
      id: '4',
      title: 'Step Counter',
      description: 'Walk 10,000 steps',
      icon: '👟',
      progress: 0.45,
      reward: 120,
    ),
  ];
});
