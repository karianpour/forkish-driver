import 'dart:convert';
import 'dart:io';
import 'dart:async';

import 'package:for_kish_driver/helpers/types.dart';
import 'package:for_kish_driver/models/work.dart';
import 'package:geolocator/geolocator.dart';

var wsBaseUrl = 'ws://192.168.1.52:4080';

class DriverState {
  bool active = false;
  Ride ride;
  bool accepted;
  Passenger passenger;
  bool arrived;
  bool confirmed;
  bool pickedup;
  bool accomplished;

  DriverState.fromJson(Map<String, dynamic> json)
      : 
        active = json['status'] != null 
          && (json['status']['status'] == 'ready' || json['status']['status'] == 'occupied'),
        ride = json['ride'] != null ? Ride.fromJson(json['ride']) : 
          json['offer'] != null ? Ride.fromJson(json['offer']): null,
        accepted = json['ride'] != null ? json['ride']['accepted'] : json['offer'] != null ? false : null,
        passenger = json['ride'] != null && json['ride']['passenger'] != null ? Passenger.fromJson(json['ride']['passenger']) : null,
        arrived = json['ride'] != null ? json['ride']['arrived'] : null,
        confirmed = json['ride'] != null ? json['ride']['confirmed'] : null,
        pickedup = json['ride'] != null ? json['ride']['pickedup'] : null,
        accomplished = json['ride'] != null ? json['ride']['accomplished'] : null;

}

WebSocket _ws;
bool _isAlive = false;
String _token;
Work _work;

void setWebSocketToken(String token){
  _token = token;
}

void registerWork(Work work){
  _work = work;
}

Future<bool> ensureWsConnection() async {
  if(!_isAlive){
    var connected = await connect();
    return connected;
  }
  return true;
}

Future<bool> connect() async {
  try{
    _ws = await WebSocket.connect('$wsBaseUrl/driver/ws');
    if (_ws?.readyState == WebSocket.open) {
      _isAlive = true;
      heartbeat();

      _ws.listen(
        (data) {
          // print('\t\t -- ${data?.toString()}');
          if(data=='pong'){
            pong();
          }else{
            try{
              final jsonData = Map<String, dynamic>.from(jsonDecode(data));
              final method = jsonData['method']?.toString();
              final payload = jsonData['payload'];
              
              if(method=='authenticated'){
                handleAuthenticated(payload);
              }else if(method=='initialState'){
                handleInitialState(payload);
              }else if(method=='statusChanged'){
                handleStateChanged(payload);
              }else if(method=='offer'){
                handleOffer(payload);
              }else if(method=='offerDrawBack'){
                handleOfferDrawBack(payload);
              }else if(method=='acceptResult'){
                handleAcceptResult(payload);
              }else if(method=='arrivedResult'){
                handleArrivedResult(payload);
              }else if(method=='passengerConfirmed'){
                handlePassengerConfirmed(payload);
              }else if(method=='boardedResult'){
                handlePickedupResult(payload);
              }else if(method=='leftResult'){
                handleAccomplishedResult(payload);
              }else if(method=='passengerCanceled'){
                handlePassengerCanceled(payload);
              }else{
                print('unused method $method');
              }
            }catch(err){
              print(err);
            }
          }
        },
        onDone: () => print('[+]Done :)'),
        onError: (err) => print('[!]Error -- ${err.toString()}'),
        cancelOnError: true,
      );

      _ws.add(jsonEncode({
        'method': 'authenticate',
        'payload': _token,
      }));
    }
    return true;
  }catch(err){
    print(err);
  }
  return false;
}

void pong(){
  _isAlive = true;
}

void heartbeat(){
  Timer.periodic(Duration(seconds: 30), (timer) {
    if(_isAlive == false){
      timer?.cancel();
      try{
        _ws?.close(1, 'no ping pong');
      }catch(err){
        print('error while closeing websoket');
      }
      return;
    }
    _isAlive = false;
    _ws.add('ping');
  });
}

void handleAuthenticated(payload){
  print('authenticated');
}

void handleInitialState(payload){
  print('initial');
  print(payload);
  var driverState = DriverState.fromJson(payload); 
  _work.setupState(driverState);
}

void handleStateChanged(payload){
  if(payload['status'] == 'ready'){
    _work?.activated(true);
  }else if(payload['status'] == 'off'){
    _work?.activated(false);
  }
}

void handleOffer(payload){
  try{
    var ride = Ride.fromJson(payload['offer']);
    _work.offerRide(ride);
  }catch(err){
    print(err);
  }
}

void handleOfferDrawBack(payload){
  _work.offerRide(null);
}

void handlePassengerCanceled(payload){
  //TODO
}

Future<void> fetchWorkState() async {
  if(_token==null) {
    _work.setupState(null);
  }
  if(!await ensureWsConnection()) {
    _work.setupState(null);
  }
  var msg = jsonEncode({
    'method': 'initialState',
    'payload': null,
  });
  _ws.add(msg);
  // await Future.delayed(Duration(milliseconds: 200));
  // return DriverState.fromJson({
  //   "active": false,
  //   "ride": null,
  //   "accepted": null,
  //   "arrived": null,
  //   "pickedup": null,
  //   "accomplished": null,
  // });
}


Future<void> fetchActivate(String vehicleId, Position currentPosition, Work work) async {
  // await Future.delayed(Duration(milliseconds: 1000));
  // if(true){
  //   Timer(Duration(seconds: 5), (){
  //     work.offerRide(Ride.fromJson({
  //       'pickup': {
  //           'lat' : 26.542411530602898,
  //           'lng' : 53.99874269842528,
  //           'name' : "گنو۱",
  //           'location' : "ایران، هرمزگان، بندر لنگه، کیش، بلوار تهران، خراسان، دماوند، الوند، اورامان، گنو۱",
  //       },
  //       'destination': {
  //         'lat': 26.542462715920408,
  //         'lng': 54.00582161070532,
  //         'location': "ایران، هرمزگان، بندر لنگه، کیش، بلوار مروارید، هریرود، خراسان، هرمزگان",
  //         'name': "هرمزگان",        
  //       },
  //       'distance': 3000.0,
  //       'time': 500.0,
  //       'price': 15000.0,
  //     }));
  //   });
  // }
  // return true;

  if(!await ensureWsConnection()) return false;
  var msg = jsonEncode({
    'method': 'ready',
    'payload': {
      'vehicleId': vehicleId,
      'lat': currentPosition.latitude,
      'lng': currentPosition.longitude,
      'heading': currentPosition.heading,
      'speed': currentPosition.speed,
    },
  });
  _ws.add(msg);
}

Future<void> fetchRejectRide(String rideId, Position currentPosition) async {
  // await Future.delayed(Duration(milliseconds: 1000));
  // print('reject');

  if(!await ensureWsConnection()) return false;
  var msg = jsonEncode({
    'method': 'reject',
    'payload': {
      'driverOfferId': rideId,
      'lat': currentPosition.latitude,
      'lng': currentPosition.longitude,
      'heading': currentPosition.heading,
      'speed': currentPosition.speed,
    },
  });
  _ws.add(msg);
}

Future<void> fetchCancelRide(String rideId, Position currentPosition) async {
  // await Future.delayed(Duration(milliseconds: 1000));
  // print('cancel');

  if(!await ensureWsConnection()) return false;
  var msg = jsonEncode({
    'method': 'cancel',
    'payload': {
      'rideProgressId': rideId,
      'lat': currentPosition.latitude,
      'lng': currentPosition.longitude,
      'heading': currentPosition.heading,
      'speed': currentPosition.speed,
    },
  });
  _ws.add(msg);
}

Future<void> fetchAcceptRide(String rideId, Position currentPosition) async {
  // await Future.delayed(Duration(milliseconds: 1000));
  // return Passenger.fromJson({
  //   'firstName': 'مصطفی',
  //   'lastName': 'خلیلی',
  //   'mobile': '09121160998',
  // });

  if(!await ensureWsConnection()) return false;
  var msg = jsonEncode({
    'method': 'accept',
    'payload': {
      'driverOfferId': rideId,
      'lat': currentPosition.latitude,
      'lng': currentPosition.longitude,
      'heading': currentPosition.heading,
      'speed': currentPosition.speed,
    },
  });
  _ws.add(msg);
}

void handleAcceptResult(dynamic payload){
  if(payload['failed'] == true){
    return;
  }else{
    var passenger = Passenger.fromJson(payload['passenger']);
    var rideId = payload['rideId'];
    _work.rideAccepted(passenger, rideId);
  }
}

Future<void> fetchArrived(String rideId, Position currentPosition) async {
  // await Future.delayed(Duration(milliseconds: 1000));
  // return true;

  if(!await ensureWsConnection()) return false;
  var msg = jsonEncode({
    'method': 'arrived',
    'payload': {
      'rideProgressId': rideId,
      'lat': currentPosition.latitude,
      'lng': currentPosition.longitude,
      'heading': currentPosition.heading,
      'speed': currentPosition.speed,
    },
  });
  _ws.add(msg);
}

void handleArrivedResult(dynamic payload){
  if(payload == true){
    _work.arrivedRecieved();
  }
}

void handlePassengerConfirmed(dynamic payload){
  _work.rideConfirmed();
}

Future<void> fetchPickedup(String rideId, Position currentPosition) async {
  // await Future.delayed(Duration(milliseconds: 1000));
  // return true;

  if(!await ensureWsConnection()) return false;
  var msg = jsonEncode({
    'method': 'boarded',
    'payload': {
      'rideProgressId': rideId,
      'lat': currentPosition.latitude,
      'lng': currentPosition.longitude,
      'heading': currentPosition.heading,
      'speed': currentPosition.speed,
    },
  });
  _ws.add(msg);
}

void handlePickedupResult(dynamic payload){
  if(payload == true){
    _work.pickedupRecieved();
  }
}

Future<void> fetchAccomplished(String rideId, Position currentPosition) async {
  // await Future.delayed(Duration(milliseconds: 1000));

  if(!await ensureWsConnection()) return false;
  var msg = jsonEncode({
    'method': 'left',
    'payload': {
      'rideProgressId': rideId,
      'lat': currentPosition.latitude,
      'lng': currentPosition.longitude,
      'heading': currentPosition.heading,
      'speed': currentPosition.speed,
    },
  });
  _ws.add(msg);
}

void handleAccomplishedResult(dynamic payload){
  if(payload == true){
    _work.accomplishedRecieved();
  }
}

Future<void> fetchInactivate(Position currentPosition) async {
  // await Future.delayed(Duration(milliseconds: 1000));

  if(!await ensureWsConnection()) return false;
  var msg = jsonEncode({
    'method': 'off',
    'payload': {
      'lat': currentPosition.latitude,
      'lng': currentPosition.longitude,
      'heading': currentPosition.heading,
      'speed': currentPosition.speed,
    },
  });
  _ws.add(msg);
}

Future<void> fetchUpdatePosition(Position currentPosition) async {
  // await Future.delayed(Duration(milliseconds: 1000));

  if(!await ensureWsConnection()) return false;
  var msg = jsonEncode({
    'method': 'pointUpdate',
    'payload': {
      'lat': currentPosition.latitude,
      'lng': currentPosition.longitude,
      'heading': currentPosition.heading,
      'speed': currentPosition.speed,
    },
  });
  _ws.add(msg);
}
