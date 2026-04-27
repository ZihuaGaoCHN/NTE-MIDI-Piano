import 'package:flutter/material.dart';
import '../logic/locale_state.dart';

class AppStrings {
  static const Map<String, Map<String, String>> _localizedValues = {
    'zh': {
      'home': '主页',
      'settings': '设置',
      'currentStatus': '当前状态',
      'notConnected': '未连接',
      'connected': '已连接',
      'noSignal': '未收到信号',
      'ready': '已就绪',
      'pleaseSelectDevice': '请先在设置中选择 MIDI 输入设备',
      'mappingStatus': '按键映射状态',
      'pressedNotes': '当前按下的 MIDI 音符:',
      'none': '无',
      'language': '语言',
      'systemDefault': '跟随系统',
      'deviceSettings': '设备设置',
      'midiInputDevice': 'MIDI 输入设备',
      'refreshDeviceList': '刷新设备列表',
      'selectDevice': '选择一个设备',
      'about': '关于',
      'version': '版本',
      'author': '作者',
      'authorName': 'ZihuaGaoCHN',
      'projectGithub': '项目 GitHub',
      'authorBilibili': '作者哔哩哔哩',
      'mappingInstruction': '《异环》钢琴映射说明:',
      'mappingDescription': '将 USB MIDI 键盘信号模拟为电脑键盘输入。',
      'mappingRange': '映射范围: C3 (48) 至 B5 (83)',
      'lowRegister': '低音区 (C3-B3): Z X C V B N M',
      'midRegister': '中音区 (C4-B4): A S D F G H J',
      'highRegister': '高音区 (C5-B5): Q W E R T Y U',
      'semiTones': '指定半音 (C#, Eb, F#, G#, Bb) 通过 Shift 和 Ctrl 组合触发。',
      'macOsWarning': '注意：在 macOS 上模拟按键可能需要辅助功能权限。请在 系统设置 → 隐私与安全性 → 辅助功能 中允许此应用。',
    },
    'en': {
      'home': 'Home',
      'settings': 'Settings',
      'currentStatus': 'Current Status',
      'notConnected': 'Not Connected',
      'connected': 'Connected',
      'noSignal': 'No Signal',
      'ready': 'Ready',
      'pleaseSelectDevice': 'Please select a MIDI input device in Settings first',
      'mappingStatus': 'Key Mapping Status',
      'pressedNotes': 'Currently pressed MIDI notes:',
      'none': 'None',
      'language': 'Language',
      'systemDefault': 'System Default',
      'deviceSettings': 'Device Settings',
      'midiInputDevice': 'MIDI Input Device',
      'refreshDeviceList': 'Refresh Device List',
      'selectDevice': 'Select a MIDI device',
      'about': 'About',
      'version': 'Version',
      'author': 'Author',
      'authorName': 'ZihuaGaoCHN',
      'projectGithub': 'Project GitHub',
      'authorBilibili': "Author's Bilibili",
      'mappingInstruction': 'NTE Piano Mapping Instruction:',
      'mappingDescription': 'Simulates USB MIDI keyboard signals as computer keyboard inputs.',
      'mappingRange': 'Mapping Range: C3 (48) to B5 (83)',
      'lowRegister': 'Low Register (C3-B3): Z X C V B N M',
      'midRegister': 'Mid Register (C4-B4): A S D F G H J',
      'highRegister': 'High Register (C5-B5): Q W E R T Y U',
      'semiTones': 'Semitones (C#, Eb, F#, G#, Bb) are triggered by combining Shift and Ctrl.',
      'macOsWarning': 'Note: Key simulation on macOS may require Accessibility permissions. Please allow this app in System Settings → Privacy & Security → Accessibility.',
    }
  };

  static String get(BuildContext context, String key) {
    final state = LocaleState.of(context);
    final langCode = state.currentLanguageCode;
    return _localizedValues[langCode]?[key] ?? _localizedValues['en']?[key] ?? key;
  }
}
