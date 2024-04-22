// ignore_for_file: unnecessary_getters_setters

import 'package:device_control/device/io_base.dart';

class DeviceBase 
{
  String? _name;
  String? _id;
  String? _type;
  String? _status;
  String? _description;

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

  command(String io, dynamic commandParam, dynamic value) {}

  IoBase getIo(String io) 
  {
    return IoBase();
  }
}