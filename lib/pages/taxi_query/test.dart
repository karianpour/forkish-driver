import 'package:flutter/material.dart';
import 'package:functional_widget_annotation/functional_widget_annotation.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

part 'test.g.dart';

final LatLng center = LatLng(26.532065, 53.977069); // center of kish island
const leafLetAccessToken = "pk.eyJ1Ijoia2FyaWFucG91ciIsImEiOiJjazZkbGJtMWYwODNzM2VudmVpdzU5dDJhIn0.LCWmMFkfKR_qDeed8Gsnhw";

@widget
Widget test(BuildContext context) {
// MapController c = MapController();
// c.onRotationChanged()


  return FlutterMap(
    options: MapOptions(
      center: center,
      zoom: 13.0,
      onPositionChanged: (mp, r){
        print(r);
        print(mp.center.toString());
      },
      swPanBoundary: LatLng(26.485096, 53.869411),
      nePanBoundary: LatLng(26.604128, 54.059012),

    ),

    layers: [
      TileLayerOptions(
        urlTemplate: "https://api.tiles.mapbox.com/v4/"
            "{id}/{z}/{x}/{y}@2x.png?access_token={accessToken}",
        additionalOptions: {
          'accessToken': leafLetAccessToken,
          'id': 'mapbox.streets',

        },

      ),
      MarkerLayerOptions(
        markers: [
          Marker(
            width: 80.0,
            height: 80.0,
            point: center,
            builder: (ctx) =>
            Container(
              child: FlutterLogo(),
            ),
            anchorPos: AnchorPos.align(AnchorAlign.top),
          ),
        ],
      ),
    ],
  );
}
