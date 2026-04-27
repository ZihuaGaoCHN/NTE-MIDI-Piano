import 'package:flutter/foundation.dart';
import 'package:flutter_midi_command/flutter_midi_command.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../keyboard_sim/keyboard_injector.dart';

class MidiState extends ChangeNotifier {
  final MidiCommand _midiCommand = MidiCommand();
  List<MidiDevice> _devices = [];
  MidiDevice? _selectedDevice;
  bool _isMappingEnabled = false;
  final Set<int> _pressedNotes = {};

  List<MidiDevice> get devices => _devices;
  MidiDevice? get selectedDevice => _selectedDevice;
  bool get isMappingEnabled => _isMappingEnabled;
  Set<int> get pressedNotes => _pressedNotes;

  MidiState() {
    _initMidi();
  }

  Future<void> _initMidi() async {
    _midiCommand.onMidiDataReceived?.listen((MidiPacket packet) {
      if (!_isMappingEnabled) return;
      _handleMidiPacket(packet);
    });

    _midiCommand.onMidiSetupChanged?.listen((String data) {
      scanDevices();
    });

    await scanDevices();

    // Try to restore previous selected device
    final prefs = await SharedPreferences.getInstance();
    final savedDeviceId = prefs.getString('selected_midi_device');
    if (savedDeviceId != null && _devices.isNotEmpty) {
      try {
        final deviceToSelect = _devices.firstWhere((d) => d.id == savedDeviceId);
        selectDevice(deviceToSelect);
      } catch (e) {
        // device not found
      }
    }
  }

  Future<void> scanDevices() async {
    _devices = await _midiCommand.devices ?? [];
    if (_selectedDevice != null) {
      try {
        _selectedDevice = _devices.firstWhere((d) => d.id == _selectedDevice!.id);
      } catch (e) {
        _selectedDevice = null;
        _isMappingEnabled = false;
      }
    }
    notifyListeners();
  }

  Future<void> selectDevice(MidiDevice? device) async {
    if (_selectedDevice != null && _selectedDevice != device) {
      _midiCommand.disconnectDevice(_selectedDevice!);
    }
    
    _selectedDevice = device;
    if (device != null) {
      try {
        await _midiCommand.connectToDevice(device);
      } catch (e) {
        debugPrint('connectToDevice error: $e');
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selected_midi_device', device.id);
    } else {
      _isMappingEnabled = false;
    }
    notifyListeners();
  }

  void toggleMapping(bool value) {
    if (_selectedDevice == null) return;
    _isMappingEnabled = value;
    if (!value) {
      _pressedNotes.clear();
    }
    notifyListeners();
  }

  void _handleMidiPacket(MidiPacket packet) {
    final data = packet.data;
    if (data.length >= 3) {
      final status = data[0];
      final note = data[1];
      final velocity = data[2];

      final isNoteOn = (status & 0xF0) == 0x90 && velocity > 0;
      final isNoteOff = (status & 0xF0) == 0x80 || ((status & 0xF0) == 0x90 && velocity == 0);

      if (isNoteOn) {
        if (!_pressedNotes.contains(note)) {
          _pressedNotes.add(note);
          KeyboardInjector.pressNoteDown(note);
          notifyListeners();
        }
      } else if (isNoteOff) {
        if (_pressedNotes.contains(note)) {
          _pressedNotes.remove(note);
          KeyboardInjector.releaseNoteUp(note);
          notifyListeners();
        }
      }
    }
  }

  @override
  void dispose() {
    _midiCommand.teardown();
    super.dispose();
  }
}
