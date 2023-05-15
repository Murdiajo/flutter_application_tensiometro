import 'dart:async';
import 'dart:ffi';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:scoped_model/scoped_model.dart';

import '../util/constants.dart';

class FlutterBleApp extends Model {
  static final FlutterBleApp singleton = FlutterBleApp._internal();

  factory FlutterBleApp() {
    return singleton;
  }

  FlutterBleApp._internal();

  FlutterBluePlus flutterBlue = FlutterBluePlus.instance;

  /// Scanning
  StreamSubscription<ScanResult>? _scanSubscription;
  Map<DeviceIdentifier, ScanResult> scanResults = {};
  bool isScanning = false;

  /// State
  StreamSubscription? _stateSubscription;
  BluetoothState state = BluetoothState.unknown;

  /// Device
  BluetoothDevice? device;
  bool get isConnected => (device != null);
  StreamSubscription? deviceConnection;
  StreamSubscription? deviceStateSubscription;
  List<BluetoothService> services = [];
  Map<Guid, StreamSubscription> valueChangedSubscriptions = {};
  BluetoothDeviceState deviceState = BluetoothDeviceState.disconnected;

  // static const String kMYDEVICE = 'myDevice';
  String? myDeviceID;
  int? presSistolica;
  int? presDiastolica;
  int? pulMedio;
  int? battery;
  int? presArterial;

  void init() {
    // Obtener inmediatamente el estado de FlutterBlue
    flutterBlue.state.listen((s) {
      state = s;
      // ignore: avoid_print
      print('State init: $state');
      notifyListeners();
    });
    // Suscríbete a los cambios de estado
    _stateSubscription = flutterBlue.state.listen((s) {
      state = s;
      // ignore: avoid_print
      print('State updated: $state');
      notifyListeners();
    });

    _loadMyDeviceID();
  }

  _loadMyDeviceID() {
    // FlutterBluePlus flutterBlue = FlutterBluePlus.instance;
    flutterBlue.scan(timeout: const Duration(seconds: 5)).listen((scanResult) {
      for (var serviceUuid in scanResult.advertisementData.serviceUuids) {
        if (serviceUuid.toString() == "00002A00-0000-1000-8000-00805f9b34fb") {
          myDeviceID = serviceUuid.toString();
          // Puedes detener la búsqueda aquí si ya encontraste el UUID
          flutterBlue.stopScan();
          break;
        }
      }
    });
  }

  void dispose() {
    _stateSubscription?.cancel();
    _stateSubscription = null;
    _scanSubscription?.cancel();
    _scanSubscription = null;
    deviceConnection?.cancel();
    deviceConnection = null;
  }

  //SCANEO DE DISPOSITIVOS
  void startScan() {
    scanResults = {};
    _scanSubscription = flutterBlue
        .scan(
      timeout: const Duration(seconds: 5),
    )
        .listen((scanResult) {
      //if (scanResult.advertisementData.localName.startsWith('BM-'))
      {
        scanResults[scanResult.device.id] = scanResult;
        notifyListeners();
      }
    }, onDone: stopScan);

    isScanning = true;
    notifyListeners();
  }

  void stopScan() {
    _scanSubscription?.cancel();
    _scanSubscription = null;
    isScanning = false;
    notifyListeners();
  }

  //CONECTAR AL DISPOSITIVO
  connect(BluetoothDevice d) async {
    device = d;

    print('Dispositivo de conexión ${d.name}');
    // Conectar al dispositivo
    await device!.connect(timeout: const Duration(seconds: 4));

    // Actualizar el estado de la conexión inmediatamente
    device!.state.listen((s) {
      deviceState = s;
      notifyListeners();
    });

    // Suscríbete a los cambios de conexión
    deviceStateSubscription = device!.state.listen((s) {
      deviceState = s;
      notifyListeners();

      if (s == BluetoothDeviceState.connected) {
        device!.discoverServices().then((s) {
          services = s;
          _setNotifications();
          notifyListeners();
        });
      }
    });
  }

  //DESCONECTAR AL DISPOSITIVO
  disconnect() {
    // Eliminar todos los oyentes con cambio de valor
    valueChangedSubscriptions.forEach((uuid, sub) => sub.cancel());
    valueChangedSubscriptions.clear();
    deviceStateSubscription?.cancel();
    deviceStateSubscription = null;
    deviceConnection?.cancel();
    deviceConnection = null;
    device = null;
    notifyListeners();
  }

  _setNotifications() {
    _setNotification(_getCharacteristic(heartrateMeasurementUUID));
    _setNotification(_getCharacteristic(batteryserviceUUID));
    _setNotification(_getCharacteristic(systolicpressurecharacteristicUUID));
    _setNotification(_getCharacteristic(diastolicpressurecharacteristicUUID));
    _setNotification(_getCharacteristic(bloodpressureserviceUUID));
  }

  _getCharacteristic(String charUUID) {
    BluetoothCharacteristic? characteristic;
    for (BluetoothService s in services) {
      for (BluetoothCharacteristic c in s.characteristics) {
        if (c.uuid.toString() == charUUID) {
          characteristic = c;
          break;
        }
      }
      if (characteristic != null) {
        break;
      }
    }
    return characteristic;
  }

  _setNotification(BluetoothCharacteristic characteristic) async {
    if (characteristic != null) {
      await characteristic.setNotifyValue(true);
      final sub = characteristic.value.listen((d) {
        _onValuesChanged(characteristic);
        notifyListeners();
      });
      // Añadir al mapa
      valueChangedSubscriptions[characteristic.uuid] = sub;
      notifyListeners();
    }
  }

  _onValuesChanged(BluetoothCharacteristic characteristic) async {
    if (characteristic.value is List<int>) {
      List<int> data = characteristic.value as List<int>;
      String uuid = characteristic.uuid.toString();

      print('onValuesChanged ' + characteristic.value.toString() + " " + uuid);

      if (uuid == heartrateMeasurementUUID) {
        presSistolica = data[1];
      } else if (uuid == systolicpressurecharacteristicUUID) {
        presDiastolica = data[1];
      } else if (uuid == diastolicpressurecharacteristicUUID) {
        pulMedio = data[1];
      } else if (uuid == bloodpressureserviceUUID) {
        presArterial = data[1];
      } else if (uuid == batteryserviceUUID) {
        battery = data[0];
      }
    }
  }

  // Future<Void> getBatteryCharacteristic() async {
  //   batteryCharacteristic = await bluetoothDevice.getCharacteristic(charUUID);
  // }

}
