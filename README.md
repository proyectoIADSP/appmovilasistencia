# Asistencia IASD Pariachi

App móvil de asistencia eclesiástica de la **Iglesia Adventista del Séptimo Día — Pariachi**.

Consume el backend **asistenciaBack** (.NET).

Arquitectura: **Clean Architecture** + **Riverpod** + **Dio** + **go_router**.

## Requisitos

- Flutter 3.44+ / Dart 3.12+
- Backend en Render (por defecto) o local en el puerto **5282**

## Base URL (AppConfig)

Por defecto la app usa **HTTPS en Render**:

`https://asistenciaback-pg60.onrender.com`

| Entorno | URL |
|---------|-----|
| Celular / producción (default) | `https://asistenciaback-pg60.onrender.com` |
| Emulador Android → API local | `http://10.0.2.2:5282` |
| iOS Simulator / Desktop → API local | `http://localhost:5282` |

Override opcional:

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:5282
```

**Nota:** el plan free de Render se duerme; el primer request puede tardar ~30–60 s (timeouts de Dio en 60 s).

## Credenciales de desarrollo (seed)

- Email: `admin@iglesia.local`
- Password: `Admin123!`

## Cómo ejecutar

```bash
flutter pub get
flutter run
```

La app hablará con Render automáticamente (sin localhost).

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
