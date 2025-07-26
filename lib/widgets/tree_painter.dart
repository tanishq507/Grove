import 'package:flutter/material.dart';
import '../models/tree_species.dart';
import '../models/garden_state.dart';

class TreePainter extends CustomPainter {
  final GardenTree tree;
  final TreeSpecies species;

  TreePainter({required this.tree, required this.species});

  @override
  void paint(Canvas canvas, Size size) {
    final stage = tree.currentStage.toString();
    final stageData = species.renderingParameters['stages'][stage];
    
    if (stageData == null) return;

    switch (species.speciesId) {
      case 'oak':
        _paintOakTree(canvas, stageData);
        break;
      case 'pine':
        _paintPineTree(canvas, stageData);
        break;
      case 'willow':
        _paintWillowTree(canvas, stageData);
        break;
    }
  }

  void _paintOakTree(Canvas canvas, Map<String, dynamic> stageData) {
    final trunkPaint = Paint()
      ..color = Color(species.renderingParameters['baseColor'])
      ..style = PaintingStyle.fill;

    final leafPaint = Paint()
      ..color = Color(species.renderingParameters['leafColor'])
      ..style = PaintingStyle.fill;

    final height = stageData['height'].toDouble();
    final width = stageData['width'].toDouble();
    final branches = stageData['branches'] as int;

    // Draw trunk
    final trunkWidth = width * 0.2;
    final trunkHeight = height * 0.4;
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(width / 2, height - trunkHeight / 2),
        width: trunkWidth,
        height: trunkHeight,
      ),
      trunkPaint,
    );

    // Draw crown (circular canopy)
    final crownRadius = width * 0.35;
    canvas.drawCircle(
      Offset(width / 2, height * 0.4),
      crownRadius,
      leafPaint,
    );

    // Draw additional leaf clusters for mature stage
    for (int i = 0; i < branches; i++) {
      final angle = (i * 2 * 3.14159) / branches;
      final offsetX = (crownRadius * 0.6) * (i % 2 == 0 ? 1 : -1);
      final offsetY = (i * height * 0.05);
      final branchX = width / 2 + offsetX;
      final branchY = height * 0.35 + offsetY;

      canvas.drawCircle(
        Offset(branchX, branchY),
        width * 0.12,
        leafPaint,
      );
    }
  }

  void _paintPineTree(Canvas canvas, Map<String, dynamic> stageData) {
    final trunkPaint = Paint()
      ..color = Color(species.renderingParameters['baseColor'])
      ..style = PaintingStyle.fill;

    final leafPaint = Paint()
      ..color = Color(species.renderingParameters['leafColor'])
      ..style = PaintingStyle.fill;

    final height = stageData['height'].toDouble();
    final width = stageData['width'].toDouble();
    final layers = stageData['layers'] as int;

    // Draw trunk
    final trunkWidth = width * 0.15;
    final trunkHeight = height * 0.25;
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(width / 2, height - trunkHeight / 2),
        width: trunkWidth,
        height: trunkHeight,
      ),
      trunkPaint,
    );

    // Draw pine layers
    for (int i = 0; i < layers; i++) {
      final layerY = height * 0.75 - (i * height * 0.15);
      final layerWidth = width * (0.9 - i * 0.1);
      
      final path = Path();
      path.moveTo(width / 2, layerY - height * 0.12);
      path.lineTo(width / 2 - layerWidth / 2, layerY);
      path.lineTo(width / 2 + layerWidth / 2, layerY);
      path.close();

      canvas.drawPath(path, leafPaint);
    }

    // Add top point
    final topPath = Path();
    topPath.moveTo(width / 2, 0);
    topPath.lineTo(width / 2 - width * 0.1, height * 0.15);
    topPath.lineTo(width / 2 + width * 0.1, height * 0.15);
    topPath.close();
    canvas.drawPath(topPath, leafPaint);
  }

  void _paintWillowTree(Canvas canvas, Map<String, dynamic> stageData) {
    final trunkPaint = Paint()
      ..color = Color(species.renderingParameters['baseColor'])
      ..style = PaintingStyle.fill;

    final branchPaint = Paint()
      ..color = Color(species.renderingParameters['leafColor'])
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final leafPaint = Paint()
      ..color = Color(species.renderingParameters['leafColor'])
      ..style = PaintingStyle.fill;

    final height = stageData['height'].toDouble();
    final width = stageData['width'].toDouble();
    final droopiness = stageData['droopiness'].toDouble();

    // Draw trunk
    final trunkWidth = width * 0.18;
    final trunkHeight = height * 0.35;
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(width / 2, height - trunkHeight / 2),
        width: trunkWidth,
        height: trunkHeight,
      ),
      trunkPaint,
    );

    // Draw main canopy
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(width / 2, height * 0.45),
        width: width * 0.7,
        height: height * 0.3,
      ),
      leafPaint,
    );

    // Draw drooping branches
    final branchCount = (width / 12).round();
    for (int i = 0; i < branchCount; i++) {
      final startX = width / 2 + (i - branchCount / 2) * width * 0.12;
      final startY = height * 0.55;
      final endX = startX + (i % 2 == 0 ? 1 : -1) * width * droopiness * 0.25;
      final endY = height * (0.75 + droopiness * 0.15);

      final path = Path();
      path.moveTo(startX, startY);
      path.quadraticBezierTo(
        startX + (endX - startX) * 0.3,
        startY + (endY - startY) * 0.7,
        endX,
        endY,
      );

      canvas.drawPath(path, branchPaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}