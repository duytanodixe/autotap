import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/profile.dart';

class ProfileLocalService {
  static const String _key = 'profiles';
  static const String _activeKey = 'active_profile_id';

  Future<List<Profile>> fetchProfiles() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_key);
    if (jsonStr == null || jsonStr.isEmpty) return [];

    final List<dynamic> jsonList = json.decode(jsonStr);
    return jsonList.map((e) => Profile.fromJson(e)).toList();
  }

  Future<void> addProfile(Profile profile) async {
    final profiles = await fetchProfiles();
    profiles.add(profile);
    await _save(profiles);
  }

  Future<void> updateProfile(Profile profile) async {
    final profiles = await fetchProfiles();
    final index = profiles.indexWhere((p) => p.id == profile.id);
    if (index != -1) {
      profiles[index] = profile;
      await _save(profiles);
    }
  }

  Future<void> deleteProfile(String id) async {
    final profiles = await fetchProfiles();
    profiles.removeWhere((p) => p.id == id);
    await _save(profiles);
  }

  Future<void> setActiveProfile(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_activeKey, id);

    final profiles = await fetchProfiles();
    final updated = profiles.map((p) {
      return p.copyWith(isActive: p.id == id);
    }).toList();
    await _save(updated);
  }

  Future<String?> getActiveProfileId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_activeKey);
  }

  Future<void> _save(List<Profile> profiles) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = profiles.map((p) => p.toJson()).toList();
    await prefs.setString(_key, json.encode(jsonList));
  }
}
