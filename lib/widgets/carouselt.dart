import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:scoped_model/scoped_model.dart';

import '../model/bluetooth.dart';

class Carousel extends StatelessWidget {
  const Carousel({Key? key, required this.onTap}) : super(key: key);

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<FlutterBleApp>(
        builder: (context, child, model) {
      var items = model.scanResults.values.toList();
      return _buildCarousel(context, items);
    });
  }

  Widget _buildCarousel(BuildContext context, List<ScanResult> scanResults) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const Spacer(),
        _buildCarouselTitle(context, scanResults),
        const Spacer(),
        SizedBox(
          height: 450.0,
          child: PageView.builder(
            controller: PageController(viewportFraction: 0.85),
            itemBuilder: (BuildContext context, int itemIndex) {
              return _buildCarouselItem(
                  context, scanResults.elementAt(itemIndex), itemIndex);
            },
            itemCount: scanResults.length,
          ),
        ),
        const Spacer(flex: 5),
      ],
    );
  }

  Widget _buildCarouselTitle(
      BuildContext context, List<ScanResult> scanResults) {
    var title = scanResults.length == 1 ? "Encontrado el dispositivo Beurer" : "Encontrado los dispositivos Beurer";
    return Text(title,
        style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold));
  }

  Widget _buildCarouselItem(
      BuildContext context, ScanResult result, int itemIndex) {
    return Stack(
      alignment: Alignment.topCenter,
      children: <Widget>[
        _buildButtonBoxOutside(result),
        _buildButtonBoxInside(),
        Column(
          children: <Widget>[
            const Spacer(flex: 4),
            Image.asset("assets/BM_85.png", height: 300),
            const Spacer(),
            _buildButtonBoxTitle(result.device.name),
            const Spacer(flex: 2),
          ],
        ),
        ScopedModelDescendant<FlutterBleApp>(builder: (context, child, model) {
          return InkWell(
            onTap: () {
              model.connect(result.device);
              onTap();
            },
          );
        })
      ],
    );
  }

  Widget _buildButtonBoxOutside(ScanResult result) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
      padding: const EdgeInsets.all(15.0),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(10.0),
        shape: BoxShape.rectangle,
        border: Border.all(
            color: Colors.greenAccent, width: 1.0, style: BorderStyle.solid),
      ),
    );
  }

  Widget _buildButtonBoxInside() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 15.0),
      padding: const EdgeInsets.all(15.0),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(10.0),
        shape: BoxShape.rectangle,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 5.0,
          ),
        ],
      ),
    );
  }

  Widget _buildButtonBoxTitle(String deviceName) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(
            deviceName,
            style: const TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Colors.black),
          ),
        )
      ],
    );
  }
}
