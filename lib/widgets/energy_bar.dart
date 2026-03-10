import 'package:flutter/material.dart';

class EnergyBar extends StatelessWidget {
  final double energy;
  final double maxEnergy;

  const EnergyBar({super.key, required this.energy, required this.maxEnergy});

  double get _percent => (energy / maxEnergy).clamp(0.0, 1.0);

  Color get _barColor {
    if (_percent > 0.6) return const Color(0xFF00E676);
    if (_percent > 0.3) return const Color(0xFFFFD600);
    return const Color(0xFFFF5252);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _barColor.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bolt_rounded, color: _barColor, size: 22),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${energy.toInt()}/${maxEnergy.toInt()}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: 4),
              SizedBox(
                width: 70,
                height: 6,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: _percent,
                    backgroundColor: Colors.white.withValues(alpha: 0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(_barColor),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
