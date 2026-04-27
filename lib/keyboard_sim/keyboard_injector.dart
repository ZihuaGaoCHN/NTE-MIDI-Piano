import 'dart:io';
import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:flutter/services.dart';
import 'package:win32/win32.dart';
import 'package:url_launcher/url_launcher.dart';
import 'keyboard_mapper.dart';

class Win32KeyboardInjector {
  static final Map<PhysicalKeyboardKey, int> _winScanCodes = {
    PhysicalKeyboardKey.keyQ: 0x10,
    PhysicalKeyboardKey.keyW: 0x11,
    PhysicalKeyboardKey.keyE: 0x12,
    PhysicalKeyboardKey.keyR: 0x13,
    PhysicalKeyboardKey.keyT: 0x14,
    PhysicalKeyboardKey.keyY: 0x15,
    PhysicalKeyboardKey.keyU: 0x16,
    PhysicalKeyboardKey.keyA: 0x1E,
    PhysicalKeyboardKey.keyS: 0x1F,
    PhysicalKeyboardKey.keyD: 0x20,
    PhysicalKeyboardKey.keyF: 0x21,
    PhysicalKeyboardKey.keyG: 0x22,
    PhysicalKeyboardKey.keyH: 0x23,
    PhysicalKeyboardKey.keyJ: 0x24,
    PhysicalKeyboardKey.keyZ: 0x2C,
    PhysicalKeyboardKey.keyX: 0x2D,
    PhysicalKeyboardKey.keyC: 0x2E,
    PhysicalKeyboardKey.keyV: 0x2F,
    PhysicalKeyboardKey.keyB: 0x30,
    PhysicalKeyboardKey.keyN: 0x31,
    PhysicalKeyboardKey.keyM: 0x32,
    PhysicalKeyboardKey.shiftLeft: 0x2A,
    PhysicalKeyboardKey.controlLeft: 0x1D,
  };

  static final Map<PhysicalKeyboardKey, int> _winVkCodes = {
    PhysicalKeyboardKey.keyQ: 0x51,
    PhysicalKeyboardKey.keyW: 0x57,
    PhysicalKeyboardKey.keyE: 0x45,
    PhysicalKeyboardKey.keyR: 0x52,
    PhysicalKeyboardKey.keyT: 0x54,
    PhysicalKeyboardKey.keyY: 0x59,
    PhysicalKeyboardKey.keyU: 0x55,
    PhysicalKeyboardKey.keyA: 0x41,
    PhysicalKeyboardKey.keyS: 0x53,
    PhysicalKeyboardKey.keyD: 0x44,
    PhysicalKeyboardKey.keyF: 0x46,
    PhysicalKeyboardKey.keyG: 0x47,
    PhysicalKeyboardKey.keyH: 0x48,
    PhysicalKeyboardKey.keyJ: 0x4A,
    PhysicalKeyboardKey.keyZ: 0x5A,
    PhysicalKeyboardKey.keyX: 0x58,
    PhysicalKeyboardKey.keyC: 0x43,
    PhysicalKeyboardKey.keyV: 0x56,
    PhysicalKeyboardKey.keyB: 0x42,
    PhysicalKeyboardKey.keyN: 0x4E,
    PhysicalKeyboardKey.keyM: 0x4D,
    PhysicalKeyboardKey.shiftLeft: VK_SHIFT,
    PhysicalKeyboardKey.controlLeft: VK_CONTROL,
  };

  static void sendKey(PhysicalKeyboardKey key, bool isDown) {
    if (!Platform.isWindows) return;
    
    final scanCode = _winScanCodes[key] ?? 0;
    final vkCode = _winVkCodes[key] ?? 0;
    if (scanCode == 0) return;

    final input = calloc<INPUT>();
    input.ref.type = INPUT_KEYBOARD;
    input.ref.ki.wVk = vkCode;
    input.ref.ki.wScan = scanCode;
    input.ref.ki.dwFlags = KEYEVENTF_SCANCODE | (isDown ? 0 : KEYEVENTF_KEYUP);
    input.ref.ki.time = 0;
    input.ref.ki.dwExtraInfo = 0;

    SendInput(1, input, sizeOf<INPUT>());
    calloc.free(input);
  }
}

class MacOsKeyboardInjector {
  static late final DynamicLibrary _coreGraphics;
  static late final Pointer Function(Pointer, int, bool) _cgEventCreateKeyboardEvent;
  static late final void Function(Pointer, int) _cgEventSetFlags;
  static late final void Function(int, Pointer) _cgEventPost;
  static late final void Function(Pointer) _cfRelease;

  static late final Pointer Function(int) _cgEventSourceCreate;
  static late final void Function(Pointer, int) _cgEventSetType;
  static late final bool Function() _axIsProcessTrusted;
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
    _axIsProcessTrusted = _coreGraphics.lookupFunction<
        Bool Function(),
        bool Function()>('AXIsProcessTrusted');
    _initialized = true;
  }

  static bool checkAccessibilityPermission() {
    if (!Platform.isMacOS) return true;
    _init();
    return _axIsProcessTrusted();
  }

  static Future<void> openAccessibilitySettings() async {
    final url = Uri.parse('x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
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
      } else if (Platform.isWindows) {
        if (action.modifiers.contains(ModifierKey.shiftModifier)) {
          Win32KeyboardInjector.sendKey(PhysicalKeyboardKey.shiftLeft, true);
          await Future.delayed(const Duration(milliseconds: 36));
        }
        if (action.modifiers.contains(ModifierKey.controlModifier)) {
          Win32KeyboardInjector.sendKey(PhysicalKeyboardKey.controlLeft, true);
          await Future.delayed(const Duration(milliseconds: 36));
        }
        Win32KeyboardInjector.sendKey(action.key, true);
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
      } else if (Platform.isWindows) {
        Win32KeyboardInjector.sendKey(action.key, false);
        await Future.delayed(const Duration(milliseconds: 36));
        if (action.modifiers.contains(ModifierKey.controlModifier)) {
          Win32KeyboardInjector.sendKey(PhysicalKeyboardKey.controlLeft, false);
        }
        if (action.modifiers.contains(ModifierKey.shiftModifier)) {
          Win32KeyboardInjector.sendKey(PhysicalKeyboardKey.shiftLeft, false);
        }
      }
    }
  }
}
