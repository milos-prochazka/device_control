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

  _IoSubscription _subscribe(NotifyState state,
    {dynamic getParam, dynamic commandParam, dynamic createParam, WidgetStateCreator? stateCreator}) 
  {
    final result = _IoSubscription(this, getParam, commandParam, createParam, state, stateCreator);
    _subscriptions[state] = result;
    return result;
  }

  void _unsubscribe(NotifyState state) 
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

typedef WidgetStateCreator = dynamic Function(dynamic createParam);

abstract class NotifyState<T extends StatefulWidget> extends State<T> 
{
  DeviceBase? device;
  dynamic ioValue;
  _IoSubscription? _subscription;

  void notifyChange(DeviceBase? device, dynamic ioValue) 
  {
    if (this.mounted) 
    {
      this.device = device;
      this.ioValue = ioValue;
      setState(() {});
    }
  }

  dynamic getValue(DeviceBase device, String ioName, {dynamic getParam}) 
  {
    return device.getIo(ioName).getValue(getParam ?? _subscription?.getParam);
    // TODO: vytvoreni subscription, pokud treba
  }

  dynamic getVisualState(DeviceBase device, String ioName,
    {WidgetStateCreator? stateCreator, dynamic createParam, dynamic getParam}) 
  {
    if (this._subscription == null) 
    {
      var io = device.getIo(ioName);
      this._subscription =
      io._subscribe(this, getParam: getParam, createParam: createParam, stateCreator: stateCreator);
    }

    if (this._subscription?.state == null && this._subscription?.stateCreator != null) 
    {
      this._subscription!.state = this._subscription?.stateCreator!(this._subscription?.createParam);
    }

    return this._subscription?.state;
  }

  @override
  void dispose() 
  {
    super.dispose();
    _subscription?.io._unsubscribe(this);
  }
}