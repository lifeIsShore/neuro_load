// Smoke test for NeuroLoad app
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neuro_load/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: NeuroLoadApp()));
    expect(find.byType(NeuroLoadApp), findsOneWidget);
  });
}
