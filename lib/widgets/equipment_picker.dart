import 'package:flutter/material.dart';
import '../providers/equipment_provider.dart';

void showEquipmentPicker(
  BuildContext context, {
  required EquipmentSlot slot,
  required List<EquipmentItem> items,
  EquipmentItem? equipped,
  required void Function(EquipmentItem) onEquip,
  required void Function() onUnequip,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => _EquipmentPickerSheet(
      slot: slot,
      items: items,
      equipped: equipped,
      onEquip: onEquip,
      onUnequip: onUnequip,
    ),
  );
}

class _EquipmentPickerSheet extends StatelessWidget {
  final EquipmentSlot slot;
  final List<EquipmentItem> items;
  final EquipmentItem? equipped;
  final void Function(EquipmentItem) onEquip;
  final void Function() onUnequip;

  const _EquipmentPickerSheet({
    required this.slot,
    required this.items,
    required this.equipped,
    required this.onEquip,
    required this.onUnequip,
  });

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF00E5FF);
    const bg = Color(0xFF12131A);
    const surface = Color(0xFF1C1E2A);

    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.35,
      maxChildSize: 0.85,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border(
              top: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
            ),
          ),
          child: Column(
            children: [
              // Drag handle
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 4),
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: accent.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Icon(slotIcon(slot), color: accent, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          slotLabel(slot),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          equipped != null
                              ? 'Equipped: ${equipped!.name}'
                              : 'Nothing equipped',
                          style: TextStyle(
                            color: equipped != null
                                ? accent.withValues(alpha: 0.8)
                                : Colors.white.withValues(alpha: 0.35),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    if (equipped != null)
                      TextButton(
                        onPressed: () {
                          onUnequip();
                          Navigator.pop(context);
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.redAccent.withValues(
                            alpha: 0.8,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                        ),
                        child: const Text(
                          'Remove',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                  ],
                ),
              ),

              Divider(
                color: Colors.white.withValues(alpha: 0.07),
                height: 1,
              ),

              // Content
              Expanded(
                child: items.isEmpty
                    ? _buildEmpty(accent)
                    : ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          final isEquipped = equipped?.name == item.name;
                          return _ItemTile(
                            item: item,
                            isEquipped: isEquipped,
                            surface: surface,
                            accent: accent,
                            onTap: () {
                              onEquip(item);
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmpty(Color accent) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accent.withValues(alpha: 0.07),
              ),
              child: Icon(
                slotIcon(slot),
                size: 44,
                color: Colors.white.withValues(alpha: 0.15),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No ${slotLabel(slot)} items yet',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Complete missions to unlock\nnew equipment for this slot.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.35),
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ItemTile extends StatelessWidget {
  final EquipmentItem item;
  final bool isEquipped;
  final Color surface;
  final Color accent;
  final VoidCallback onTap;

  const _ItemTile({
    required this.item,
    required this.isEquipped,
    required this.surface,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isEquipped
              ? accent.withValues(alpha: 0.1)
              : surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isEquipped
                ? accent.withValues(alpha: 0.45)
                : Colors.white.withValues(alpha: 0.07),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(item.icon, color: accent, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                item.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
            if (isEquipped)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Equipped',
                  style: TextStyle(
                    color: accent,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              )
            else
              Icon(
                Icons.chevron_right_rounded,
                color: Colors.white.withValues(alpha: 0.2),
              ),
          ],
        ),
      ),
    );
  }
}
