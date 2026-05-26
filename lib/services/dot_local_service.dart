import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/dot.dart';

class DotLocalService {
  static const String _key = 'dots';

  Future<List<Dot>> fetchDots({String? profileId}) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('${_key}_$profileId');
    if (jsonStr == null || jsonStr.isEmpty) return [];

    final List<dynamic> jsonList = json.decode(jsonStr);
    return jsonList.map((e) => Dot.fromJson(e)).toList();
  }

  Future<void> saveDots(List<Dot> dots, {String? profileId}) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = dots.map((d) => d.toJson()).toList();
    await prefs.setString('${_key}_$profileId', json.encode(jsonList));
  }

  Future<void> addDot(Dot dot, {String? profileId}) async {
    final dots = await fetchDots(profileId: profileId);
    dots.add(dot);
    await saveDots(dots, profileId: profileId);
  }

  Future<void> updateDot(Dot dot, {String? profileId}) async {
    final dots = await fetchDots(profileId: profileId);
    final index = dots.indexWhere((d) => d.id == dot.id);
    if (index != -1) {
      dots[index] = dot;
      await saveDots(dots, profileId: profileId);
    }
  }

  Future<void> deleteDot(String id, {String? profileId}) async {
    final dots = await fetchDots(profileId: profileId);
    dots.removeWhere((d) => d.id == id);
    await saveDots(dots, profileId: profileId);
  }

  Future<void> clearDots({String? profileId}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('${_key}_$profileId');
  }
}
