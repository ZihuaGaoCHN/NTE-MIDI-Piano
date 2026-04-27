import 'package:flutter/services.dart';

class KeyAction {
  final PhysicalKeyboardKey key;
  final List<ModifierKey> modifiers;

  const KeyAction(this.key, {this.modifiers = const []});
}

class KeyboardMapper {
  static final Map<int, KeyAction> _map = {
    // C3 - B3
    48: const KeyAction(PhysicalKeyboardKey.keyZ), // C3
    49: const KeyAction(PhysicalKeyboardKey.keyZ, modifiers: [ModifierKey.shiftModifier]), // C#3
    50: const KeyAction(PhysicalKeyboardKey.keyX), // D3
    51: const KeyAction(PhysicalKeyboardKey.keyC, modifiers: [ModifierKey.controlModifier]), // Eb3
    52: const KeyAction(PhysicalKeyboardKey.keyC), // E3
    53: const KeyAction(PhysicalKeyboardKey.keyV), // F3
    54: const KeyAction(PhysicalKeyboardKey.keyV, modifiers: [ModifierKey.shiftModifier]), // F#3
    55: const KeyAction(PhysicalKeyboardKey.keyB), // G3
    56: const KeyAction(PhysicalKeyboardKey.keyB, modifiers: [ModifierKey.shiftModifier]), // G#3
    57: const KeyAction(PhysicalKeyboardKey.keyN), // A3
    58: const KeyAction(PhysicalKeyboardKey.keyM, modifiers: [ModifierKey.controlModifier]), // Bb3
    59: const KeyAction(PhysicalKeyboardKey.keyM), // B3

    // C4 - B4
    60: const KeyAction(PhysicalKeyboardKey.keyA), // C4
    61: const KeyAction(PhysicalKeyboardKey.keyA, modifiers: [ModifierKey.shiftModifier]), // C#4
    62: const KeyAction(PhysicalKeyboardKey.keyS), // D4
    63: const KeyAction(PhysicalKeyboardKey.keyD, modifiers: [ModifierKey.controlModifier]), // Eb4
    64: const KeyAction(PhysicalKeyboardKey.keyD), // E4
    65: const KeyAction(PhysicalKeyboardKey.keyF), // F4
    66: const KeyAction(PhysicalKeyboardKey.keyF, modifiers: [ModifierKey.shiftModifier]), // F#4
    67: const KeyAction(PhysicalKeyboardKey.keyG), // G4
    68: const KeyAction(PhysicalKeyboardKey.keyG, modifiers: [ModifierKey.shiftModifier]), // G#4
    69: const KeyAction(PhysicalKeyboardKey.keyH), // A4
    70: const KeyAction(PhysicalKeyboardKey.keyJ, modifiers: [ModifierKey.controlModifier]), // Bb4
    71: const KeyAction(PhysicalKeyboardKey.keyJ), // B4

    // C5 - B5
    72: const KeyAction(PhysicalKeyboardKey.keyQ), // C5
    73: const KeyAction(PhysicalKeyboardKey.keyQ, modifiers: [ModifierKey.shiftModifier]), // C#5
    74: const KeyAction(PhysicalKeyboardKey.keyW), // D5
    75: const KeyAction(PhysicalKeyboardKey.keyE, modifiers: [ModifierKey.controlModifier]), // Eb5
    76: const KeyAction(PhysicalKeyboardKey.keyE), // E5
    77: const KeyAction(PhysicalKeyboardKey.keyR), // F5
    78: const KeyAction(PhysicalKeyboardKey.keyR, modifiers: [ModifierKey.shiftModifier]), // F#5
    79: const KeyAction(PhysicalKeyboardKey.keyT), // G5
    80: const KeyAction(PhysicalKeyboardKey.keyT, modifiers: [ModifierKey.shiftModifier]), // G#5
    81: const KeyAction(PhysicalKeyboardKey.keyY), // A5
    82: const KeyAction(PhysicalKeyboardKey.keyU, modifiers: [ModifierKey.controlModifier]), // Bb5
    83: const KeyAction(PhysicalKeyboardKey.keyU), // B5
  };

  static KeyAction? getActionForNote(int midiNote) {
    return _map[midiNote];
  }
}
