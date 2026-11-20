import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formidable_example/showcase.dart';

/// A tall, wide surface, so that a whole page is built and on screen.
void useTallSurface(WidgetTester tester, {double width = 800}) {
  tester.view.physicalSize = Size(width, 4000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

Future<void> pumpMaterial(WidgetTester tester, Widget home) async {
  useTallSurface(tester);
  await tester.pumpWidget(MaterialShowcase(home: home));
}

Future<void> pumpCupertino(WidgetTester tester, Widget home) async {
  useTallSurface(tester);
  await tester.pumpWidget(CupertinoShowcase(home: home));
}

/// Lets debounced checks, async answers and animations run.
Future<void> settle(WidgetTester tester) =>
    tester.pump(const Duration(seconds: 1));
