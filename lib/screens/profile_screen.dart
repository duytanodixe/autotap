import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/profile_local_service.dart';
import '../models/profile.dart';
import '../cubit/dot_cubit.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileLocalService _service = ProfileLocalService();
  final TextEditingController _nameCtl = TextEditingController();
  List<Profile> _profiles = const [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await _service.fetchProfiles();
      setState(() => _profiles = data);
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _addProfile() async {
    _nameCtl.clear();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Colors.grey[850],
          title: const Text('Create New Profile', style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: _nameCtl,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Enter profile name',
              hintStyle: const TextStyle(color: Colors.white54),
              filled: true,
              fillColor: Colors.grey[800],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, _nameCtl.text.trim()),
              child: const Text('Create', style: TextStyle(color: Colors.blueAccent)),
            ),
          ],
        );
      },
    );

    if (name == null || name.isEmpty) return;

    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final profile = Profile(
      id: id,
      name: name,
      createdAt: DateTime.now(),
      isActive: false,
    );

    await _service.addProfile(profile);
    await _load();
  }

  Future<void> _selectAndSetActive(Profile p) async {
    await _service.setActiveProfile(p.id);
    if (!mounted) return;

    final dotCubit = context.read<DotCubit>();
    dotCubit.setProfile(p.id);
    await dotCubit.loadDots(profileId: p.id);

    if (!mounted) return;
    Navigator.pop(context, p.id);
  }

  Future<void> _deleteProfile(Profile p) async {
    await _service.deleteProfile(p.id);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text('Profiles', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: const Color(0xFF1565C0),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.blueAccent))
          : _profiles.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.folder_open, color: Colors.white54, size: 64),
                      SizedBox(height: 16),
                      Text('No profiles', style: TextStyle(color: Colors.white70, fontSize: 18)),
                      SizedBox(height: 8),
                      Text('Tap + to create one', style: TextStyle(color: Colors.white38)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _profiles.length,
                  itemBuilder: (context, index) {
                    final p = _profiles[index];
                    return Card(
                      color: p.isActive ? const Color(0xFF1E88E5) : Colors.grey[850],
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: CircleAvatar(
                          backgroundColor: p.isActive ? Colors.blueAccent : Colors.grey[700],
                          child: const Icon(Icons.account_circle, color: Colors.white),
                        ),
                        title: Text(p.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        subtitle: Text('ID: ${p.id}', style: const TextStyle(color: Colors.white70)),
                        trailing: Wrap(
                          spacing: 4,
                          children: [
                            if (p.isActive)
                              const Icon(Icons.check_circle, color: Colors.lightGreenAccent),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.redAccent),
                              onPressed: () => _deleteProfile(p),
                            ),
                            IconButton(
                              icon: const Icon(Icons.login, color: Colors.white),
                              onPressed: () => _selectAndSetActive(p),
                            ),
                          ],
                        ),
                        onTap: () => _selectAndSetActive(p),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addProfile,
        backgroundColor: const Color(0xFF1565C0),
        child: const Icon(Icons.person_add, color: Colors.white),
      ),
    );
  }
}
