// ignore_for_file: unnecessary_getters_setters

import 'package:device_control/device/io_base.dart';

class DeviceBase 
{
  String? _name;
  String? _id;
  String? _type;
  String? _status;
  String? _description;

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
}

class IoGetter extends IoBase 
{
  IoGetter({required DeviceBase super.device, required super.name, required super.deviceId});

  @override
  dynamic getValue(dynamic getParam) 
  {
    return null;
  }
}