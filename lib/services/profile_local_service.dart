import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/profile.dart';

class ProfileLocalService {
  static const String _profilesKey = 'profiles';
  static const String _activeProfileKey = 'active_profile_id';

  Future<List<Profile>> fetchProfiles() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profilesData = prefs.getString(_profilesKey);
      
      if (profilesData == null || profilesData.isEmpty) return [];

      final List<dynamic> profilesList = json.decode(profilesData);
      return profilesList.map((profileData) => Profile.fromMap(profileData as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('ProfileLocalService.fetchProfiles error: $e');
      return [];
    }
  }

  Future<String?> getActiveProfileId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_activeProfileKey);
    } catch (e) {
      debugPrint('ProfileLocalService.getActiveProfileId error: $e');
      return null;
    }
  }

  Future<void> addProfile(Profile profile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profilesData = prefs.getString(_profilesKey);
      
      List<dynamic> profilesList = [];
      if (profilesData != null && profilesData.isNotEmpty) {
        profilesList = json.decode(profilesData) as List<dynamic>;
      }

      final existingIndex = profilesList.indexWhere(
        (p) => (p as Map<String, dynamic>)['id'] == profile.id,
      );
      if (existingIndex != -1) {
        profilesList[existingIndex] = profile.toMap();
      } else {
        profilesList.add(profile.toMap());
      }
      
      await prefs.setString(_profilesKey, json.encode(profilesList));
    } catch (e) {
      debugPrint('ProfileLocalService.addProfile error: $e');
      rethrow;
    }
  }

  Future<void> updateProfile(Profile profile) async {
    await addProfile(profile);
  }

  Future<void> deleteProfile(String profileId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profilesData = prefs.getString(_profilesKey);
      
      if (profilesData == null || profilesData.isEmpty) return;

      List<dynamic> profilesList = json.decode(profilesData) as List<dynamic>;
      profilesList.removeWhere(
        (profile) => (profile as Map<String, dynamic>)['id'] == profileId,
      );
      
      await prefs.setString(_profilesKey, json.encode(profilesList));

      final activeProfileId = await getActiveProfileId();
      if (activeProfileId == profileId) {
        await prefs.remove(_activeProfileKey);
      }
    } catch (e) {
      debugPrint('ProfileLocalService.deleteProfile error: $e');
      rethrow;
    }
  }

  Future<void> setActiveProfile(String profileId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final profilesData = prefs.getString(_profilesKey);
      if (profilesData != null && profilesData.isNotEmpty) {
        List<dynamic> profilesList = json.decode(profilesData) as List<dynamic>;
        for (int i = 0; i < profilesList.length; i++) {
          final p = profilesList[i] as Map<String, dynamic>;
          profilesList[i] = {...p, 'isActive': false};
        }
        
        final profileIndex = profilesList.indexWhere(
          (p) => (p as Map<String, dynamic>)['id'] == profileId,
        );
        if (profileIndex != -1) {
          final p = profilesList[profileIndex] as Map<String, dynamic>;
          profilesList[profileIndex] = {...p, 'isActive': true};
        }
        
        await prefs.setString(_profilesKey, json.encode(profilesList));
      }
      
      await prefs.setString(_activeProfileKey, profileId);
    } catch (e) {
      debugPrint('ProfileLocalService.setActiveProfile error: $e');
      rethrow;
    }
  }
}
