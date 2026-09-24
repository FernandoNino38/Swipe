import 'package:flutter_test/flutter_test.dart';
import 'package:photo_triage/main.dart';

void main() {
  testWidgets('App initialization smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const PhotoTriageApp());
    // Confirma que a estrutura base do app inicializa sem exceções
    expect(find.byType(PhotoTriageApp), findsOneWidget);
  });
}
