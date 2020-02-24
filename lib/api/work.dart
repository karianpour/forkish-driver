import 'dart:async';

import 'package:for_kish_driver/helpers/types.dart';
import 'package:for_kish_driver/models/work.dart';

class DriverState {
  bool active = false;
  Ride ride;
  bool accepted;
  Passenger passenger;
  bool arrived;
  bool pickedup;
  bool accomplished;

  DriverState.fromJson(Map<String, dynamic> json)
      : 
        active = json['active'] == null ?  false : json['active'],
        ride = json['ride'] == null ? null : Ride.fromJson(json['ride']),
        accepted = json['accepted'],
        passenger = json['passenger'] == null ? null : Passenger.fromJson(json['passenger']),
        arrived = json['arrived'],
        pickedup = json['pickedup'],
        accomplished = json['accomplished'];

}

Future<DriverState> fetchWorkState(String driverId) async {
  await Future.delayed(Duration(milliseconds: 200));
  return DriverState.fromJson({
    "active": false,
    "ride": null,
    "accepted": null,
    "arrived": null,
    "pickedup": null,
    "accomplished": null,
  });
}


Future<bool> fetchActivate(String driverId, Work work) async {
  await Future.delayed(Duration(milliseconds: 1000));

  if(true){
    Timer(Duration(seconds: 5), (){
      work.offerRide(Ride.fromJson({
        'pickup': {
            'lat' : 26.542411530602898,
            'lng' : 53.99874269842528,
            'name' : "گنو۱",
            'location' : "ایران، هرمزگان، بندر لنگه، کیش، بلوار تهران، خراسان، دماوند، الوند، اورامان، گنو۱",
        },
        'destination': {
          'lat': 26.542462715920408,
          'lng': 54.00582161070532,
          'location': "ایران، هرمزگان، بندر لنگه، کیش، بلوار مروارید، هریرود، خراسان، هرمزگان",
          'name': "هرمزگان",        
        },
        'distance': 3000.0,
        'time': 500.0,
        'price': 15000.0,
      }));
    });
  }

  return true;
}

Future<bool> fetchRejectRide(String rideId) async {
  await Future.delayed(Duration(milliseconds: 1000));
  return true;
}

Future<Passenger> fetchAcceptRide(String rideId) async {
  await Future.delayed(Duration(milliseconds: 1000));
  return Passenger.fromJson({
    'firstName': 'مصطفی',
    'lastName': 'خلیلی',
    'mobile': '09121160998',
  });
}

Future<bool> fetchArrived(String rideId) async {
  await Future.delayed(Duration(milliseconds: 1000));
  return true;
}

Future<bool> fetchPickedup(String rideId) async {
  await Future.delayed(Duration(milliseconds: 1000));
  return true;
}

Future<bool> fetchAccomplished(String rideId) async {
  await Future.delayed(Duration(milliseconds: 1000));
  return true;
}


Future<bool> fetchInactivate(String driverId) async {
  await Future.delayed(Duration(milliseconds: 1000));
  return true;
}
