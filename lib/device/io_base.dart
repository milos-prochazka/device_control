// ignore_for_file: unnecessary_this

import 'device_base.dart';
import 'package:flutter/widgets.dart';

import 'device_list.dart';

class IoBase 
{
  final Map<NotifyState, _IoSubscription> _subscriptions = {};
  String name = '';
  String deviceId = '';
  dynamic _value;
  DeviceBase? device;

  IoBase({this.name = '', this.deviceId = '', this.device, dynamic value}) : _value = value;

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
    if (this._value != value) 
    {
      this._value = value;
      notifySubscribers();
    }
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

  DeviceBase? getDeviceById(dynamic deviceId) 
  {
    return deviceList.getDeviceById(deviceId);
  }

  dynamic getValue(DeviceBase device, String ioName, {dynamic getParam}) 
  {
    final io = device.getIo(ioName);
    if (this._subscription == null) 
    {
      this._subscription = io._subscribe(this, getParam: getParam);
    }

    return io.getValue(getParam ?? _subscription?.getParam);
  }

  dynamic getValueById(dynamic deviceId, String ioName, {dynamic getParam}) 
  {
    final device = getDeviceById(deviceId);
    return device != null ? getValue(device, ioName, getParam: getParam) : null;
  }

  dynamic getVisualState(DeviceBase device, String ioName, {WidgetStateCreator? stateCreator, dynamic createParam}) 
  {
    final io = device.getIo(ioName);
    if (this._subscription != null) 
    {
      final subscription = this._subscription!;

      if (stateCreator != null) 
      {
        subscription.stateCreator = (createParam);
      }

      if (createParam != null) 
      {
        subscription.createParam = createParam;
      }

      if (subscription.state == null && subscription.stateCreator != null) 
      {
        subscription.state = subscription.stateCreator!(subscription.createParam);
      }
    } 
    else 
    {
      final subscription = io._subscribe(this, createParam: createParam, stateCreator: stateCreator);

      if (stateCreator != null) 
      {
        subscription.state = stateCreator(createParam);
      }

      this._subscription = subscription;
    }

    return this._subscription?.state;
  }

  dynamic getVisualStateById(dynamic deviceId, String ioName, {WidgetStateCreator? stateCreator, dynamic createParam}) 
  {
    final device = getDeviceById(deviceId);
    return device != null ? getVisualState(device, ioName, stateCreator: stateCreator, createParam: createParam) : null;
  }

  @override
  void dispose() 
  {
    super.dispose();
    _subscription?.io._unsubscribe(this);
  }
}