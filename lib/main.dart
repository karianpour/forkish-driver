import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:functional_widget_annotation/functional_widget_annotation.dart';
import 'package:mapir_gl/mapir_gl.dart';

part 'main.g.dart';

void main() async {
  // await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
  runApp(MyApp());
}

final LatLng center = const LatLng(26.532065, 53.977069);
// final LatLng center = const LatLng(35.708329, 51.409836);

@widget
Widget myApp() => MaterialApp(
      // debugShowCheckedModeBanner: false,
      // theme: ThemeData.dark(),
      home: Scaffold(
          appBar: AppBar(title: const Text('Mapir Map')),
          body: MapirMap(
            initialCameraPosition: CameraPosition(target: center, zoom: 14),
            myLocationEnabled: true,
            myLocationRenderMode: MyLocationRenderMode.NORMAL,
            // myLocationTrackingMode: ,
            zoomGesturesEnabled: true,

          ),
      ),
    );