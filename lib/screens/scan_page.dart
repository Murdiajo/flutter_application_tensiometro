import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../model/bluetooth.dart';
import '../widgets/carouselt.dart';
import 'device_page.dart';

class ScanPage extends StatelessWidget {
  const ScanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<FlutterBleApp>(
      builder: (context, child, model) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("MASTER MEDIC"),
          ),
          body: Stack(
            children: <Widget>[
              (model.isScanning) ? _buildProgressBarTile() : Container(),
              _buildBackgroundWidget(context, model),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProgressBarTile() {
    return const LinearProgressIndicator();
  }

  Widget _buildBackgroundWidget(BuildContext context, FlutterBleApp model) {
    var items = model.scanResults.values.toList();
    if (items.isNotEmpty && !model.isScanning) {
      return Stack(
        children: <Widget>[
          _buildScanAgainButton(model),
          Carousel(
            onTap: () => onTap(context),
          ),
        ],
      );
    } else if (model.isScanning) {
      return _buildScanningBackground();
    } else {
      startBluetooth(model);
      return _buildWaitingScanningBackground(model);
    }
  }

  Widget _buildScanAgainButton(FlutterBleApp model) {
    if (!model.isScanning) {
      return Container(
          padding: const EdgeInsets.all(15.0),
          alignment: Alignment.bottomRight,
          child: FloatingActionButton(
            onPressed: model.startScan,
            child: const Icon(Icons.search),
          ));
    } else {
      return Container();
    }
  }

  Widget _buildScanningBackground() {
    return SizedBox.expand(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Image.asset("assets/bluetooth_scan.png", height: 250),
        const SizedBox(height: 20),
        const Text("Scanning...",
            style: TextStyle(fontSize: 13.0, fontWeight: FontWeight.bold)),
      ],
    ));
  }

  Widget _buildWaitingScanningBackground(FlutterBleApp model) {
    return SizedBox.expand(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          _buildScanButton(model),
          const SizedBox(height: 20),
          const Text("Pulse el botón para escanear",
              style: TextStyle(fontSize: 13.0, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildScanButton(FlutterBleApp model) {
    return Ink.image(
      image: const AssetImage("assets/bluetooth.png"),
      fit: BoxFit.fill,
      height: 250,
      width: 250,
      child: InkWell(
        onTap: model.startScan,
      ),
    );
  }

  void startBluetooth(FlutterBleApp model) {
    if (!model.isConnected && model.state != BluetoothState.on) {
      model.init();
    }
  }

  void onTap(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DevicePage()),
    );
  }
}
