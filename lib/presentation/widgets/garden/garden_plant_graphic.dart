import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/zen_garden.dart';

class GardenPlantGraphic extends StatelessWidget {
  final Plant plant;
  final ZenGarden garden;
  final bool isDragging;

  const GardenPlantGraphic({
    super.key,
    required this.plant,
    required this.garden,
    this.isDragging = false,
  });

  @override
  Widget build(BuildContext context) {
    String? assetPath;
    double size = 80;
    
    switch (plant.type) {
      case 'zen_bonsai':
      case 'bonsai':
        assetPath = 'assets/images/zen_bonsai.png';
        size = 100;
        break;
      case 'zen_sakura':
      case 'flower':
        assetPath = 'assets/images/zen_sakura.png';
        size = 120;
        break;
      case 'zen_stone':
      case 'stone':
      case 'bamboo':
        assetPath = 'assets/images/zen_stone.png';
        size = 70;
        break;
    }

    final isWithered = garden.water <= 0 || garden.sunlight <= 0;

    Widget graphic;
    if (assetPath != null) {
      graphic = Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            image: AssetImage(assetPath),
            fit: BoxFit.cover,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDragging ? 0.3 : 0.15),
              blurRadius: isDragging ? 20 : 10,
              offset: Offset(0, isDragging ? 8 : 4),
            )
          ],
        ),
      );
    } else {
      graphic = CircleAvatar(
        radius: size / 2,
        backgroundColor: AppColors.mossGreen,
        child: const Icon(Icons.park, color: Colors.white),
      );
    }

    if (isWithered) {
      return ColorFiltered(
        colorFilter: const ColorFilter.matrix([
          0.2126, 0.7152, 0.0722, 0, 0,
          0.2126, 0.7152, 0.0722, 0, 0,
          0.2126, 0.7152, 0.0722, 0, 0,
          0,      0,      0,      1, 0,
        ]),
        child: Opacity(opacity: 0.8, child: graphic),
      );
    }
    
    return graphic;
  }
}
