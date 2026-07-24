/// Configuración de la API.
///
/// Por defecto apunta a Render (producción / celular).
/// Para backend local:
/// ```bash
/// flutter run --dart-define=API_BASE_URL=http://10.0.2.2:5282
/// # o en desktop/iOS simulator:
/// flutter run --dart-define=API_BASE_URL=http://localhost:5282
/// ```
class AppConfig {
  AppConfig._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://asistenciaback-pg60.onrender.com',
  );

  static const String apiPrefix = '/api';
}
