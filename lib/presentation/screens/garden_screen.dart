import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/garden_provider.dart';
import '../../domain/entities/zen_garden.dart';

class GardenScreen extends ConsumerWidget {
  const GardenScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final garden = ref.watch(gardenProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F0), // Sand/Paper color
      appBar: AppBar(
        title: const Text('Khu vườn Zen', style: TextStyle(fontFamily: 'Serif')),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          _buildResourceChip(Icons.water_drop, garden.water.toString(), Colors.blue),
          _buildResourceChip(Icons.wb_sunny, garden.sunlight.toString(), Colors.orange),
          const SizedBox(width: 16),
        ],
      ),
      body: Stack(
        children: [
          // The Sand Ground
          Positioned.fill(
            child: CustomPaint(
              painter: SandRakePainter(),
            ),
          ),
          // The Plants/Objects
          ...garden.plants.map((plant) => Positioned(
            left: plant.x,
            top: plant.y,
            child: _buildPlantIcon(plant),
          )),
          // Interactive overlay
          GestureDetector(
            onTapDown: (details) {
              _showPlacementMenu(context, ref, details.localPosition);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildResourceChip(IconData icon, String value, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildPlantIcon(Plant plant) {
    IconData icon;
    Color color;
    switch (plant.type) {
      case 'bonsai':
        icon = Icons.park;
        color = Colors.green.shade800;
        break;
      case 'flower':
        icon = Icons.local_florist;
        color = Colors.pink.shade300;
        break;
      case 'stone':
        icon = Icons.landscape;
        color = Colors.grey.shade700;
        break;
      default:
        icon = Icons.eco;
        color = Colors.green;
    }

    return Tooltip(
      message: 'Level ${plant.level}',
      child: Icon(icon, size: 40 + (plant.level * 5).toDouble(), color: color),
    );
  }

  void _showPlacementMenu(BuildContext context, WidgetRef ref, Offset position) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Chọn vật phẩm để đặt', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMenuItem(context, ref, 'bonsai', Icons.park, position),
                  _buildMenuItem(context, ref, 'flower', Icons.local_florist, position),
                  _buildMenuItem(context, ref, 'stone', Icons.landscape, position),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuItem(BuildContext context, WidgetRef ref, String type, IconData icon, Offset position) {
    return InkWell(
      onTap: () {
        ref.read(gardenProvider.notifier).addPlant(type, position.dx, position.dy);
        Navigator.pop(context);
      },
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.grey.shade100,
            child: Icon(icon, size: 32, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          Text(type.toUpperCase(), style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

class SandRakePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Draw concentric circles to mimic raked sand
    for (var i = 0; i < size.width + size.height; i += 40) {
      canvas.drawCircle(Offset(size.width / 2, size.height / 2), i.toDouble(), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}