import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/profile_local_service.dart';
import '../models/profile.dart';
import '../cubit/dot_cubit.dart';
import '../utils/constants.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

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

  @override
  void dispose() {
    _nameCtl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await _service.fetchProfiles();
      setState(() {
        _profiles = data;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  Future<void> _addProfile() async {
    _nameCtl.clear();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.grey[850],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.extraLargeRadius),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Create New Profile',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _nameCtl,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Enter profile name',
                    hintStyle: const TextStyle(color: Colors.white54),
                    filled: true,
                    fillColor: Colors.grey[800],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppConstants.largeRadius),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => Navigator.pop(ctx, _nameCtl.text.trim()),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(AppConstants.largeRadius),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.blueAccent,
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 10,
                        ),
                        child: const Text(
                          'Create',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
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
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey[850],
        title: const Text('Delete Profile', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to delete "${p.name}"?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _service.deleteProfile(p.id);
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(AppConstants.miniAppBarHeight),
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
            'Profiles',
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
          : _profiles.isEmpty
              ? const Center(
                  child: Text(
                    'No profiles',
                    style: TextStyle(color: Colors.white70),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(12),
                    itemCount: _profiles.length,
                    itemBuilder: (context, index) {
                      final p = _profiles[index];
                      final isActive = p.isActive;
                      return AnimatedContainer(
                        duration: AppConstants.longAnimation,
                        curve: Curves.easeOut,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            AppConstants.extraLargeRadius,
                          ),
                          gradient: LinearGradient(
                            colors: isActive
                                ? const [
                                    Color(0xFF1E88E5),
                                    Color(0xFF42A5F5),
                                  ]
                                : const [
                                    Color(0xFF2C2C2C),
                                    Color(0xFF1A1A1A),
                                  ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            if (isActive)
                              BoxShadow(
                                color: Colors.blueAccent.withValues(alpha: 0.6),
                                blurRadius: 12,
                                spreadRadius: 1,
                              )
                            else
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.5),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: CircleAvatar(
                            radius: AppConstants.profileAvatarRadius,
                            backgroundColor:
                                isActive ? Colors.blueAccent : Colors.grey[700],
                            child: const Icon(
                              Icons.account_circle_rounded,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                          title: Text(
                            p.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Text(
                            'ID: ${p.id}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                          trailing: Wrap(
                            spacing: 4,
                            children: [
                              if (isActive)
                                const Icon(
                                  Icons.verified_rounded,
                                  color: Colors.lightGreenAccent,
                                ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_forever_rounded,
                                  color: Colors.redAccent,
                                ),
                                onPressed: () => _deleteProfile(p),
                                splashRadius: 24,
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.login_rounded,
                                  color: Colors.white,
                                ),
                                onPressed: () => _selectAndSetActive(p),
                                splashRadius: 24,
                              ),
                            ],
                          ),
                          onTap: () => _selectAndSetActive(p),
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: Container(
        width: AppConstants.fabSize,
        height: AppConstants.fabSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.blueAccent,
              blurRadius: 8,
              spreadRadius: 1,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: IconButton(
          icon: const Icon(
            Icons.person_add_alt_1_rounded,
            color: Colors.white,
            size: 30,
          ),
          onPressed: _addProfile,
        ),
      ),
    );
  }
}
