import '/device/device_base.dart';
import 'device/io_base.dart';

class CounterDevice extends DeviceBase 
{
  final IoBase counter;

  CounterDevice(String name, String id)
  : counter = IoBase(name: 'counter', deviceId: id, value: 0),
  super(name, id, 'counter-device', '', 'A simple counter device') 
  {
    counter.device = this;
    io['counter'] = counter;
  }

  @override
  dynamic command(String cmd, {dynamic commandParam, dynamic value}) 
  {
    switch (cmd) 
    {
      case 'increment':
      {
        final cnt = getIo('counter');
        cnt.value = (cnt.getValue(null) as int? ?? 0) + 1;
      }
      break;
    }
  }
}