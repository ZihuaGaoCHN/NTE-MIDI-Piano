import 'dart:io';
import 'dart:ffi';
import 'package:keypress_simulator/keypress_simulator.dart';
import 'package:flutter/services.dart';
import 'keyboard_mapper.dart';

class MacOsKeyboardInjector {
  static late final DynamicLibrary _coreGraphics;
  static late final Pointer Function(Pointer, int, bool) _cgEventCreateKeyboardEvent;
  static late final void Function(Pointer, int) _cgEventSetFlags;
  static late final void Function(int, Pointer) _cgEventPost;
  static late final void Function(Pointer) _cfRelease;

  static late final Pointer Function(int) _cgEventSourceCreate;
  static late final void Function(Pointer, int) _cgEventSetType;
  static bool _initialized = false;

  static void _init() {
    if (_initialized) return;
    _coreGraphics = DynamicLibrary.open('/System/Library/Frameworks/ApplicationServices.framework/ApplicationServices');
    _cgEventCreateKeyboardEvent = _coreGraphics.lookupFunction<
        Pointer Function(Pointer, Uint32, Bool),
        Pointer Function(Pointer, int, bool)>('CGEventCreateKeyboardEvent');
    _cgEventSourceCreate = _coreGraphics.lookupFunction<
        Pointer Function(Int32),
        Pointer Function(int)>('CGEventSourceCreate');
    _cgEventSetFlags = _coreGraphics.lookupFunction<
        Void Function(Pointer, Uint64),
        void Function(Pointer, int)>('CGEventSetFlags');
    _cgEventSetType = _coreGraphics.lookupFunction<
        Void Function(Pointer, Uint32),
        void Function(Pointer, int)>('CGEventSetType');
    _cgEventPost = _coreGraphics.lookupFunction<
        Void Function(Uint32, Pointer),
        void Function(int, Pointer)>('CGEventPost');
    _cfRelease = _coreGraphics.lookupFunction<
        Void Function(Pointer),
        void Function(Pointer)>('CFRelease');
    _initialized = true;
  }

  static final Map<PhysicalKeyboardKey, int> _macKeyCodes = {
    PhysicalKeyboardKey.keyA: 0,
    PhysicalKeyboardKey.keyS: 1,
    PhysicalKeyboardKey.keyD: 2,
    PhysicalKeyboardKey.keyF: 3,
    PhysicalKeyboardKey.keyH: 4,
    PhysicalKeyboardKey.keyG: 5,
    PhysicalKeyboardKey.keyZ: 6,
    PhysicalKeyboardKey.keyX: 7,
    PhysicalKeyboardKey.keyC: 8,
    PhysicalKeyboardKey.keyV: 9,
    PhysicalKeyboardKey.keyB: 11,
    PhysicalKeyboardKey.keyQ: 12,
    PhysicalKeyboardKey.keyW: 13,
    PhysicalKeyboardKey.keyE: 14,
    PhysicalKeyboardKey.keyR: 15,
    PhysicalKeyboardKey.keyY: 16,
    PhysicalKeyboardKey.keyT: 17,
    PhysicalKeyboardKey.keyU: 32,
    PhysicalKeyboardKey.keyJ: 38,
    PhysicalKeyboardKey.keyN: 45,
    PhysicalKeyboardKey.keyM: 46,
    PhysicalKeyboardKey.shiftLeft: 56,
    PhysicalKeyboardKey.controlLeft: 59,
  };

  static void postEvent(PhysicalKeyboardKey key, bool keyDown, List<ModifierKey> activeModifiers) {
    _init();
    final keyCode = _macKeyCodes[key] ?? 0;
    
    // kCGEventSourceStateHIDSystemState = 1
    final source = _cgEventSourceCreate(1);
    final event = _cgEventCreateKeyboardEvent(source, keyCode, keyDown);
    if (event != nullptr) {
      if (key == PhysicalKeyboardKey.shiftLeft || key == PhysicalKeyboardKey.controlLeft) {
        _cgEventSetType(event, 12); // kCGEventFlagsChanged
      }
      
      int flags = 0;
      if (activeModifiers.contains(ModifierKey.shiftModifier)) {
        // 0x00020000 = global shift, 0x02 = NX_DEVICELSHIFTKEYMASK
        flags |= 0x00020002; 
      }
      if (activeModifiers.contains(ModifierKey.controlModifier)) {
        // 0x00040000 = global control, 0x01 = NX_DEVICELCTLKEYMASK
        flags |= 0x00040001; 
      }
      
      _cgEventSetFlags(event, flags);
      _cgEventPost(0, event); // kCGHIDEventTap
      _cfRelease(event);
    }
    if (source != nullptr) {
      _cfRelease(source);
    }
  }
}

class KeyboardInjector {
  static Future<void> pressNoteDown(int midiNote) async {
    final action = KeyboardMapper.getActionForNote(midiNote);
    if (action != null) {
      print('MIDI Note $midiNote Down -> modifiers: ${action.modifiers}');
      
      if (Platform.isMacOS) {
        if (action.modifiers.contains(ModifierKey.shiftModifier)) {
          MacOsKeyboardInjector.postEvent(PhysicalKeyboardKey.shiftLeft, true, [ModifierKey.shiftModifier]);
          await Future.delayed(const Duration(milliseconds: 36));
        }
        if (action.modifiers.contains(ModifierKey.controlModifier)) {
          MacOsKeyboardInjector.postEvent(PhysicalKeyboardKey.controlLeft, true, [ModifierKey.controlModifier]);
          await Future.delayed(const Duration(milliseconds: 36));
        }
        MacOsKeyboardInjector.postEvent(action.key, true, action.modifiers);
      } else {
        if (action.modifiers.contains(ModifierKey.shiftModifier)) {
          await keyPressSimulator.simulateKeyDown(PhysicalKeyboardKey.shiftLeft);
          await Future.delayed(const Duration(milliseconds: 36));
        }
        if (action.modifiers.contains(ModifierKey.controlModifier)) {
          await keyPressSimulator.simulateKeyDown(PhysicalKeyboardKey.controlLeft);
          await Future.delayed(const Duration(milliseconds: 36));
        }
        await keyPressSimulator.simulateKeyDown(action.key);
      }
    }
  }

  static Future<void> releaseNoteUp(int midiNote) async {
    final action = KeyboardMapper.getActionForNote(midiNote);
    if (action != null) {
      print('MIDI Note $midiNote Up -> modifiers: ${action.modifiers}');
      
      if (Platform.isMacOS) {
        MacOsKeyboardInjector.postEvent(action.key, false, action.modifiers);
        await Future.delayed(const Duration(milliseconds: 36));
        if (action.modifiers.contains(ModifierKey.controlModifier)) {
          MacOsKeyboardInjector.postEvent(PhysicalKeyboardKey.controlLeft, false, []);
        }
        if (action.modifiers.contains(ModifierKey.shiftModifier)) {
          MacOsKeyboardInjector.postEvent(PhysicalKeyboardKey.shiftLeft, false, []);
        }
      } else {
        await keyPressSimulator.simulateKeyUp(action.key);
        await Future.delayed(const Duration(milliseconds: 36));
        if (action.modifiers.contains(ModifierKey.controlModifier)) {
          await keyPressSimulator.simulateKeyUp(PhysicalKeyboardKey.controlLeft);
        }
        if (action.modifiers.contains(ModifierKey.shiftModifier)) {
          await keyPressSimulator.simulateKeyUp(PhysicalKeyboardKey.shiftLeft);
        }
      }
    }
  }
}
