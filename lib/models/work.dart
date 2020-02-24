import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:for_kish_driver/api/work.dart';
import 'package:for_kish_driver/helpers/types.dart';
import 'package:for_kish_driver/models/map_hook.dart';

class Work with ChangeNotifier {
  bool loaded = false;
  String driverId;
  bool active = false;
  Ride ride;
  bool accepted;
  Passenger passenger;
  bool arrived;
  bool pickedup;
  bool accomplished;

  MapControllerHookState controller;

  Work();

  void load(String driverId) async{
    if(loaded) return;
    try{
      var driverState = await fetchWorkState(driverId);
      this.loaded = true;
      this.active = driverState.active;
      this.ride = driverState.ride;
      this.accepted = driverState.accepted;
      this.passenger = driverState.passenger;
      this.arrived = driverState.arrived;
      this.pickedup = driverState.pickedup;
      this.accomplished = driverState.accomplished;
      notifyListeners();
    }catch(err){
      print(err);
    }
  }

  Future<void> activate() async {
    if(this.active) return;
    try{
      var result = await fetchActivate(driverId, this);
      if(result){
        this.active = true;
        notifyListeners();
      }
    }catch(err){
      print(err);
    }
  }

  Future<void> inactivate() async {
    if(!this.active) return;
    try{
      var result = await fetchInactivate(driverId);
      if(result){
        this.active = false;
        notifyListeners();
      }
    }catch(err){
      print(err);
    }
  }

  void offerRide(Ride ride) {
    if(!this.active || this.ride != null) return;
    if(ride!=null){
      this.ride = ride;
      this.accepted = false;
      if(controller!=null){
        controller.moveCamera(ride);
      }
      notifyListeners();
    }
  }

  void rejectRide() async{
    if(this.ride==null || (this.accepted ?? false)) return;
    try{
      var rejectingRide = this.ride;
      this.ride = null;
      notifyListeners();
      await fetchRejectRide(rejectingRide.id);
      print('rejected');
    }catch(err){
      print(err);
    }
  }

  Future<void> acceptRide() async{
    if(this.ride==null || (this.accepted ?? false)) return;
    try{
      var result = await fetchAcceptRide(ride.id);
      if(result != null){
        this.accepted = true;
        this.passenger = result;
        this.arrived = false;
        this.pickedup = false;
        this.accomplished = false;
      }else{
        this.ride = null;
      }
      notifyListeners();
    }catch(err){
      print(err);
    }
  }

  Future<void> declareArrived() async{
    if(this.ride==null || (this.arrived ?? false)) return;
    try{
      var result = await fetchArrived(ride.id);
      if(result){
        this.arrived = true;
      }
      notifyListeners();
    }catch(err){
      print(err);
    }
  }

  Future<void> declarePickedup() async{
    if(this.ride==null || (this.pickedup ?? false)) return;
    try{
      var result = await fetchPickedup(ride.id);
      if(result){
        this.pickedup = true;
      }
      notifyListeners();
    }catch(err){
      print(err);
    }
  }

  Future<void> declareAccomplished() async{
    if(this.ride==null || (this.accomplished ?? false)) return;
    try{
      var result = await fetchAccomplished(ride.id);
      if(result != null){
        this.ride = null;
        this.accepted = null;
        this.passenger = null;
        this.arrived = null;
        this.pickedup = null;
        this.accomplished = null;
      }
      notifyListeners();
    }catch(err){
      print(err);
    }
  }

  void setMapController(MapControllerHookState controller) {
    this.controller = controller;
  }

}