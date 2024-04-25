import 'dart:async';

import '/device/device_base.dart';

class CounterDevice extends DeviceBase 
{
  bool _stopwachRunning = false;
  Timer? _stopwatchTimer = null;
  int _stopwatchTime = 0;
  int _stopwatchStartTimestamp = 0;
  final IoBase counter;
  final IoGetter stopwatch;
  final IoBase hours;
  final IoBase minutes;
  final IoBase seconds;

  CounterDevice(String name, String id)
  : counter = IoBase(name: 'counter', deviceId: id, value: 0),
  stopwatch = StopwatchGetter(name: 'stopwatch', deviceId: id),
  hours = IoBase(name: 'hours', deviceId: id, value: 0),
  minutes = IoBase(name: 'minutes', deviceId: id, value: 0),
  seconds = IoBase(name: 'seconds', deviceId: id, value: 0),
  super(name, id, 'counter-device', '', 'A simple counter device') 
  {
    io['counter'] = counter;
    getters['stopwatch'] = stopwatch;
    io['hours'] = hours;
    io['minutes'] = minutes;
    io['seconds'] = seconds;

    setDeviceReference();
  }

  @override
  dynamic command(dynamic cmd, {dynamic commandParam, dynamic value}) 
  {
    switch (cmd as String) 
    {
      case 'increment':
      {
        final cnt = getIo('counter');
        cnt.value = (cnt.getValue(null) as int? ?? 0) + 1;
      }
      break;

      case 'start':
      {
        startStopwatch(true);
      }
      break;
    }
  }

  @override
  void dispose() 
  {
    super.dispose();
  }

  @override
  void onSubcribeFirst() {}

  @override
  void onUnsubscribeLast() 
  {
    if (_stopwatchTimer != null) 
    {
      _stopwatchTimer!.cancel();
      _stopwatchTimer = null;
    }
  }

  void startStopwatch(bool reset) 
  {
    if (_stopwachRunning) 
    {
      return;
    }
    _stopwachRunning = true;
    if (reset) 
    {
      _stopwatchTime = 0;
      _stopwatchStartTimestamp = DateTime.now().millisecondsSinceEpoch;
    } 
    else 
    {
      final now = DateTime.now().millisecondsSinceEpoch;
      _stopwatchStartTimestamp = now - _stopwatchTime;
    }

    _stopwatchTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) => timeUpdate());
  }

  void timeUpdate() 
  {
    if (_stopwachRunning) 
    {
      final now = DateTime.now().millisecondsSinceEpoch;
      _stopwatchTime = now - _stopwatchStartTimestamp;
    }

    stopwatch.notifySubscribers();
  }
}

class StopwatchGetter extends IoGetter 
{
  StopwatchGetter({super.name, super.deviceId, super.device});

  @override
  dynamic getValue(dynamic getParam) 
  {
    final device = this.device as CounterDevice;
    switch (getParam) 
    {
      case 'isRunning':
      {
        return device._stopwachRunning;
      }

      default:
      {
        var t = device._stopwatchTime;
        final hour = t ~/ 3600000;
        final min = (t % 3600000) ~/ 60000;
        final sec = (t % 60000) ~/ 1000;
        final ms = t % 1000;

        return '$hour:${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}.${ms.toString().padLeft(3, '0')}';
      }
    }
  }
}