import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:for_kish_driver/api/work.dart';
import 'package:for_kish_driver/helpers/types.dart';
import 'package:for_kish_driver/models/map_hook.dart';
import 'package:geolocator/geolocator.dart';

class Work with ChangeNotifier {
  bool loaded = false;
  Driver driver;
  bool active = false;
  Ride ride;
  bool accepted;
  Passenger passenger;
  bool arrived;
  bool confirmed;
  bool pickedup;
  bool accomplished;

  MapControllerHookState controller;

  Work();

  void load(Driver driver) async{
    if(loaded) return;
    this.driver = driver;
    registerWork(this);
    fetchWorkState();
  }

  void reinitialize(){
    loaded = false;
    fetchWorkState();
    notifyListeners();
  }

  void setupState(DriverState driverState){
    this.loaded = true;
    if(driverState!=null){
      this.active = driverState.active;
      this.ride = driverState.ride;
      this.accepted = driverState.accepted;
      this.passenger = driverState.passenger;
      this.arrived = driverState.arrived;
      this.confirmed = driverState.confirmed;
      this.pickedup = driverState.pickedup;
      this.accomplished = driverState.accomplished;
      if(controller!=null && ride!=null){
        controller.moveCamera(ride);
      }
    }
    notifyListeners();
  }

  Future<void> activate() async {
    if(this.active) return;
    try{
      var currentPosition = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      await fetchActivate(driver.vehicles[0].id, currentPosition, this);
    }catch(err){
      print(err);
    }
  }

  void activated(bool active) {
    this.active = active;
    notifyListeners();
  }

  Future<void> locationChanged(Position position) async{
    print(position == null ? 'Unknown' : position.latitude.toString() + ', ' + position.longitude.toString());
  }

  Future<void> inactivate() async {
    if(!this.active) return;
    try{
      var currentPosition = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      await fetchInactivate(currentPosition);
    }catch(err){
      print(err);
    }
  }

  void offerRide(Ride ride) {
    if(!this.active) return;
    if(ride!=null){
      this.ride = ride;
      this.accepted = false;
      if(controller!=null){
        controller.moveCamera(ride);
      }
      notifyListeners();
    }else{
      this.ride = null;
      this.accepted = false;
      notifyListeners();
    }
  }

  void rejectRide() async{
    if(this.ride==null || (this.accepted ?? false)) return;
    try{
      var rejectingRide = this.ride;
      resetRide();
      var currentPosition = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      await fetchRejectRide(rejectingRide.id, currentPosition);
    }catch(err){
      print(err);
    }
  }

  void cancelRide() async{
    if(this.ride==null || !(this.accepted ?? false) || (this.accomplished ?? false)) return;
    try{
      var cancellingRide = this.ride;
      resetRide();
      var currentPosition = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      await fetchCancelRide(cancellingRide.id, currentPosition);
    }catch(err){
      print(err);
    }
  }

  Future<void> acceptRide() async{
    if(this.ride==null || (this.accepted ?? false)) return;
    try{
      var currentPosition = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      await fetchAcceptRide(ride.id, currentPosition);
    }catch(err){
      print(err);
    }
  }

  void rideAccepted(Passenger passenger, String rideId) {
    if(passenger != null){
      this.accepted = true;
      this.passenger = passenger;
      this.ride.id = rideId;
      this.arrived = false;
      this.confirmed = false;
      this.pickedup = false;
      this.accomplished = false;
    }else{
      this.ride = null;
    }
    notifyListeners();
  }

  void rideConfirmed() {
    this.confirmed = true;
    notifyListeners();
  }

  Future<void> declareArrived() async{
    if(this.ride==null || (this.arrived ?? false)) return;
    try{
      var currentPosition = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      await fetchArrived(ride.id, currentPosition);
    }catch(err){
      print(err);
    }
  }

  void arrivedRecieved() {
    this.arrived = true;
    notifyListeners();
  }

  Future<void> declarePickedup() async{
    if(this.ride==null || (this.pickedup ?? false)) return;
    try{
      var currentPosition = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      await fetchPickedup(ride.id, currentPosition);
    }catch(err){
      print(err);
    }
  }

  void pickedupRecieved() {
    this.pickedup = true;
    notifyListeners();
  }

  Future<void> declareAccomplished() async{
    if(this.ride==null || (this.accomplished ?? false)) return;
    try{
      var currentPosition = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      await fetchAccomplished(ride.id, currentPosition);
    }catch(err){
      print(err);
    }
  }

  void accomplishedRecieved() {
    resetRide();
  }

  void resetRide(){
    this.ride = null;
    this.accepted = null;
    this.passenger = null;
    this.arrived = null;
    this.confirmed = null;
    this.pickedup = null;
    this.accomplished = null;
    notifyListeners();
  }

  void setMapController(MapControllerHookState controller) {
    this.controller = controller;
    this.controller?.informMeAboutLocationChanged(locationChanged);
    if(controller!=null && ride!=null){
      controller.moveCamera(ride);
    }
  }
}