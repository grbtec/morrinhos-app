import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sinceRepositoryProvider = Provider.autoDispose(
    (ref) => SinceRepository(prefs: SharedPreferences.getInstance()));

class SinceRepository {
  final Future<SharedPreferences> prefs;

  SinceRepository({
    required this.prefs,
  });


  Future<void> setSince(String id) async {
    final now = DateTime.now().toUtc().toIso8601String();
    final prefs = await this.prefs;

    await prefs.setString(id, now);
  }

  Future<String> getSince(String id) async {
    final prefs = await this.prefs;

    return prefs.getString(id) ?? '';
  }
}
