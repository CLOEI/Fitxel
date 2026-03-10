import 'dart:async';
import 'dart:math';
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

const _dialogLines = [
  'Hey! What you did that for?',
  'Ouch, that tickles!',
  "I'm trying to idle here...",
  'Could you please not?',
  'I saw nothing.',
  "Leave me alone, I'm training!",
  '...',
];

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  late final FitxelGame _game;
  String? _dialogMessage;
  Timer? _dialogTimer;
  int _lastDialogIndex = -1;

  @override
  void initState() {
    super.initState();
    _game = FitxelGame(onCharacterTapped: _onCharacterTapped);
  }

  @override
  void dispose() {
    _dialogTimer?.cancel();
    super.dispose();
  }

  void _onCharacterTapped() {
    _dialogTimer?.cancel();

    // Pick a line that's different from the last one
    int index;
    do {
      index = Random().nextInt(_dialogLines.length);
    } while (index == _lastDialogIndex && _dialogLines.length > 1);
    _lastDialogIndex = index;

    setState(() => _dialogMessage = _dialogLines[index]);

    _dialogTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _dialogMessage = null);
    });
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

                    // Center: Flame game + speech bubble overlay
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          // Character is centered; at 6× scale it is 192 px tall.
                          // Head sits 96 px above center. Bubble is anchored 12 px
                          // above the head, so its bottom is (h/2 - 108) from top,
                          // which equals (h/2 + 108) from the bottom of the Stack.
                          final bubbleBottom =
                              constraints.maxHeight / 2 + 72;
                          return Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.white
                                          .withValues(alpha: 0.08),
                                      width: 1,
                                    ),
                                  ),
                                  child: GameWidget(game: _game),
                                ),
                              ),

                              // Speech bubble – grows upward from bubbleBottom
                              Positioned(
                                bottom: bubbleBottom,
                                left: 0,
                                right: 0,
                                child: Center(
                                  child: AnimatedSwitcher(
                                    duration:
                                        const Duration(milliseconds: 200),
                                    transitionBuilder: (child, animation) =>
                                        FadeTransition(
                                      opacity: animation,
                                      child: ScaleTransition(
                                        scale: animation,
                                        alignment: Alignment.bottomCenter,
                                        child: child,
                                      ),
                                    ),
                                    child: _dialogMessage != null
                                        ? _CharacterSpeechBubble(
                                            key: ValueKey(_dialogMessage),
                                            message: _dialogMessage!,
                                          )
                                        : const SizedBox.shrink(
                                            key: ValueKey<String?>('none'),
                                          ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
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

class _CharacterSpeechBubble extends StatelessWidget {
  final String message;

  const _CharacterSpeechBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          constraints: const BoxConstraints(maxWidth: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E).withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFF00E5FF).withValues(alpha: 0.4),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00E5FF).withValues(alpha: 0.15),
                blurRadius: 12,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
        ),
        // Downward pointer triangle
        CustomPaint(
          size: const Size(14, 8),
          painter: _TrianglePainter(
            color: const Color(0xFF00E5FF).withValues(alpha: 0.4),
            fill: const Color(0xFF1A1A2E).withValues(alpha: 0.92),
          ),
        ),
      ],
    );
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;
  final Color fill;

  const _TrianglePainter({required this.color, required this.fill});

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();

    canvas.drawPath(path, Paint()..color = fill);
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(_TrianglePainter old) =>
      old.color != color || old.fill != fill;
}
