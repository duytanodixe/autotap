import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/dot.dart';

class DotLocalService {
  static const String _dotsKey = 'dots';

  Future<List<Dot>> fetchDots({String? profileId}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dotsData = prefs.getString(_dotsKey);
      
      if (dotsData == null) return [];

      final Map<String, dynamic> allDots = json.decode(dotsData);
      
      if (profileId != null) {
        final profileDots = allDots[profileId] as List<dynamic>? ?? [];
        return profileDots.map((dotData) => Dot.fromMap(dotData)).toList();
      } else {
        // Trả về tất cả dots từ tất cả profiles
        final List<Dot> allDotsList = [];
        for (final profileDots in allDots.values) {
          if (profileDots is List) {
            allDotsList.addAll(profileDots.map((dotData) => Dot.fromMap(dotData)));
          }
        }
        return allDotsList;
      }
    } catch (e) {
      return [];
    }
  }

  Future<void> addDot(Dot dot, {String? profileId}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dotsData = prefs.getString(_dotsKey);
      
      Map<String, dynamic> allDots = {};
      if (dotsData != null) {
        allDots = json.decode(dotsData);
      }

      final currentProfileId = profileId ?? 'default';
      List<dynamic> profileDots = allDots[currentProfileId] as List<dynamic>? ?? [];
      
      // Kiểm tra xem dot đã tồn tại chưa
      final existingIndex = profileDots.indexWhere((d) => d['id'] == dot.id);
      if (existingIndex != -1) {
        profileDots[existingIndex] = dot.toMap();
      } else {
        profileDots.add(dot.toMap());
      }
      
      allDots[currentProfileId] = profileDots;
      await prefs.setString(_dotsKey, json.encode(allDots));
    } catch (e) {
      throw Exception('Failed to save dot: $e');
    }
  }

  Future<void> updateDot(Dot dot, {String? profileId}) async {
    await addDot(dot, profileId: profileId);
  }

  Future<void> deleteDot(String dotId, {String? profileId}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dotsData = prefs.getString(_dotsKey);
      
      if (dotsData == null) return;

      Map<String, dynamic> allDots = json.decode(dotsData);
      
      if (profileId != null) {
        final profileDots = allDots[profileId] as List<dynamic>? ?? [];
        profileDots.removeWhere((dot) => dot['id'] == dotId);
        allDots[profileId] = profileDots;
      } else {
        // Xóa dot từ tất cả profiles
        for (final profileId in allDots.keys) {
          final profileDots = allDots[profileId] as List<dynamic>? ?? [];
          profileDots.removeWhere((dot) => dot['id'] == dotId);
          allDots[profileId] = profileDots;
        }
      }
      
      await prefs.setString(_dotsKey, json.encode(allDots));
    } catch (e) {
      throw Exception('Failed to delete dot: $e');
    }
  }

  Future<void> saveDots(List<Dot> dots, {String? profileId}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dotsData = prefs.getString(_dotsKey);
      
      Map<String, dynamic> allDots = {};
      if (dotsData != null) {
        allDots = json.decode(dotsData);
      }

      final currentProfileId = profileId ?? 'default';
      allDots[currentProfileId] = dots.map((dot) => dot.toMap()).toList();
      
      await prefs.setString(_dotsKey, json.encode(allDots));
    } catch (e) {
      throw Exception('Failed to save dots: $e');
    }
  }
}
