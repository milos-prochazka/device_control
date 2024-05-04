import 'dart:async';

import '/device/device_base.dart';

class CounterDevice extends DeviceBase 
{
  bool _stopwachRunning = false;
  Timer? _stopwatchTimer;
  Timer? _timer;
  int _stopwatchTime = 0;
  int _stopwatchStartTimestamp = 0;
  final IoBase counter;
  final IoBase stopwatch;
  final IoBase hours;
  final IoBase minutes;
  final IoBase seconds;

  CounterDevice(String name, String id)
  : counter = IoBase(name: 'counter', deviceId: id, value: 0),
  stopwatch = StopwatchGetter(name: 'stopwatch', deviceId: id),
  hours = TimerValue(name: 'hours', deviceId: id),
  minutes = TimerValue(name: 'minutes', deviceId: id),
  seconds = TimerValue
  (
    name: 'seconds',
    deviceId: id,
  ),
  super(name, id, 'counter-device', '', 'A simple counter device') 
  {
    mapIo(ioList: [counter, stopwatch, hours, minutes, seconds], getterList: [stopwatch]);
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

      case 'startTimer':
      {
        startTimer();
      }
      break;

      case 'stopTimer':
      {
        stopTimer();
      }
      break;
    }
  }

  @override
  void dispose() 
  {
    onUnsubscribeLast();
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
    if (_timer != null) 
    {
      _timer!.cancel();
      _timer = null;
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

  void startTimer() 
  {
    if (_timer != null) 
    {
      return;
    }

    DateTime start =
    DateTime.now().add(Duration(hours: hours.getValue(), minutes: minutes.getValue(), seconds: seconds.getValue()));

    _timer = Timer.periodic
    (
      const Duration(milliseconds: 250), (timer) 
      {
        final now = DateTime.now();
        var diff = start.difference(now);

        if (diff.inSeconds <= 0) 
        {
          timer.cancel();
          _timer = null;
          diff = const Duration();
        }

        hours.value = diff.inHours;
        minutes.value = diff.inMinutes.remainder(60);
        seconds.value = diff.inSeconds.remainder(60);
        seconds.doEvent('change');
      }
    );
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

  stopTimer() 
  {
    if (_timer != null) 
    {
      _timer!.cancel();
      _timer = null;
      seconds.notifySubscribers();
      minutes.notifySubscribers();
      hours.notifySubscribers();
    }
  }
}

class StopwatchGetter extends IoBase 
{
  StopwatchGetter({super.name, super.deviceId, super.device});

  @override
  dynamic getValue([dynamic getParam]) 
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

class TimerValue extends IoBase 
{
  TimerValue({super.name, super.deviceId, super.device}) : super(value: 0);

  @override
  dynamic getValue([dynamic getParam]) 
  {
    switch (getParam) 
    {
      case 'isRunning':
      return (device as CounterDevice)._timer != null;

      default:
      return super.getValue(getParam);
    }
  }
}