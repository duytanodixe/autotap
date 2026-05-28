import 'package:flutter/material.dart';
import 'browser_screen.dart';
import '../utils/constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isPressed = false;

  void _goToBrowser() {
    String url = _controller.text.trim();

    if (url.isNotEmpty) {
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        url = 'https://$url';
      }
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => BrowserScreen(url: url)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập URL')),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(AppConstants.backgroundDark),

      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(AppConstants.appBarHeight),
        child: Container(
          padding: const EdgeInsets.only(
            top: 40,
            left: 20,
            right: 20,
            bottom: 20,
          ),
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
              BoxShadow(
                color: Colors.white10,
                offset: Offset(0, -1),
                blurRadius: 8,
              ),
            ],
          ),
          child: Center(
            child: Text(
              AppConstants.appName,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),

      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.largePadding),
          child: Container(
            padding: const EdgeInsets.all(AppConstants.extraPadding),
            decoration: BoxDecoration(
              color: const Color(AppConstants.cardDark),
              borderRadius: BorderRadius.circular(AppConstants.ultraLargeRadius),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black87,
                  offset: Offset(4, 4),
                  blurRadius: 12,
                ),
                BoxShadow(
                  color: Colors.white10,
                  offset: Offset(-4, -4),
                  blurRadius: 12,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Enter website URL',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(AppConstants.inputDark),
                    borderRadius: BorderRadius.circular(AppConstants.largeRadius),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black54,
                        offset: Offset(3, 3),
                        blurRadius: 6,
                      ),
                      BoxShadow(
                        color: Colors.white10,
                        offset: Offset(-3, -3),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _controller,
                    keyboardType: TextInputType.url,
                    textInputAction: TextInputAction.go,
                    onSubmitted: (_) => _goToBrowser(),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Ex: google.com',
                      hintStyle: TextStyle(
                        color: Colors.grey.withValues(alpha: 0.6),
                        fontStyle: FontStyle.italic,
                      ),
                      prefixIcon: const Icon(Icons.language, color: Colors.blueAccent),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                GestureDetector(
                  onTapDown: (_) => setState(() => _isPressed = true),
                  onTapUp: (_) {
                    setState(() => _isPressed = false);
                    _goToBrowser();
                  },
                  onTapCancel: () => setState(() => _isPressed = false),
                  child: AnimatedContainer(
                    duration: AppConstants.mediumAnimation,
                    height: 50,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF42A5F5), Color(0xFF1565C0)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(AppConstants.largeRadius),
                      boxShadow: _isPressed
                          ? const [
                              BoxShadow(
                                color: Colors.black54,
                                offset: Offset(1, 1),
                                blurRadius: 4,
                              ),
                              BoxShadow(
                                color: Colors.white10,
                                offset: Offset(-1, -1),
                                blurRadius: 4,
                              ),
                            ]
                          : const [
                              BoxShadow(
                                color: Colors.black87,
                                offset: Offset(4, 4),
                                blurRadius: 10,
                              ),
                              BoxShadow(
                                color: Colors.white10,
                                offset: Offset(-4, -4),
                                blurRadius: 10,
                              ),
                            ],
                    ),
                    child: const Center(
                      child: Text(
                        'Browse',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
