import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:for_kish/helpers/types.dart';
import 'package:mapir_gl/mapir_gl.dart';

final LatLng center = const LatLng(26.542065, 53.987069); // center of kish island

class MapControllerWrapper {
  MapirMapController _controller;
  Symbol _pickupSymbol;
  Symbol _destinationSymbol;
  void Function(Location location) setPickup;
  Location Function() getPickup;
  void Function(Location location) setDestination;
  Location Function() getDestination;
  void Function(bool c) setPickupConfirmed;
  bool Function() getPickupConfirmed;
  void Function(bool c) setDestinationConfirmed;
  bool Function() getDestinationConfirmed;
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

  MapControllerWrapper({
    this.setPickup, this.getPickup,
    this.setDestination, this.getDestination,
    this.setPickupConfirmed, this.getPickupConfirmed,
    this.setDestinationConfirmed, this.getDestinationConfirmed,
    this.setRequestingOffers, this.getRequestingOffers,
    this.setOffers, this.getOffers,
    this.setSelectedOffer, this.getSelectedOffer,
    this.setRequestingRide, this.getRequestingRide,
    this.setRide, this.getRide,
    this.setRideApproach, this.getRideApproach,
    this.setRideProgress, this.getRideProgress,
  });

  void onMapCreated(MapirMapController controller) {
    this._controller = controller;
    _controller.onSymbolTapped.add(_onSymbolTapped);
    // _controller.addCircle(
    //   CircleOptions(
    //     geometry: center,
    //     circleRadius: 60.0,
    //     circleStrokeColor: "#0000FF",
    //     circleStrokeWidth: 1.0,
    //     circleOpacity: 0.5,
    //     circleColor: "#FFFFFF",
    //     draggable: true,
    //   ),
    // );

    // _controller.addCircle(
    //   CircleOptions(
    //     geometry: LatLng(
    //       26.475096, 53.869411
    //     ),
    //     circleRadius: 60.0,
    //     circleStrokeColor: "#0000FF",
    //     circleStrokeWidth: 1.0,
    //     circleOpacity: 0.5,
    //     circleColor: "#FF0000",
    //     draggable: true,
    //   ),
    // );
    // _controller.addCircle(
    //   CircleOptions(
    //     geometry: LatLng(
    //       26.604128, 54.059012,
    //     ),
    //     circleRadius: 60.0,
    //     circleStrokeColor: "#0000FF",
    //     circleStrokeWidth: 1.0,
    //     circleOpacity: 0.5,
    //     circleColor: "#00FF00",
    //     draggable: true,
    //   ),
    // );

    // _controller.addSymbol(
    //   SymbolOptions(
    //     // iconRotate: 100,
    //     iconSize: 3.0,
    //     iconOpacity: 1.0,
    //     // iconOffset: Offset(0, -11),
    //     geometry: center,
    //     iconImage: "assets/map/marker.png",
    //     draggable: true,
    //   )
    // );
    moveToMyLocation();
  }

  void moveToMyLocation() async {
    try{
      // final latlon = await _controller.requestMyLocationLatLng();
      // await Future.delayed(Duration(seconds: 5));
      // TODO get the device location
      final latlon = center;
      _controller.moveCamera(CameraUpdate.newLatLng(latlon));
    }catch(err){
      print(err);
    }
  }

  void onMapClicked(Point<double> point, LatLng coordinates){
    print("${_controller?.cameraPosition?.target?.toString()} ${_controller?.cameraPosition?.zoom?.toString()}");
    // this.setPickup("Cli ${_controller?.cameraPosition?.target?.latitude} , ${_controller?.cameraPosition?.target?.longitude}");
    // _controller.addCircle(
    //   CircleOptions(
    //     geometry: LatLng(
    //       coordinates.latitude,
    //       coordinates.longitude,
    //     ),
    //     circleRadius: 60.0,
    //     circleStrokeColor: "#0000FF",
    //     circleStrokeWidth: 1.0,
    //     circleOpacity: 0.0,
    //     circleColor: "#FFFFFF",
    //     draggable: false,
    //   ),
    // );

    // _controller.addSymbol(
    //   SymbolOptions(
    //     // iconRotate: 100,
    //     iconSize: 1.0,
    //     iconOpacity: 1.0,
    //     iconOffset: Offset(0, -11),
    //     geometry: LatLng(coordinates.latitude, coordinates.longitude),
    //     iconImage: "assets/map/marker.png",
    //     draggable: true,
    //     zIndex: 100,
    //   ));
  }

  // void _updateSelectedSymbol(SymbolOptions changes) {
  //   _controller.updateSymbol(_selectedSymbol, changes);
  // }

  void _onSymbolTapped(Symbol symbol) {
    if(_pickupSymbol==symbol){
      setPickupConfirmed(true);
    }
    if(_destinationSymbol==symbol){
      setDestinationConfirmed(true);
    }
    // if (_selectedSymbol != null) {
    //   _updateSelectedSymbol(
    //     const SymbolOptions(iconSize: 1.0),
    //   );
    // }
    // _selectedSymbol = symbol;
    // _updateSelectedSymbol(
    //   SymbolOptions(
    //     iconSize: 5.0,
    //   ),
    // );
  }

  void dispose(){
    _controller?.onSymbolTapped?.remove(_onSymbolTapped);
    _controller = null;
  }

  // void onCameraTrackingChanged(MyLocationTrackingMode mode) {
  //   print(mode);
  // }

  // void onCameraTrackingDismissed() {
  //   print('dismissed');
  //   this.setPickup("${_controller?.cameraPosition?.target?.latitude} , ${_controller?.cameraPosition?.target?.longitude}");
  // }

  void setPickupSymbol(Location pickup) async {
    if(_pickupSymbol==null){
      if(pickup!=null){
        _pickupSymbol = await _controller.addSymbol(
          SymbolOptions(
            // iconRotate: 100,
            iconSize: 3.0,
            iconOpacity: 1.0,
            iconOffset: Offset(0, -11),
            geometry: LatLng(pickup.lat, pickup.lng),
            iconImage: "assets/map/pickup.png",
            draggable: false,
            // textField: 'Pickup',
          )
        );
      }
    }else{
      if(pickup!=null){
        await _controller.updateSymbol(_pickupSymbol, SymbolOptions(
          geometry: LatLng(pickup.lat, pickup.lng),
        ));
      }else{
        await _controller.removeSymbol(_pickupSymbol);
        _pickupSymbol = null;
      }
    }
    if(_pickupSymbol!=null){
      await _controller.moveCamera(CameraUpdate.newLatLng(_pickupSymbol.options.geometry));
    }else{
      setPickupConfirmed(false);
    }
  }

  void setDestinationSymbol(Location destination) async {
    if(_destinationSymbol==null){
      if(destination!=null){
        _destinationSymbol = await _controller.addSymbol(
          SymbolOptions(
            // iconRotate: 100,
            iconSize: 3.0,
            iconOpacity: 1.0,
            iconOffset: Offset(0, -11),
            geometry: LatLng(destination.lat, destination.lng),
            iconImage: "assets/map/destination.png",
            draggable: false,
            // textField: 'Destination',
          )
        );
      }
    }else{
      if(destination!=null){
        await _controller.updateSymbol(_destinationSymbol, SymbolOptions(
          geometry: LatLng(destination.lat, destination.lng),
        ));
      }else{
        await _controller.removeSymbol(_destinationSymbol);
        _destinationSymbol = null;
      }
    }
    if(_destinationSymbol!=null){
      await _controller.moveCamera(CameraUpdate.newLatLng(_destinationSymbol.options.geometry));
    }else{
      setDestinationConfirmed(false);
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
  // });

  @override
  _MapControllerHookState createState() => _MapControllerHookState();
}

class _MapControllerHookState extends HookState<MapControllerWrapper, _MapControllerHook> {
  MapControllerWrapper _wrapper;
  Location _pickup;
  bool _pickupConfirmed;
  Location _destination;
  bool _destinationConfirmed;
  bool _requestingOffers;
  List<Offer> _offers;
  Offer _selectedOffer;
  bool _requestingRide;
  Ride _ride;
  RideApproach _rideApproach;
  RideProgress _rideProgress;

  @override
  void initHook() {
    super.initHook();
    _pickup = null;
    _pickupConfirmed = false;
    _destination = null;
    _destinationConfirmed = false;
    _requestingOffers = false;
    _requestingRide = false;
    _wrapper = MapControllerWrapper(
      setPickup: setPickup,
      getPickup: getPickup,
      setPickupConfirmed: setPickupConfirmed,
      getPickupConfirmed: getPickupConfirmed,
      setDestination: setDestination,
      getDestination: getDestination,
      setDestinationConfirmed: setDestinationConfirmed,
      getDestinationConfirmed: getDestinationConfirmed,
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
    );
  }

  void setPickup(Location p){
    setState((){
      this._pickup = p;
    });
    _wrapper.setPickupSymbol(_pickup);
  }

  Location getPickup(){
    return this._pickup;
  }

  void setDestination(Location l){
    setState((){
      this._destination = l;
    });
    _wrapper.setDestinationSymbol(_destination);
  }

  Location getDestination(){
    return this._destination;
  }

  void setPickupConfirmed(bool c){
    setState((){
      this._pickupConfirmed = c;
    });
    requestOffers();
  }

  bool getPickupConfirmed(){
    return this._pickupConfirmed;
  }

  void setDestinationConfirmed(bool c){
    setState((){
      this._destinationConfirmed = c;
    });
    requestOffers();
  }

  bool getDestinationConfirmed(){
    return this._destinationConfirmed;
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
    super.dispose();
  }

  void requestOffers() async {
    if(!_destinationConfirmed || !_pickupConfirmed)
      return;
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
    if(!_destinationConfirmed || !_pickupConfirmed || _selectedOffer == null)
      return;
    setState((){
      this._requestingRide = true;
      this._ride = null;
      this._rideApproach = null;
      this._rideProgress = null;
    });
    try{
      final rideAndApproch = await fetchRide(this._pickup, this._destination, this._selectedOffer);
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
}

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