import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:for_kish_driver/helpers/types.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:rxdart/rxdart.dart';

MapControllerHookState useMapControllerHook() {
  return Hook.use(_MapControllerHook());
}

class _MapControllerHook extends Hook<MapControllerHookState> {
  MapControllerHookState createState() => MapControllerHookState();
}

class MapControllerHookState extends HookState<MapControllerHookState, _MapControllerHook> {
  MapController _controller;
  bool firstTry = true;
  Position _currentLocation;
  StreamSubscription<Position> _positionStream;
  void Function(Position) _locationChangeListener;

  final _locationOnChange = new BehaviorSubject<LatLng>();

  @override
  void initHook() {
    super.initHook();

    var locationOptions = LocationOptions(accuracy: LocationAccuracy.high, distanceFilter: 20);

    _positionStream = Geolocator().getPositionStream(locationOptions).listen(
      (Position position) {
        setState((){
          _currentLocation = position;
        });
        if(firstTry){
          _controller.move(LatLng(position.latitude, position.longitude), _controller.zoom);
          firstTry = false;
        }
        if(this._locationChangeListener != null) _locationChangeListener(position);
        // print(position == null ? 'Unknown' : position.latitude.toString() + ', ' + position.longitude.toString());
      }
    );

    _controller = MapController();
  }

  informMeAboutLocationChanged (void Function(Position) locationChangeListener){
    this._locationChangeListener = locationChangeListener;
  }

  MapController get controller => _controller;

  Position currentLocation() => _currentLocation;

  @override
  MapControllerHookState build(BuildContext context) {
    return this;
  }

  @override
  void dispose() {
    // _wrapper.dispose();
    _positionStream.cancel();
    super.dispose();
  }

  void centerChanged(LatLng center) {
    _locationOnChange.add(center);
  }

  void moveCamera(Ride ride) async {
    if(!_controller.ready){
      await _controller.onReady;
    }
    _controller?.fitBounds(LatLngBounds(
      LatLng(ride.pickup.lat, ride.pickup.lng),
      LatLng(ride.destination.lat, ride.destination.lng),
    ), options: FitBoundsOptions(
      padding: const EdgeInsets.only(top: 350.0, bottom: 200, left: 30, right: 30),
    ));
  }
}
