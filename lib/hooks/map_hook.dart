import 'dart:math';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:for_kish/helpers/types.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:rxdart/rxdart.dart';

// final LatLng center = const LatLng(26.542065, 53.987069); // center of kish island

class MapControllerWrapper {
  MapController controller;

  Position Function() currentLocation;

  void Function(bool c) setRequestingLocation;
  bool Function() getRequestingLocation;
  void Function(Location location) setLocation;
  Location Function() getLocation;
  void Function(LatLng center) centerChanged;

  void Function(Location location) setPickup;
  Location Function() getPickup;
  void Function(Location location) setDestination;
  Location Function() getDestination;
  void Function(bool c) setRequestingOffers;
  bool Function() getRequestingOffers;
  void Function(List<Offer> c) setOffers;
  List<Offer> Function() getOffers;
  void Function(Offer c) setSelectedOffer;
  Offer Function() getSelectedOffer;
  void Function(bool c) setRequestingRide;
  bool Function() getRequestingRide;
  void Function(Ride c) setRide;
  Ride Function() getRide;
  void Function(RideApproach c) setRideApproach;
  RideApproach Function() getRideApproach;
  void Function(RideProgress c) setRideProgress;
  RideProgress Function() getRideProgress;
  void Function() cancelRide;

  MapControllerWrapper({
    this.controller,
    this.currentLocation,
    this.setRequestingLocation, this.getRequestingLocation,
    this.setLocation, this.getLocation,
    this.centerChanged,
    this.setPickup, this.getPickup,
    this.setDestination, this.getDestination,
    this.setRequestingOffers, this.getRequestingOffers,
    this.setOffers, this.getOffers,
    this.setSelectedOffer, this.getSelectedOffer,
    this.setRequestingRide, this.getRequestingRide,
    this.setRide, this.getRide,
    this.setRideApproach, this.getRideApproach,
    this.setRideProgress, this.getRideProgress,
    this.cancelRide,
  });

  void moveToMyLocation() async {
    try{
      // final latlon = await _controller.requestMyLocationLatLng();
      // await Future.delayed(Duration(seconds: 5));
      final location = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      print(location.toJson());

      final latlon = LatLng(location.latitude, location.longitude);
      controller.move(latlon, controller.zoom);
    }catch(err){
      print(err);
    }
  }

  void dispose(){
    controller = null;
  }

  void confirmed() {
    if(getPickup()==null){
      setPickup(getLocation());
    }else if(getDestination()==null){
      setDestination(getLocation());
    }
  }
}
    
MapControllerWrapper useMapControllerHook() {
  return Hook.use(_MapControllerHook());
}

class _MapControllerHook extends Hook<MapControllerWrapper> {
  // final MapirMapController controller;

  // const _MapControllerHook({
    // @required this.controller
  _MapControllerHookState createState() => _MapControllerHookState();
}

class _MapControllerHookState extends HookState<MapControllerWrapper, _MapControllerHook> {
  MapControllerWrapper _wrapper;

  MapController _controller;
  bool firstTry = true;
  Position _currentLocation;
  StreamSubscription<Position> _positionStream;

  final _locationOnChange = new BehaviorSubject<LatLng>();
  bool _requestingLocation;
  Location _location;

  Location _pickup;
  Location _destination;
  bool _requestingOffers;
  List<Offer> _offers;
  Offer _selectedOffer;
  bool _requestingRide;
  bool _requestCancelled;
  Ride _ride;
  RideApproach _rideApproach;
  RideProgress _rideProgress;

  @override
  void initHook() {
    super.initHook();

    var locationOptions = LocationOptions(accuracy: LocationAccuracy.high, distanceFilter: 50);

    _positionStream = Geolocator().getPositionStream(locationOptions).listen(
      (Position position) {
        setState((){
          _currentLocation = position;
        });
        if(firstTry){
          _controller.move(LatLng(position.latitude, position.longitude), _controller.zoom);
          firstTry = false;
        }
        print(position == null ? 'Unknown' : position.latitude.toString() + ', ' + position.longitude.toString());
      }
    );

    _locationOnChange.debounceTime(Duration(milliseconds: 500)).listen((center) {
      // print(center.toString());
      queryForNewLocation(center);
    });

    _controller = MapController();

    _requestingLocation = false;

    _pickup = null;
    _destination = null;
    _requestingOffers = false;
    _requestingRide = false;
    _requestCancelled = false;
    _wrapper = MapControllerWrapper(
      controller: _controller,

      currentLocation: currentLocation,

      setRequestingLocation: setRequestingLocation,
      getRequestingLocation: getRequestingLocation,
      setLocation: setLocation,
      getLocation: getLocation,
      centerChanged: centerChanged,

      setPickup: setPickup,
      getPickup: getPickup,
      setDestination: setDestination,
      getDestination: getDestination,
      setRequestingOffers: setRequestingOffers,
      getRequestingOffers: getRequestingOffers,
      setOffers: setOffers,
      getOffers: getOffers,
      setSelectedOffer: setSelectedOffer,
      getSelectedOffer: getSelectedOffer,
      setRequestingRide: setRequestingRide,
      getRequestingRide: getRequestingRide,
      setRide: setRide,
      getRide: getRide,
      setRideApproach: setRideApproach,
      getRideApproach: getRideApproach,
      setRideProgress: setRideProgress,
      getRideProgress: getRideProgress,
      cancelRide: cancelRide,
    );
  }

  Position currentLocation() => _currentLocation;

  void setRequestingLocation(bool c){
    setState((){
      this._requestingLocation = c;
    });
  }

  bool getRequestingLocation(){
    return this._requestingLocation;
  }

  void setLocation(Location p){
    setState((){
      this._location = p;
    });
  }

  Location getLocation(){
    return this._location;
  }

  void setPickup(Location p){
    if(_ride!=null || _requestingRide) return;
    setState((){
      this._pickup = p;
    });
    requestOffers();
  }

  Location getPickup(){
    return this._pickup;
  }

  void setDestination(Location l){
    if(_ride!=null || _requestingRide) return;
    setState((){
      this._destination = l;
    });
    requestOffers();
  }

  Location getDestination(){
    return this._destination;
  }

  void setRequestingOffers(bool c){
    setState((){
      this._requestingOffers = c;
    });
  }

  bool getRequestingOffers(){
    return this._requestingOffers;
  }

  void setOffers(List<Offer> c){
    setState((){
      this._offers = c;
    });
  }

  List<Offer> getOffers(){
    return this._offers;
  }

  void setSelectedOffer(Offer c){
    setState((){
      this._selectedOffer = c;
    });
  }

  Offer getSelectedOffer(){
    return this._selectedOffer;
  }

  void setRequestingRide(bool c){
    setState((){
      this._requestingRide = c;
    });
    if(_requestingRide){
      requestRide();
    }
  }

  bool getRequestingRide(){
    return this._requestingRide;
  }

  void setRide(Ride c){
    setState((){
      this._ride = c;
    });
  }

  Ride getRide(){
    return this._ride;
  }

  void setRideApproach(RideApproach c){
    setState((){
      this._rideApproach = c;
    });
  }

  RideApproach getRideApproach(){
    return this._rideApproach;
  }

  void setRideProgress(RideProgress c){
    setState((){
      this._rideProgress = c;
    });
  }

  RideProgress getRideProgress(){
    return this._rideProgress;
  }


  @override
  MapControllerWrapper build(BuildContext context) {
    return _wrapper;
  }

  @override
  void dispose() {
    _wrapper.dispose();
    _positionStream.cancel();
    super.dispose();
  }

  void centerChanged(LatLng center) {
    _locationOnChange.add(center);
  }

  void queryForNewLocation(LatLng center) async {
    try{
      setState((){
        this._requestingLocation = true;
        this._location = null;
      });
      final location = await queryLocation(center.latitude, center.longitude);
      setState((){
        this._requestingLocation = false;
        this._location = location;
      });
    }catch(err){
      print(err);
      setState((){
        this._requestingLocation = false;
        this._location = null;
      });
    }
  }

  void requestOffers() async {
    if(_destination==null || _pickup==null)
      return;

    _controller.fitBounds(LatLngBounds(
      LatLng(_pickup.lat, _pickup.lng),
      LatLng(_destination.lat, _destination.lng),
    ), options: FitBoundsOptions(
      padding: const EdgeInsets.only(top: 250.0, bottom: 300, left: 30, right: 30),
    ));

    setState((){
      this._requestingOffers = true;
      this._offers = null;
      this._selectedOffer = null;
    });
    try{
      final offers = await fetchOffers(this._pickup, this._destination);
      setState((){
        this._requestingOffers = false;
        this._offers = offers;
        this._selectedOffer = offers.firstWhere( (o) => o.enabled, orElse: () => null );
      });
    }catch(err){
      setState((){
        this._requestingOffers = false;
        this._offers = null;
        this._selectedOffer = null;
      });
    }
  }

  void requestRide() async {
    if(_destination==null || _pickup==null || _selectedOffer == null)
      return;
    setState((){
      this._requestCancelled = false;
      this._requestingRide = true;
      this._ride = null;
      this._rideApproach = null;
      this._rideProgress = null;
    });
    try{
      final rideAndApproch = await fetchRide(this._pickup, this._destination, this._selectedOffer);
      // K1 : it might be the case the use requet , cancel , and request again, I have to find out which answer is canceled.
      if(this._requestCancelled){
        return;
      }
      setState((){
        this._requestingRide = false;
        this._ride = rideAndApproch.ride;
        this._rideApproach = rideAndApproch.rideApproach;
        this._rideProgress = null;
      });
    }catch(err){
      setState((){
        this._requestingRide = false;
        this._ride = null;
        this._rideApproach = null;
        this._rideProgress = null;
      });
    }
  }

  void cancelRide() {
    setState((){
      this._requestCancelled = true;
      this._requestingRide = false;
      this._ride = null;
      this._rideApproach = null;
      this._rideProgress = null;
    });
  }

}

var i = 0;

Future<Location> queryLocation(double lat, double lng) async {
  await Future.delayed(Duration(milliseconds: 500));
  i++;
  return Location(lat: lat, lng: lng, name: 'اینجا ${round(lat, decimals: 2).toString()}, ${round(lng, decimals: 2).toString()}', location: 'اونجا $i');
}

// });


Future<List<Offer>> fetchOffers(Location pickup, Location destination) async{
  await Future.delayed(Duration(milliseconds: 2000));
  // throw("error test");
  return <Offer> [
    Offer(vehicleType: VehicleType.sedan, price: 25000, enabled: true),
    Offer(vehicleType: VehicleType.hatchback, price: 15000, enabled: false),
    Offer(vehicleType: VehicleType.van, price: 55000, enabled: false),
  ];
}

Future<RideAndApproach> fetchRide(Location pickup, Location destination, Offer selectedOffer) async{
  await Future.delayed(Duration(seconds: 10));
  // throw("error test");
  return RideAndApproach(
    ride: Ride(
      driver: Driver(name: "اصغر طرقه", phone: "+989121161998", photoUrl: "", score: 4),
      vehicle: Vehicle(vehicleType: VehicleType.sedan, classNumber: "22", mainNumber: "12345"),
      paymentType: PaymentType.cash,
      price: 25000,
    ),
    rideApproach: RideApproach(distance: 5700, eta: 560, location: Location(lat: 26.564119755213248, lng: 53.98794763507246), bearing: 55, rideReady: false),
  );
}