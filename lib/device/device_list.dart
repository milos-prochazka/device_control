import 'device_base.dart';

class DeviceList 
{
  Map<dynamic, DeviceBase> _devices = {};

  DeviceBase? getDeviceById(dynamic deviceId) => _devices[deviceId];

  void addDevice(DeviceBase device) => _devices[device.id] = device;

  void removeDevice(DeviceBase device) => _devices.remove(device.id);

  void removeDeviceById(dynamic deviceId) => _devices.remove(deviceId);

  void getDeviceList() => _devices.values.toList();
}

final deviceList = DeviceList();