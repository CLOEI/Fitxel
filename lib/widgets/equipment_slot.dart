import 'dart:ui';
import 'package:flutter/material.dart';

class EquipmentSlotWidget extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool hasItem;
  final VoidCallback? onTap;

  const EquipmentSlotWidget({
    super.key,
    required this.icon,
    required this.label,
    this.hasItem = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: hasItem
                      ? const Color(0xFF00E5FF).withValues(alpha: 0.15)
                      : Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: hasItem
                        ? const Color(0xFF00E5FF).withValues(alpha: 0.5)
                        : Colors.white.withValues(alpha: 0.15),
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  icon,
                  color: hasItem
                      ? const Color(0xFF00E5FF)
                      : Colors.white.withValues(alpha: 0.3),
                  size: 24,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.5),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
