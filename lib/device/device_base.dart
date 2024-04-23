// ignore_for_file: unnecessary_getters_setters, unnecessary_this

import 'package:flutter/widgets.dart';

import 'device_list.dart';

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////

class DeviceBase 
{
  String? _name;
  String? _id;
  String? _type;
  String? _status;
  String? _description;
  int _subscribers = 0;

  Map<String, IoBase> io = {};
  Map<String, IoGetter> getters = {};

  DeviceBase(this._name, this._id, this._type, this._status, this._description);

  String get name => _name!;
  String get id => _id!;
  String get type => _type!;
  String get status => _status!;
  String get description => _description!;

  set name(String name) => _name = name;
  set id(String id) => _id = id;
  set type(String type) => _type = type;
  set status(String status) => _status = status;
  set description(String description) => _description = description;

  Map<String, dynamic> toMap() 
  {
    var map = <String, dynamic>{};
    map['name'] = _name;
    map['id'] = _id;
    map['type'] = _type;
    map['status'] = _status;
    map['description'] = _description;
    return map;
  }

  DeviceBase.fromMapObject(Map<String, dynamic> map) 
  {
    this._name = map['name'];
    this._id = map['id'];
    this._type = map['type'];
    this._status = map['status'];
    this._description = map['description'];
  }

  dynamic command(String cmd, {dynamic commandParam, dynamic value}) async 
  {
    return null;
  }

  IoBase getIo(String ioName) 
  {
    var result = getters[ioName] ?? io[ioName];
    if (result == null) 
    {
      result = IoBase(device: this, name: ioName, deviceId: id);
      io[ioName] = result;
    }
    return result;
  }

  void _subscribe() 
  {
    if (_subscribers++ == 0) 
    {
      print('First subscribe');
      onSubcribeFirst();
    }
  }

  void _unsubscribe() 
  {
    _subscribers--;
    if (_subscribers == 0) 
    {
      print('Last unsubscribe');
      onUnsubscribeLast();
    }
  }

  void onSubcribeFirst() {}

  void onUnsubscribeLast() {}

  void dispose() 
  {
    for (final item in io.entries) 
    {
      item.value._subscriptions.clear();
    }

    for (final item in getters.entries) 
    {
      item.value._subscriptions.clear();
    }

    _subscribers = 0;
    _name = null;
    _id = null;
    _type = null;
    _status = null;
    _description = null;
  }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////

class IoGetter extends IoBase 
{
  IoGetter({required DeviceBase super.device, required super.name, required super.deviceId});

  @override
  dynamic getValue(dynamic getParam) 
  {
    return null;
  }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////

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
    device!._subscribe();
    return result;
  }

  void _unsubscribe(NotifyState state) 
  {
    _subscriptions.remove(state);
    device!._unsubscribe();
  }

  void notifySubscribers() 
  {
    for (var item in _subscriptions.entries) 
    {
      item.key.notifyChange(this.device!, getValue(item.value.getParam));
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

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////

abstract class NotifyState<T extends StatefulWidget> extends State<T> 
{
  DeviceBase? device;
  dynamic ioValue;
  _IoSubscription? _subscription;

  void notifyChange(DeviceBase device, dynamic ioValue) 
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

  dynamic getValue(DeviceBase device, String ioName, {dynamic getParam, bool subscribe = true}) 
  {
    final io = device.getIo(ioName);

    if (subscribe && this._subscription == null) 
    {
      this._subscription = io._subscribe(this, getParam: getParam);
    }

    return io.getValue(getParam ?? _subscription?.getParam);
  }

  dynamic getValueById(dynamic deviceId, String ioName, {dynamic getParam, bool subscribe = true}) 
  {
    final device = getDeviceById(deviceId);
    return device != null ? getValue(device, ioName, getParam: getParam, subscribe: subscribe) : null;
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

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////

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

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////