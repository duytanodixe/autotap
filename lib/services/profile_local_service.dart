import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/profile.dart';

class ProfileLocalService {
  static const String _profilesKey = 'profiles';
  static const String _activeProfileKey = 'active_profile_id';

  Future<List<Profile>> fetchProfiles() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profilesData = prefs.getString(_profilesKey);
      
      if (profilesData == null) return [];

      final List<dynamic> profilesList = json.decode(profilesData);
      return profilesList.map((profileData) => Profile.fromMap(profileData)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<String?> getActiveProfileId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_activeProfileKey);
    } catch (e) {
      return null;
    }
  }

  Future<void> addProfile(Profile profile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profilesData = prefs.getString(_profilesKey);
      
      List<dynamic> profilesList = [];
      if (profilesData != null) {
        profilesList = json.decode(profilesData);
      }

      // Kiểm tra xem profile đã tồn tại chưa
      final existingIndex = profilesList.indexWhere((p) => p['id'] == profile.id);
      if (existingIndex != -1) {
        profilesList[existingIndex] = profile.toMap();
      } else {
        profilesList.add(profile.toMap());
      }
      
      await prefs.setString(_profilesKey, json.encode(profilesList));
    } catch (e) {
      throw Exception('Failed to save profile: $e');
    }
  }

  Future<void> updateProfile(Profile profile) async {
    await addProfile(profile);
  }

  Future<void> deleteProfile(String profileId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profilesData = prefs.getString(_profilesKey);
      
      if (profilesData == null) return;

      List<dynamic> profilesList = json.decode(profilesData);
      profilesList.removeWhere((profile) => profile['id'] == profileId);
      
      await prefs.setString(_profilesKey, json.encode(profilesList));

      // Nếu profile bị xóa là active profile, xóa active profile
      final activeProfileId = await getActiveProfileId();
      if (activeProfileId == profileId) {
        await prefs.remove(_activeProfileKey);
      }
    } catch (e) {
      throw Exception('Failed to delete profile: $e');
    }
  }

  Future<void> setActiveProfile(String profileId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Cập nhật tất cả profiles để set isActive = false
      final profilesData = prefs.getString(_profilesKey);
      if (profilesData != null) {
        List<dynamic> profilesList = json.decode(profilesData);
        for (int i = 0; i < profilesList.length; i++) {
          profilesList[i]['isActive'] = false;
        }
        
        // Set profile được chọn là active
        final profileIndex = profilesList.indexWhere((p) => p['id'] == profileId);
        if (profileIndex != -1) {
          profilesList[profileIndex]['isActive'] = true;
        }
        
        await prefs.setString(_profilesKey, json.encode(profilesList));
      }
      
      // Lưu active profile ID
      await prefs.setString(_activeProfileKey, profileId);
    } catch (e) {
      throw Exception('Failed to set active profile: $e');
    }
  }
}
