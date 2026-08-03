import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pacepulse/core/ui/ui.dart';

void main() {
  test('registry exposes 36 unique icons', () {
    expect(PPIcons.all.length, 36);
    expect(PPIcons.all.toSet().length, 36);
  });

  testWidgets('PPIcon renders at requested size with explicit color',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Center(
        child: PPIcon(PPIcons.zap, size: PPIconSize.s28, color: Colors.red),
      ),
    ));
    final icon = tester.widget<Icon>(find.byType(Icon));
    expect(icon.size, 28);
    expect(icon.color, Colors.red);
  });
}
