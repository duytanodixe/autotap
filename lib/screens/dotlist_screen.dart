import 'package:flutter/material.dart';
import '../services/dot_local_service.dart';
import '../models/dot.dart';

class DotListScreen extends StatefulWidget {
  const DotListScreen({super.key});

  @override
  State<DotListScreen> createState() => _DotListScreenState();
}

class _DotListScreenState extends State<DotListScreen> {
  final DotLocalService _service = DotLocalService();
  List<Dot> _dots = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadDots();
  }

  Future<void> _loadDots() async {
    setState(() {
      _loading = true;
    });
    try {
      final dots = await _service.fetchDots();
      setState(() {
        _dots = dots;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          automaticallyImplyLeading: true,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          title: const Text(
            "Saved Dots",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          elevation: 0,
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.blueAccent),
            )
          : _dots.isEmpty
              ? const Center(
                  child: Text(
                    "Chưa có dữ liệu",
                    style: TextStyle(color: Colors.white70),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadDots,
                  child: ListView.builder(
                    itemCount: _dots.length,
                    padding: const EdgeInsets.all(12),
                    itemBuilder: (context, index) {
                      final dot = _dots[index];

                      return Card(
                        color: Colors.grey[850],
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.circle, color: Colors.blue),
                          title: Text(
                            "Dot ${dot.id}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          subtitle: Text(
                            "x: ${dot.position.dx.toInt()}, y: ${dot.position.dy.toInt()}\n"
                            "Interval: ${dot.actionIntervalTime}ms, Hold: ${dot.holdTime}ms",
                            style: const TextStyle(color: Colors.white70),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              await _service.deleteDot(dot.id);
                              _loadDots();
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
