import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:appmovilasistencia/app.dart';

void main() {
  testWidgets('App arranca con ProviderScope', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: ProyectoAsistenciaApp()),
    );
    await tester.pump();
    expect(find.byType(ProyectoAsistenciaApp), findsOneWidget);
  });
}
