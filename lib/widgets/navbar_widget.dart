import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/tutorial_screen.dart';
import '../screens/action_screen.dart';
class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;

  const CustomBottomNavBar({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: const Color(0xFF1C1F26),
      selectedItemColor: const Color(0xFF42A5F5),
      unselectedItemColor: Colors.white54,
      currentIndex: currentIndex,
      onTap: (index) {
        if (index == currentIndex) return; // không làm gì nếu bấm đúng nút hiện tại

        switch (index) {
          case 0:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
            break;
          case 1:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const TutorialScreen()),
            );
            break;
          case 2:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const ActionScreen()),
            );
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.public), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Tutorial'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
      ],
    );
  }
}
