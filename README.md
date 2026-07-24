# Asistencia IASD Pariachi

App móvil de asistencia eclesiástica de la **Iglesia Adventista del Séptimo Día — Pariachi**.

Consume el backend **asistenciaBack** (.NET).

Arquitectura: **Clean Architecture** + **Riverpod** + **Dio** + **go_router**.

## Requisitos

- Flutter 3.44+ / Dart 3.12+
- Backend `asistenciaBack` corriendo en el puerto **5282**

## Base URL (AppConfig)

| Entorno | URL |
|---------|-----|
| Emulador Android | `http://10.0.2.2:5282` |
| iOS Simulator / Windows / macOS / Web | `http://localhost:5282` |

La selección es automática en `lib/core/config/app_config.dart`.

## Credenciales de desarrollo (seed)

- Email: `admin@iglesia.local`
- Password: `Admin123!`

## Cómo ejecutar

1. Levanta el backend en `http://localhost:5282`.
2. En esta carpeta:

```bash
flutter pub get
flutter run
```

- Emulador Android: la app usará `10.0.2.2:5282` (host de tu PC).
- Escritorio / iOS Simulator: usará `localhost:5282`.

### Dispositivo físico Android

Cambia temporalmente `AppConfig.baseUrl` a la IP LAN de tu PC, por ejemplo:

```dart
return 'http://192.168.1.20:5282';
```

## Módulos

- **Auth**: login, me, registro (solo Administrador), JWT en `flutter_secure_storage`
- **Members**: listar / crear / editar / desactivar (soft delete) / activar
- **Attendance**: sábados del mes, pasar lista (bulk UPSERT), estadísticas mensuales

## Estructura

```
lib/
  core/          # config, network, storage, router, theme, errors
  features/
    auth/
    members/
    attendance/
    home/
  main.dart
  app.dart
```
