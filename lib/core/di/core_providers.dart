import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config.dart';
import '../network/dio_client.dart';
import '../storage/secure_token_storage.dart';
import '../storage/token_storage.dart';

final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return SecureTokenStorage();
});

final dioClientProvider = Provider<DioClient>((ref) {
  final storage = ref.watch(tokenStorageProvider);
  return DioClient(
    baseUrl: AppConfig.baseUrl,
    tokenStorage: storage,
    onUnauthorized: () {
      // El AuthNotifier escucha y limpia sesión al recibir 401 vía logout.
    },
  );
});
