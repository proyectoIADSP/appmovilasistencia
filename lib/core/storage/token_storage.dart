abstract class TokenStorage {
  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<void> clearToken();
  Future<void> saveUserJson(String json);
  Future<String?> getUserJson();
  Future<void> clearAll();
}
