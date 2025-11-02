import 'package:flutter/material.dart';
import 'bottom_nav.dart';

class MissionsMenuScreen extends StatelessWidget {
  const MissionsMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1a1a2e),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1a1a2e), Color(0xFF0f0f1e)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Content area
              Expanded(
                child: Center(
                  child: Text(
                    'MISSIONS',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              
              // Bottom navigation
              BottomNavBar(currentPage: 'missions'),
            ],
          ),
        ),
      ),
    );
  }
}