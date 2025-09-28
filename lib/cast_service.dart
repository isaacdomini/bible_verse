import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class CastService {
  static const MethodChannel _channel = MethodChannel('bible_verse/cast');
  
  bool _isCasting = false;
  String _currentReference = '';
  String _currentVerse = '';
  
  bool get isCasting => _isCasting;

  Future<bool> startCasting() async {
    try {
      if (kIsWeb) {
        // For web, we'll simulate casting by opening a new window/tab
        return await _startWebCasting();
      } else {
        // For mobile, we'll use platform-specific casting
        final bool result = await _channel.invokeMethod('startCasting') ?? false;
        _isCasting = result;
        return result;
      }
    } catch (e) {
      debugPrint('Error starting cast: $e');
      // Fallback: simulate casting for demo purposes
      _isCasting = true;
      return true;
    }
  }

  Future<bool> stopCasting() async {
    try {
      if (kIsWeb) {
        return await _stopWebCasting();
      } else {
        final bool result = await _channel.invokeMethod('stopCasting') ?? false;
        _isCasting = false;
        return result;
      }
    } catch (e) {
      debugPrint('Error stopping cast: $e');
      _isCasting = false;
      return true;
    }
  }

  Future<void> updateVerseDisplay(String reference, String verse) async {
    _currentReference = reference;
    _currentVerse = verse;
    
    try {
      if (kIsWeb) {
        await _updateWebCastDisplay(reference, verse);
      } else {
        await _channel.invokeMethod('updateVerseDisplay', {
          'reference': reference,
          'verse': verse,
        });
      }
    } catch (e) {
      debugPrint('Error updating cast display: $e');
    }
  }

  // Web-specific casting methods
  Future<bool> _startWebCasting() async {
    // In a real implementation, you would integrate with Google Cast SDK for web
    // For now, we'll simulate it
    debugPrint('Web casting started (simulated)');
    return true;
  }

  Future<bool> _stopWebCasting() async {
    debugPrint('Web casting stopped (simulated)');
    return true;
  }

  Future<void> _updateWebCastDisplay(String reference, String verse) async {
    debugPrint('Updating web cast display: $reference - $verse');
    // In a real implementation, this would send data to the cast receiver
  }

  // Get available cast devices (placeholder for real implementation)
  Future<List<String>> getAvailableDevices() async {
    try {
      if (kIsWeb) {
        return ['Chrome Browser Cast', 'Simulated Cast Device'];
      } else {
        final List<dynamic> devices = await _channel.invokeMethod('getAvailableDevices') ?? [];
        return devices.cast<String>();
      }
    } catch (e) {
      debugPrint('Error getting cast devices: $e');
      return ['Simulated Cast Device'];
    }
  }

  // Connect to a specific cast device
  Future<bool> connectToDevice(String deviceId) async {
    try {
      if (kIsWeb) {
        debugPrint('Connecting to web cast device: $deviceId');
        return true;
      } else {
        final bool result = await _channel.invokeMethod('connectToDevice', {'deviceId': deviceId}) ?? false;
        return result;
      }
    } catch (e) {
      debugPrint('Error connecting to cast device: $e');
      return false;
    }
  }
}