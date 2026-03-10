import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../game/fitxel_game.dart';
import '../providers/player_provider.dart';
import '../providers/equipment_provider.dart';
import '../providers/mission_provider.dart';
import '../widgets/level_badge.dart';
import '../widgets/energy_bar.dart';
import '../widgets/equipment_slot.dart';
import '../widgets/equipment_picker.dart';
import '../widgets/mission_card.dart';
import 'missions_page.dart';
import 'profile_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  late final FitxelGame _game;

  @override
  void initState() {
    super.initState();
    _game = FitxelGame();
  }

  @override
  Widget build(BuildContext context) {
    final player = ref.watch(playerProvider);
    final equipment = ref.watch(equipmentProvider);
    final missions = ref.watch(missionProvider);

    // Left equipment slots: Hat, Shirt, Pants
    final leftSlots = [
      EquipmentSlot.hat,
      EquipmentSlot.shirt,
      EquipmentSlot.pants,
    ];
    // Right equipment slots: Back, Face, Shoes
    final rightSlots = [
      EquipmentSlot.back,
      EquipmentSlot.face,
      EquipmentSlot.shoes,
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ─── Top Bar: Level + Energy ───
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  LevelBadge(
                    level: player.level,
                    expPercent: player.expPercent,
                  ),
                  EnergyBar(energy: player.energy, maxEnergy: player.maxEnergy),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ProfilePage(),
                      ),
                    ),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF00E5FF).withValues(alpha: 0.1),
                        border: Border.all(
                          color: const Color(0xFF00E5FF).withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        color: Color(0xFF00E5FF),
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ─── Game View with Equipment Slots ───
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  children: [
                    // Left equipment column
                    SizedBox(
                      width: 64,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: leftSlots.map((slot) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6.0),
                            child: EquipmentSlotWidget(
                              icon: slotIcon(slot),
                              label: slotLabel(slot),
                              hasItem: equipment.slots[slot] != null,
                              onTap: () => showEquipmentPicker(
                                context,
                                slot: slot,
                                items: const [],
                                equipped: equipment.slots[slot],
                                onEquip: (item) => ref
                                    .read(equipmentProvider.notifier)
                                    .equip(slot, item),
                                onUnequip: () => ref
                                    .read(equipmentProvider.notifier)
                                    .unequip(slot),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    // Center: Flame game
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.08),
                              width: 1,
                            ),
                          ),
                          child: GameWidget(game: _game),
                        ),
                      ),
                    ),

                    // Right equipment column
                    SizedBox(
                      width: 64,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: rightSlots.map((slot) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6.0),
                            child: EquipmentSlotWidget(
                              icon: slotIcon(slot),
                              label: slotLabel(slot),
                              hasItem: equipment.slots[slot] != null,
                              onTap: () => showEquipmentPicker(
                                context,
                                slot: slot,
                                items: const [],
                                equipped: equipment.slots[slot],
                                onEquip: (item) => ref
                                    .read(equipmentProvider.notifier)
                                    .equip(slot, item),
                                onUnequip: () => ref
                                    .read(equipmentProvider.notifier)
                                    .unequip(slot),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ─── Missions Section ───
            Expanded(
              flex: 2,
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.04),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  border: Border(
                    top: BorderSide(
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Missions',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const MissionsPage(),
                            ),
                          ),
                          child: Text(
                            'See All',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: const Color(
                                0xFF00E5FF,
                              ).withValues(alpha: 0.8),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: missions.length,
                        itemBuilder: (context, index) {
                          final m = missions[index];
                          return MissionCard(
                            icon: m.icon,
                            title: m.title,
                            description: m.description,
                            progress: m.progress,
                            reward: m.reward,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
