/// Helpers para parsear JSON del API (.NET a veces manda números o enums como String).
int parseJsonInt(dynamic value, {String field = 'value'}) {
  if (value == null) {
    throw FormatException('Campo "$field" es nulo');
  }
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) {
    final parsed = int.tryParse(value.trim());
    if (parsed != null) return parsed;
  }
  throw FormatException(
    'Campo "$field" no es un entero válido: $value (${value.runtimeType})',
  );
}

String parseJsonString(dynamic value, {String field = 'value'}) {
  if (value == null) {
    throw FormatException('Campo "$field" es nulo');
  }
  if (value is String) return value;
  return value.toString();
}

bool parseJsonBool(dynamic value, {bool fallback = false}) {
  if (value == null) return fallback;
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final v = value.toLowerCase().trim();
    if (v == 'true' || v == '1') return true;
    if (v == 'false' || v == '0') return false;
  }
  return fallback;
}

/// Role puede venir como int (1|2) o string ("Deacon"|"Administrator").
int parseUserRoleValue(dynamic value) {
  if (value == null) return 1;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) {
    final trimmed = value.trim();
    final asInt = int.tryParse(trimmed);
    if (asInt != null) return asInt;
    switch (trimmed.toLowerCase()) {
      case 'deacon':
      case 'diacono':
      case 'diácono':
        return 1;
      case 'administrator':
      case 'admin':
      case 'administrador':
        return 2;
    }
  }
  return 1;
}

/// Status de asistencia: int o nombre enum.
int parseAttendanceStatusValue(dynamic value) {
  if (value == null) return 3;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) {
    final trimmed = value.trim();
    final asInt = int.tryParse(trimmed);
    if (asInt != null) return asInt;
    switch (trimmed.toLowerCase()) {
      case 'present':
      case 'presente':
        return 1;
      case 'late':
      case 'tarde':
        return 2;
      case 'absent':
      case 'ausente':
        return 3;
    }
  }
  return 3;
}
