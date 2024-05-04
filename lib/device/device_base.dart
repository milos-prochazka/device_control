// ignore_for_file: unnecessary_getters_setters, unnecessary_this

import 'package:flutter/widgets.dart';

import 'device_list.dart';

/// ### Kořenová třída pro všechna zařízení.
/// Z této třídy dědí všechna zařízení.
/// - Obsahuje základní informace o zařízení.
/// - Obsahuje seznam I/O a Getters
/// - Obsahuje metody pro práci s I/O a Getters
/// - Obsahuje metody pro zpracování příkazů
/// - Obsahuje metody pro práci s odběrateli
/// - Obsahuje metody pro uvolnění prostředků
/// - Obsahuje metody pro zpracování příkazů
///
class DeviceBase 
{
  String? _name;
  String? _id;
  String? _type;
  String? _status;
  String? _description;
  int _subscribers = 0;

  Map<String, IoBase> io = {};
  Map<String, IoBase> getters = {};

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

  /// Nastaví referenci na zařízení pro všechny I/O a Getters
  /// - Používá se při vytváření nového zařízení
  /// - Musí se zavolat po vytvoření všech I/O a Getters v hlavičce konstruktoru (nelze u nich předávat this)
  void setDeviceReference() 
  {
    for (final item in io.entries) 
    {
      item.value.device = this;
    }

    for (final item in getters.entries) 
    {
      item.value.device = this;
    }
  }

  /// Mapuje I/O a Getters na zařízení
  /// - Používá se v konstruktoru zařízení.
  /// - Zároveň nastavuje referenci na zařízení pro I/O a Getters.
  /// Parametry:
  /// - ioList: seznam I/O, které se mapují na zařízení
  /// - getterList: seznam Getters, které se mapují na zařízení
  void mapIo({List<IoBase>? ioList, List<IoBase>? getterList}) 
  {
    if (ioList != null) 
    {
      for (final item in ioList) 
      {
        this.io[item.name] = item;
        item.device = this;
      }
    }

    if (getterList != null) 
    {
      for (final item in getterList) 
      {
        this.getters[item.name] = item;
        item.device = this;
      }
    }
  }

  /// Zpracování příkazu
  /// - Určeno k přepsání v potomcích
  /// - Používá se pro zpracování příkazů z vizuálních prvků.
  /// - Typy parametrů jsou volitelné podle implementace.
  ///
  /// Parametry:
  /// - cmd: příkaz
  /// - commandParam: parametr příkazu
  /// - value: hodnota příkazu
  /// - Vrací: výsledek zpracování příkazu
  dynamic command(dynamic cmd, {dynamic commandParam, dynamic value}) async 
  {
    return null;
  }

  /// Uvolnění prostředků
  /// - **Musí se zavolat v potomkovi (poud potomek přepíše dispose).**
  /// - **Seznam zařízení musí korektně volat dispose, vždy když se zařízení odstraní.**
  /// --------------------------------
  /// - Volá se při odstranění zařízení
  /// - Uvolní všechny I/O a Getters
  /// - Uvolní všechny odběratele
  /// - Nastaví všechny I/O a Getters na null
  /// - Nastaví všechny proměnné na null
  /// - Nastaví počet odběratelů na 0
  @mustCallSuper
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
}

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////

class IoBase 
{
  final Map<IoNotifyState, _IoSubscription> _subscriptions = {};
  String name = '';
  String deviceId = '';
  dynamic _value;
  DeviceBase? device;

  IoBase({this.name = '', this.deviceId = '', this.device, dynamic value}) : _value = value;

  _IoSubscription _subscribe(IoNotifyState state) 
  {
    var result = _subscriptions[state];
    if (result == null) 
    {
      result = _IoSubscription(this);
      _subscriptions[state] = result;
      device!._subscribe();
    }
    return result;
  }

  void _unsubscribe(IoNotifyState state) 
  {
    _subscriptions.remove(state);
    device!._unsubscribe();
  }

  _IoSubscription? _getSubscription(IoNotifyState state) => _subscriptions[state];

  void notifySubscribers() 
  {
    for (var item in _subscriptions.entries) 
    {
      item.key.notifyChange(this.device!, name);
    }
  }

  dynamic getValue([dynamic getParam]) => _value;
  dynamic get value => getValue();

  setValue(dynamic value, [dynamic setParam]) 
  {
    if (this._value != value) 
    {
      this._value = value;
      notifySubscribers();
    }
  }

  set value(dynamic value) => setValue(value);

  void doEvent(dynamic event, [dynamic eventParam]) 
  {
    for (var item in _subscriptions.entries) 
    {
      item.value.eventCallback?.call(device!, name, event, eventParam);
    }
  }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////

abstract class IoNotifyState<T extends StatefulWidget> extends State<T> 
{
  final subscribedIos = <String, IoBase>{};

  void notifyChange(DeviceBase device, String ioName) 
  {
    if (this.mounted) 
    {
      setState(() {});
    }
  }

  DeviceBase? getDeviceById(dynamic deviceId) 
  {
    return deviceList.getDeviceById(deviceId);
  }

  IoBase _getIo(DeviceBase device, String ioName) 
  {
    var result = subscribedIos[ioName];
    if (result == null) 
    {
      result = device.getIo(ioName);
      subscribedIos[ioName] = result;
    }
    return result;
  }

  dynamic getValue(DeviceBase device, String ioName, {dynamic getParam, bool subscribe = true}) 
  {
    final io = _getIo(device, ioName);

    if (subscribe && io._getSubscription(this) == null) 
    {
      io._subscribe(this);
    }

    return io.getValue(getParam);
  }

  dynamic getValueById(dynamic deviceId, String ioName, {dynamic getParam, bool subscribe = true}) 
  {
    final device = getDeviceById(deviceId);
    return device != null ? getValue(device, ioName, getParam: getParam, subscribe: subscribe) : null;
  }

  void setValue(DeviceBase device, String ioName, dynamic value, {dynamic setParam}) 
  {
    final io = _getIo(device, ioName);
    io.value = value;
  }

  void setValueById(dynamic deviceId, String ioName, dynamic value, {dynamic setParam}) 
  {
    final device = getDeviceById(deviceId);
    if (device != null) 
    {
      setValue(device, ioName, value, setParam: setParam);
    }
  }

  dynamic getVisualState(DeviceBase device, String ioName, {WidgetStateCreator? stateCreator, dynamic createParam}) 
  {
    final io = _getIo(device, ioName);
    var subscription = io._getSubscription(this);

    if (subscription != null) 
    {
      if (subscription.state == null && stateCreator != null) 
      {
        subscription.state = stateCreator(createParam);
      }
    } 
    else 
    {
      subscription = io._subscribe(this);

      if (stateCreator != null) 
      {
        subscription.state = stateCreator(createParam);
      }
    }

    return subscription.state;
  }

  dynamic getVisualStateById(dynamic deviceId, String ioName, {WidgetStateCreator? stateCreator, dynamic createParam}) 
  {
    final device = getDeviceById(deviceId);
    return device != null ? getVisualState(device, ioName, stateCreator: stateCreator, createParam: createParam) : null;
  }

  void subscribeEvent(DeviceBase device, String ioName, EventCallback? eventCallback) 
  {
    final io = _getIo(device, ioName);
    final subcription = io._subscribe(this);
    subcription.eventCallback = eventCallback;
  }

  void subscribeEventById(dynamic deviceId, String ioName, EventCallback? eventCallback) 
  {
    final device = getDeviceById(deviceId);
    if (device != null) 
    {
      subscribeEvent(device, ioName, eventCallback);
    }
  }

  @override
  void dispose() 
  {
    super.dispose();
    for (final item in subscribedIos.entries) 
    {
      item.value._unsubscribe(this);
    }
  }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////

class _IoSubscription 
{
  IoBase io;
  dynamic state;
  EventCallback? eventCallback;

  _IoSubscription(this.io);
}

typedef WidgetStateCreator = dynamic Function(dynamic createParam);
typedef EventCallback = void Function(DeviceBase device, String ioName, dynamic event, dynamic eventParam);

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////