import 'package:flutter_test/flutter_test.dart';
import 'package:tvmaze/main.dart';

void main() {
  testWidgets('App renders HomePage', (WidgetTester tester) async {
    await tester.pumpWidget(const SeriesVaultApp());

    expect(find.text('SeriesVault'), findsOneWidget);
  });
}