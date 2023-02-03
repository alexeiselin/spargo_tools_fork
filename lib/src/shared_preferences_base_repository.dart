import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Базовые ключи репозитория [SharedPreferences]
abstract class ISharedPreferencesBaseRepositoryKeys {
  static const keyToken = 'token';
  static const keyRefreshToken = 'refreshToken';
  static const keyRole = 'role';
  static const keyIdentityCookie = 'identityCookie';
}

/// Базовый репозиторий [SharedPreferences]
abstract class SharedPreferencesBaseRepository {
  static Future<bool> setToken(String token) async => setString(ISharedPreferencesBaseRepositoryKeys.keyToken, token);
  static Future<bool> setRefreshToken(String refreshToken) async => setString(ISharedPreferencesBaseRepositoryKeys.keyRefreshToken, refreshToken);

  static Future<String?> getToken() async => getString(ISharedPreferencesBaseRepositoryKeys.keyToken);
  static Future<String?> getRefreshToken() async => getString(ISharedPreferencesBaseRepositoryKeys.keyRefreshToken);

  static Future<String?> getTokenWithouBearer() async {
    final token = await getString(ISharedPreferencesBaseRepositoryKeys.keyToken);
    if (token != null) {
      return token.replaceFirst('Bearer ', '');
    }
    return null;
  }

  static Future<Map<String, dynamic>?> getDecodedToken() async {
    final token = await getToken();
    if (token != null && token.isNotEmpty) {
      final decodedToken = JwtDecoder.decode(token);
      return decodedToken;
    }
    return null;
  }

  static Future<bool> setUserRole(String role) async => setString(ISharedPreferencesBaseRepositoryKeys.keyRole, role);

  static Future<bool> removeUserRole() async => remove(ISharedPreferencesBaseRepositoryKeys.keyRole);

  static Future<String?> getUserRole() async => getString(ISharedPreferencesBaseRepositoryKeys.keyRole);

  static Future<void> setIndentityCookie(String cookie) async => setString(ISharedPreferencesBaseRepositoryKeys.keyIdentityCookie, cookie);

  static Future<String?> getIdentityCookie() async {
    final pref = await SharedPreferences.getInstance();
    return pref.getString(ISharedPreferencesBaseRepositoryKeys.keyIdentityCookie);
  }

  static Future<bool> clear() async {
    final pref = await SharedPreferences.getInstance();
    return pref.clear();
  }

  static Future<bool> setString(String key, String value) async {
    final pref = await SharedPreferences.getInstance();
    return pref.setString(key, value);
  }

  static Future<String?> getString(String key) async {
    final pref = await SharedPreferences.getInstance();
    return pref.getString(key);
  }

  static Future<bool> setInt(String key, int value) async {
    final pref = await SharedPreferences.getInstance();
    return pref.setInt(key, value);
  }

  static Future<int?> getInt(String key) async {
    final pref = await SharedPreferences.getInstance();
    return pref.getInt(key);
  }

  static Future<bool> setBool(String key, bool value) async {
    final pref = await SharedPreferences.getInstance();
    return pref.setBool(key, value);
  }

  static Future<bool> setStringList(String key, List<String> value) async {
    final pref = await SharedPreferences.getInstance();
    return pref.setStringList(key, value);
  }

  static Future<List<String>?> getStringList(String key) async {
    final pref = await SharedPreferences.getInstance();
    return pref.getStringList(key);
  }

  static Future<bool?> getBool(String key) async {
    final pref = await SharedPreferences.getInstance();
    return pref.getBool(key);
  }

  static Future<bool> remove(String key) async {
    final pref = await SharedPreferences.getInstance();
    return pref.remove(key);
  }
}
