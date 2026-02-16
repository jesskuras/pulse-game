import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lucky_game/providers/game_provider.dart';

void main() {
  test('GameProvider generates Fading and Static nodes correctly', () async {
    SharedPreferences.setMockInitialValues({});

    final provider = GameProvider();
    // Wait for async init (simulated)
    await Future.delayed(const Duration(milliseconds: 100));

    final state = provider.state;
    // We expect some fading nodes and some static nodes
    // but random generation makes exact counts tricky.
    // However, they MUST be disjoint.

    final intersection = state.staticNodes.intersection(state.fadingNodes);
    expect(
      intersection,
      isEmpty,
      reason: "Static and Fading nodes should be mutually exclusive",
    );
  });
}
