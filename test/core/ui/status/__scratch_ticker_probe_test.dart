import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class Probe extends StatefulWidget {
  const Probe({super.key});
  @override
  State<Probe> createState() => _ProbeState();
}

class _ProbeState extends State<Probe> with SingleTickerProviderStateMixin {
  late final AnimationController c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
  int completions = 0;

  @override
  void initState() {
    super.initState();
    c.addStatusListener((s) {
      if (s == AnimationStatus.completed) {
        completions++;
        // ignore: avoid_print
        print('completed at count=$completions');
      }
    });
    c.forward();
  }

  @override
  Widget build(BuildContext context) => Text('value=${c.value}');
}

void main() {
  testWidgets('AnimationController value/status after single 1000ms pump', (tester) async {
    await tester.pumpWidget(MaterialApp(home: Probe()));
    final state = tester.state<_ProbeState>(find.byType(Probe));
    print('initial value=${state.c.value} status=${state.c.status}');
    await tester.pump(const Duration(milliseconds: 1000));
    print('after one 1000ms pump: value=${state.c.value} status=${state.c.status} completions=${state.completions}');
  });
}
