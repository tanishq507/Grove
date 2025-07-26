import 'package:flutter/material.dart';

class ForestBackground extends StatelessWidget {
  final Widget child;

  const ForestBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF4A90E2), // Deep sky blue
            Color(0xFF7BB3F0), // Medium sky blue
            Color(0xFFA8D5BA), // Light mint green
            Color(0xFF88C999), // Medium green
            Color(0xFF2E7D32), // Deep forest green
          ],
          stops: [0.0, 0.25, 0.5, 0.75, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Sun
          Positioned(
            top: 50,
            right: 50,
            child: Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Color(0xFFFFF176),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x40FFF176),
                    blurRadius: 20,
                    spreadRadius: 10,
                  ),
                ],
              ),
            ),
          ),
          // Clouds
          Positioned(
            top: 80,
            left: 30,
            child: _buildCloud(),
          ),
          Positioned(
            top: 120,
            right: 80,
            child: _buildCloud(),
          ),
          Positioned(
            top: 60,
            left: 150,
            child: _buildCloud(),
          ),
          // Ground elements
          Positioned(
            bottom: 20,
            left: 20,
            child: _buildGrass(),
          ),
          Positioned(
            bottom: 15,
            right: 40,
            child: _buildGrass(),
          ),
          child,
        ],
      ),
    );
  }

  Widget _buildCloud() {
    return Row(
      children: [
        Container(
          width: 35,
          height: 25,
          decoration: const BoxDecoration(
            color: Color(0xFFF5F5F5),
            borderRadius: BorderRadius.all(Radius.circular(15)),
          ),
        ),
        Container(
          width: 45,
          height: 30,
          decoration: const BoxDecoration(
            color: Color(0xFFF5F5F5),
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
        ),
        Container(
          width: 38,
          height: 26,
          decoration: const BoxDecoration(
            color: Color(0xFFF5F5F5),
            borderRadius: BorderRadius.all(Radius.circular(18)),
          ),
        ),
      ],
    );
  }

  Widget _buildGrass() {
    return Row(
      children: List.generate(
          5,
          (index) => Container(
                width: 3,
                height: 15 + (index % 3) * 5,
                margin: const EdgeInsets.only(right: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50),
                  borderRadius: BorderRadius.circular(2),
                ),
              )),
    );
  }
}
