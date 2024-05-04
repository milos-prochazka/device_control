import 'device_base.dart';

class DeviceList 
{
  // ignore: prefer_final_fields
  Map<dynamic, DeviceBase> _devices = {};

  DeviceBase? getDeviceById(dynamic deviceId) => _devices[deviceId];

  void addDevice(DeviceBase device) => _devices[device.id] = device;

  void removeDevice(DeviceBase device) 
  {
    _devices.remove(device.id);
    device.dispose();
  }

  void removeDeviceById(dynamic deviceId) 
  {
    final device = _devices.remove(deviceId);
    if (device != null) 
    {
      device.dispose();
    }
  }

  void getDeviceList() => _devices.values.toList();
}

final deviceList = DeviceList();