// ignore_for_file: unnecessary_this

import 'package:device_control/device/device_base.dart';
import 'package:flutter/widgets.dart';

class IoBase 
{
  final Map<NotifyState, _IoSubscription> _subscriptions = {};
  String name = '';
  String deviceId = '';
  dynamic _value;
  DeviceBase? device;

  void subscribe(NotifyState state, {dynamic getParam, dynamic commandParam, dynamic createParam, WidgetStateCreator? stateCreator}) 
  {
    _subscriptions[state] = _IoSubscription(this,getParam, commandParam, createParam, state, stateCreator);
  }

  void unsubscribe(NotifyState state) 
  {
    _subscriptions.remove(state);
  }

  void notifySubscribers() 
  {
    for (var item in _subscriptions.entries) 
    {
      item.key.notifyChange(this.device, getValue(item.value.getParam));
    }
  }

  dynamic getValue(dynamic getParam) => _value;

  set value(dynamic value) 
  {
    _value = value;
    notifySubscribers();
  }
}

class _IoSubscription 
{
  IoBase io;
  dynamic getParam;
  dynamic commandParam;
  dynamic createParam;
  dynamic state;
  WidgetStateCreator? stateCreator;

  _IoSubscription(this.io, this.getParam, this.commandParam, this.createParam, this.state, this.stateCreator);
}

typedef WidgetStateCreator = void Function(dynamic createParam);

abstract class NotifyState<T extends StatefulWidget> extends State<T> 
{
  DeviceBase? device;
  dynamic ioValue;
  _IoSubscription? _subscription;


  void notifyChange(DeviceBase ?device,  dynamic ioValue) 
  {
    if (this.mounted) 
    {
      this.device = device;
      this.ioValue = ioValue;
      setState(() {});
    }
  }

  dynamic getValue(DeviceBase device, String ioName)
  {
    return device.io[ioName]?.getValue(null);
  }

  @override
  void dispose() 
  {
    super.dispose();
    _subscription?.io.unsubscribe(this);
  }
}