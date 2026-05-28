import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/dot.dart';

class DotLocalService {
  static const String _dotsKey = 'dots';

  Future<List<Dot>> fetchDots({String? profileId}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dotsData = prefs.getString(_dotsKey);
      
      if (dotsData == null || dotsData.isEmpty) return [];

      final Map<String, dynamic> allDots = json.decode(dotsData);
      
      if (profileId != null) {
        final profileDots = allDots[profileId] as List<dynamic>? ?? [];
        return profileDots.map((dotData) => Dot.fromMap(dotData as Map<String, dynamic>)).toList();
      } else {
        final List<Dot> allDotsList = [];
        for (final profileDots in allDots.values) {
          if (profileDots is List) {
            allDotsList.addAll(
              profileDots.map((dotData) => Dot.fromMap(dotData as Map<String, dynamic>)),
            );
          }
        }
        return allDotsList;
      }
    } catch (e) {
      debugPrint('DotLocalService.fetchDots error: $e');
      return [];
    }
  }

  Future<void> addDot(Dot dot, {String? profileId}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dotsData = prefs.getString(_dotsKey);
      
      Map<String, dynamic> allDots = {};
      if (dotsData != null && dotsData.isNotEmpty) {
        allDots = json.decode(dotsData) as Map<String, dynamic>;
      }

      final currentProfileId = profileId ?? 'default';
      List<dynamic> profileDots = (allDots[currentProfileId] as List<dynamic>?) ?? [];
      
      final existingIndex = profileDots.indexWhere((d) => d['id'] == dot.id);
      if (existingIndex != -1) {
        profileDots[existingIndex] = dot.toMap();
      } else {
        profileDots.add(dot.toMap());
      }
      
      allDots[currentProfileId] = profileDots;
      await prefs.setString(_dotsKey, json.encode(allDots));
    } catch (e) {
      debugPrint('DotLocalService.addDot error: $e');
      rethrow;
    }
  }

  Future<void> updateDot(Dot dot, {String? profileId}) async {
    await addDot(dot, profileId: profileId);
  }

  Future<void> deleteDot(String dotId, {String? profileId}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dotsData = prefs.getString(_dotsKey);
      
      if (dotsData == null || dotsData.isEmpty) return;

      Map<String, dynamic> allDots = json.decode(dotsData);
      
      if (profileId != null) {
        final profileDots = allDots[profileId] as List<dynamic>? ?? [];
        profileDots.removeWhere((dot) => dot['id'] == dotId);
        allDots[profileId] = profileDots;
      } else {
        for (final key in allDots.keys.toList()) {
          final profileDots = allDots[key] as List<dynamic>? ?? [];
          profileDots.removeWhere((dot) => dot['id'] == dotId);
          allDots[key] = profileDots;
        }
      }
      
      await prefs.setString(_dotsKey, json.encode(allDots));
    } catch (e) {
      debugPrint('DotLocalService.deleteDot error: $e');
      rethrow;
    }
  }

  Future<void> saveDots(List<Dot> dots, {String? profileId}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dotsData = prefs.getString(_dotsKey);
      
      Map<String, dynamic> allDots = {};
      if (dotsData != null && dotsData.isNotEmpty) {
        allDots = json.decode(dotsData) as Map<String, dynamic>;
      }

      final currentProfileId = profileId ?? 'default';
      allDots[currentProfileId] = dots.map((dot) => dot.toMap()).toList();
      
      await prefs.setString(_dotsKey, json.encode(allDots));
    } catch (e) {
      debugPrint('DotLocalService.saveDots error: $e');
      rethrow;
    }
  }
}
