import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class TutorialScreen extends StatefulWidget {
  const TutorialScreen({super.key});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  final PageController _controller = PageController();
  int _currentStep = 0;

  final List<Map<String, String>> _tutorials = List.generate(9, (index) {
    return {
      "image": "assets/images/guide_${index + 1}.jpg",
      "title": "Step ${index + 1}: Sample Title",
      "desc": "Description for step ${index + 1}.",
    };
  });

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      int page = _controller.page?.round() ?? 0;
      if (_currentStep != page) {
        setState(() {
          _currentStep = page;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = _tutorials[_currentStep];

    return Scaffold(
      backgroundColor: const Color(0xFF101820), // nền đen

      // ===== HEADER =====
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: Container(
          padding:
              const EdgeInsets.only(top: 40, left: 20, right: 20, bottom: 20),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black54,
                offset: Offset(0, 4),
                blurRadius: 10,
              ),
            ],
          ),
          child: const Center(
            child: Text(
              'Tutorial',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),

      body: SafeArea(
        child: Column(
          children: [
            // Hình minh họa
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _tutorials.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(20),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        _tutorials[index]["image"]!,
                        fit: BoxFit.contain,
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 15),

            // Dấu chấm chuyển trang
            SmoothPageIndicator(
              controller: _controller,
              count: _tutorials.length,
              effect: const WormEffect(
                activeDotColor: Color(0xFF42A5F5),
                dotColor: Colors.white24,
                dotHeight: 8,
                dotWidth: 8,
              ),
            ),

            const SizedBox(height: 20),

            // Tiêu đề
            Text(
              item["title"]!,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),

            // Mô tả
            Text(
              item["desc"]!,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20),

            // Ghi chú
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Note: Due to the limitations of the Apple system, clicks '
                'outside the application can only be achieved through the settings mentioned above.',
                style: TextStyle(color: Colors.redAccent, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 10),

            // Friendly reminder
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Friendly reminder:\n'
                '1. Once Apple opens the corresponding interface, we will implement external clicks as soon as possible.\n'
                '2. You can also use a non-iPhone version of GA Auto Clicker to achieve external clicks.',
                style: TextStyle(color: Colors.white70, fontSize: 14),
                textAlign: TextAlign.left,
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
