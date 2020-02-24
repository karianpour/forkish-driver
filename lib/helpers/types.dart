class Passenger {
  String firstName;
  String lastName;
  String mobile;

  Passenger({this.firstName, this.lastName, this.mobile});

  Passenger.fromJson(Map<String, dynamic> json)
      : 
        firstName = json['firstName'],
        lastName = json['lastName'],
        mobile = json['mobile'];

  Map<String, dynamic> toJson() =>
    {
      'firstName': firstName,
      'lastName': lastName,
      'mobile': mobile,
    };

}

class LocationList {
  List<Location> locations;

  LocationList({this.locations});
}

class Location {
  double lat;
  double lng;
  String name;
  String location;
  Location({this.name, this.location, this.lat, this.lng});

  Location.fromJson(Map<String, dynamic> json)
      : 
        lat = json['lat'],
        lng = json['lng'],
        name = json['name'],
        location = json['location'];
}

enum VehicleType {
  sedan,
  van,
  hatchback,
}

class Vehicle {
  String mainNumber;
  String classNumber;
  VehicleType vehicleType;

  Vehicle({this.mainNumber, this.classNumber, this.vehicleType});
}

class Driver {
  String id;
  String firstName;
  String lastName;
  String firstNameEn;
  String lastNameEn;
  String mobile;
  String photoUrl;

  Driver({this.id, this.firstName, this.lastName, this.firstNameEn, this.lastNameEn, this.mobile, this.photoUrl});

  Driver.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        firstName = json['firstName'],
        lastName = json['lastName'],
        firstNameEn = json['firstNameEn'],
        lastNameEn = json['lastNameEn'],
        mobile = json['mobile'],
        photoUrl = json['photoUrl'];

  Map<String, dynamic> toJson() =>
    {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'firstNameEn': firstNameEn,
      'lastNameEn': lastNameEn,
      'mobile': mobile,
      'photoUrl': photoUrl,
    };

}

class Ride {
  String id;
  Location pickup;
  Location destination;
  double distance;
  double time;
  double price;

  Ride({this.pickup, this.destination, this.distance, this.time, this.price});

  Ride.fromJson(Map<String, dynamic> json)
      : 
        id = json['id'],
        pickup = json['pickup'] == null ? null : Location.fromJson(json['pickup']),
        destination = json['destination'] == null ? null : Location.fromJson(json['destination']),
        distance = json['distance'],
        time = json['time'],
        price = json['price'];
}

enum PaymentType {
  cash,
  credit,
}

class RideProgress{
  bool onboard;
  Location location;
  int bearing;

  RideProgress({this.onboard, this.location, this.bearing});
}

