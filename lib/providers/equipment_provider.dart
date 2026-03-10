import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum EquipmentSlot { hat, shirt, pants, back, face, shoes }

class EquipmentItem {
  final String name;
  final IconData icon;

  const EquipmentItem({required this.name, required this.icon});
}

class EquipmentState {
  final Map<EquipmentSlot, EquipmentItem?> slots;

  const EquipmentState({required this.slots});

  factory EquipmentState.initial() {
    return EquipmentState(
      slots: {for (final slot in EquipmentSlot.values) slot: null},
    );
  }

  EquipmentState equip(EquipmentSlot slot, EquipmentItem item) {
    return EquipmentState(slots: {...slots, slot: item});
  }

  EquipmentState unequip(EquipmentSlot slot) {
    return EquipmentState(slots: {...slots, slot: null});
  }
}

class EquipmentNotifier extends Notifier<EquipmentState> {
  @override
  EquipmentState build() => EquipmentState.initial();

  void equip(EquipmentSlot slot, EquipmentItem item) {
    state = state.equip(slot, item);
  }

  void unequip(EquipmentSlot slot) {
    state = state.unequip(slot);
  }
}

final equipmentProvider = NotifierProvider<EquipmentNotifier, EquipmentState>(
  EquipmentNotifier.new,
);

/// Helper to get the display info for each slot
IconData slotIcon(EquipmentSlot slot) {
  return switch (slot) {
    EquipmentSlot.hat => Icons.sports_motorsports,
    EquipmentSlot.shirt => Icons.checkroom,
    EquipmentSlot.pants => Icons.accessibility_new,
    EquipmentSlot.back => Icons.backpack,
    EquipmentSlot.face => Icons.face,
    EquipmentSlot.shoes => Icons.ice_skating,
  };
}

String slotLabel(EquipmentSlot slot) {
  return switch (slot) {
    EquipmentSlot.hat => 'Hat',
    EquipmentSlot.shirt => 'Shirt',
    EquipmentSlot.pants => 'Pants',
    EquipmentSlot.back => 'Back',
    EquipmentSlot.face => 'Face',
    EquipmentSlot.shoes => 'Shoes',
  };
}
