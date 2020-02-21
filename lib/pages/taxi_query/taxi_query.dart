import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:for_kish_driver/models/map_hook.dart';
import 'package:latlong/latlong.dart';
import 'package:functional_widget_annotation/functional_widget_annotation.dart';


part 'taxi_query.g.dart';

final LatLng center = LatLng(26.532065, 53.977069); // center of kish island
// const leafLetAccessToken = "pk.eyJ1Ijoia2FyaWFucG91ciIsImEiOiJjazZkbGJtMWYwODNzM2VudmVpdzU5dDJhIn0.LCWmMFkfKR_qDeed8Gsnhw";
const leafLetAccessToken = "pk.eyJ1Ijoia2FyaWFucG91ciIsImEiOiJjazZnY21iMW4wMnV0M21wOGFwazl0MXVkIn0.58NkL2VWsgUo16JGBz2CZw";

@widget
Widget taxiQuery(BuildContext context) {
  final state = useMapControllerHook();

  return Stack(
    children: <Widget>[
      MapArea(state: state),
    ],
  );
}

class MapArea extends StatelessWidget {
  const MapArea({
    Key key,
    @required this.state,
  }) : super(key: key);

  final MapControllerHookState state;

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: state.controller,
      options: MapOptions(
        center: center,
        minZoom: 10,
        maxZoom: 18,
        zoom: 15.0,
        onPositionChanged: (mp, r){
          state.centerChanged(mp.center);
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
        CircleLayerOptions(
          circles: [
            if(state.currentLocation()!=null) CircleMarker(
              point: LatLng(state.currentLocation().latitude, state.currentLocation().longitude),
              radius: 7,
              color: Colors.blue,
            ),
          ],
        ),
      ],
    );
  }
}
