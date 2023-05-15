// ignore_for_file: unnecessary_null_comparison
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter_application_tensiometro/model/bluetooth.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class DevicePage extends StatelessWidget {
  const DevicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<FlutterBleApp>(
        builder: (context, child, model) {
      return Scaffold(
          appBar: AppBar(
            title: Text(
                model.device != null ? model.device!.name : "Desconectado"),
            actions: _buildActionButtons(model),
          ),
          body: Column(children: <Widget>[
            _buildDeviceStateTile(context, model),
            _buildDeviceMetrics(context, model)
          ]));
    });
  }

  _buildActionButtons(FlutterBleApp model) {
    if (model.isConnected) {
      return <Widget>[
        IconButton(
          icon: const Icon(Icons.cancel),
          onPressed: () => model.disconnect(),
        )
      ];
    }
  }

  _buildDeviceStateTile(BuildContext context, FlutterBleApp model) {
    return ListTile(
      leading: (model.deviceState == BluetoothDeviceState.connected)
          ? const Icon(Icons.bluetooth_connected)
          : const Icon(Icons.bluetooth_disabled),
      title: Text(
          'El Dispositivo esta ${model.deviceState.toString().split('.')[1]}.'),
    );
  }

  _buildDeviceMetrics(BuildContext context, FlutterBleApp model) {
    Column column = Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        _buildMetric(
            "Bateria", model.battery?.toString() ?? "", "%", "bateria"),
        _buildMetric("Presion Sistolica", model.presSistolica?.toString() ?? "",
            "SYS/mmHg", "sistolica"),
        _buildMetric("Presion Diastolica",
            model.presDiastolica?.toString() ?? "", "DIA/mmHg", "diastolica"),
        _buildMetric("Pulso Medio", model.pulMedio?.toString() ?? "", "/min",
            "pulsomedio"),
        _buildMetric("Presion Arterial", model.presArterial?.toString() ?? "",
            "mmHg", "presion_arterial"),
      ],
    );

    return column;
  }

  //LLAMA A LAS IMAGENES Y CLASES _BUILDMETRIC
  _buildMetric(String name, String value, String unit, String image) {
    return ListTile(
      leading: Image.asset("assets/$image.png", height: 30),
      title: Text(name),
      subtitle: Text(unit),
      trailing: Text(value),
    );
  }
}
