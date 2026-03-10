import 'package:flutter/material.dart';

class AchievementsPage extends StatelessWidget {
  const AchievementsPage({super.key});

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF00E5FF);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0F18),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Achievements',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),

            // Stats row
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Row(
                children: [
                  _StatChip(
                    label: 'Unlocked',
                    value: '0',
                    color: accent,
                  ),
                  const SizedBox(width: 12),
                  _StatChip(
                    label: 'Total',
                    value: '${_placeholderAchievements.length}',
                    color: Colors.white.withValues(alpha: 0.4),
                  ),
                ],
              ),
            ),

            // List
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                itemCount: _placeholderAchievements.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  final a = _placeholderAchievements[i];
                  return _AchievementTile(achievement: a);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Tile ─────────────────────────────────────────────────────────────────────

class _AchievementTile extends StatelessWidget {
  final _Achievement achievement;

  const _AchievementTile({required this.achievement});

  @override
  Widget build(BuildContext context) {
    const surface = Color(0xFF1C1E2A);
    const accent = Color(0xFF00E5FF);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.07),
        ),
      ),
      child: Row(
        children: [
          // Icon container — locked style
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
            child: Icon(
              achievement.icon,
              color: Colors.white.withValues(alpha: 0.15),
              size: 26,
            ),
          ),
          const SizedBox(width: 14),

          // Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.title,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.35),
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  achievement.description,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.2),
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Lock badge
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.lock_outline_rounded,
              color: Colors.white.withValues(alpha: 0.2),
              size: 16,
            ),
          ),

          // XP reward chip
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '+${achievement.xp} XP',
              style: TextStyle(
                color: accent.withValues(alpha: 0.4),
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stat chip ────────────────────────────────────────────────────────────────

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1E2A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.35),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Data ─────────────────────────────────────────────────────────────────────

class _Achievement {
  final String title;
  final String description;
  final IconData icon;
  final int xp;

  const _Achievement({
    required this.title,
    required this.description,
    required this.icon,
    required this.xp,
  });
}

const _placeholderAchievements = [
  _Achievement(
    title: 'First Steps',
    description: 'Complete your first mission.',
    icon: Icons.directions_walk_rounded,
    xp: 50,
  ),
  _Achievement(
    title: 'Well Fed',
    description: 'Log a meal for 7 days in a row.',
    icon: Icons.restaurant_rounded,
    xp: 100,
  ),
  _Achievement(
    title: 'Explorer',
    description: 'Open the map and check your location.',
    icon: Icons.map_rounded,
    xp: 30,
  ),
  _Achievement(
    title: 'Geared Up',
    description: 'Equip an item in every slot.',
    icon: Icons.checkroom_rounded,
    xp: 150,
  ),
  _Achievement(
    title: 'Mission Hunter',
    description: 'Complete 10 missions.',
    icon: Icons.task_alt_rounded,
    xp: 200,
  ),
  _Achievement(
    title: 'Level Up!',
    description: 'Reach player level 5.',
    icon: Icons.star_rounded,
    xp: 250,
  ),
  _Achievement(
    title: 'Calorie Counter',
    description: 'Log over 2,000 kcal in a single day.',
    icon: Icons.local_fire_department_rounded,
    xp: 75,
  ),
  _Achievement(
    title: 'On the Move',
    description: 'Complete 5 missions in one day.',
    icon: Icons.bolt_rounded,
    xp: 120,
  ),
];
