class Passenger {
  String firstname;
  String lastname;
  String mobile;

  Passenger({this.firstname, this.lastname, this.mobile});

  Passenger.fromJson(Map<String, dynamic> json)
      : 
        firstname = json['firstname'],
        lastname = json['lastname'],
        mobile = json['mobile'];

  Map<String, dynamic> toJson() =>
    {
      'firstname': firstname,
      'lastname': lastname,
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
  String address;
  Location({this.name, this.address, this.lat, this.lng});

  Location.fromJson(Map<String, dynamic> json)
      : 
        lat = json['lat'],
        lng = json['lng'],
        name = json['name'],
        address = json['address'];
}

enum VehicleType {
  sedan,
  van,
  hatchback,
}

VehicleType findVehicleType(String name){
  return VehicleType.values.firstWhere((vt)=> vt.toString()=='VehicleType.$name', orElse: (){
    print('Vehicle Type for $name not found, returning null');
    return null;
  });
}

String getVehicleTypeName(VehicleType vt) {
  return vt?.toString()?.replaceFirst('VehicleType.', '');
}

class Vehicle {
  String id;
  String plateNo;
  VehicleType vehicleType;
  int capacity;

  Vehicle({this.plateNo, this.vehicleType, this.capacity});

  Vehicle.fromJson(Map<String, dynamic> json)
   :
     id = json['id'],
     plateNo = json['plateNo'],
     vehicleType = findVehicleType(json['vehicleType']),
     capacity = json['capacity']
   ;

  Map<String, dynamic> toJson() =>
    {
      'id': id,
      'plateNo': plateNo,
      'vehicleType': getVehicleTypeName(vehicleType),
      'capacity': capacity
    };
}

class Driver {
  String id;
  String firstName;
  String lastName;
  String firstNameEn;
  String lastNameEn;
  String mobile;
  String photoUrl;
  List<Vehicle> vehicles;

  Driver({this.id, this.firstName, this.lastName, this.firstNameEn, this.lastNameEn, this.mobile, this.photoUrl});

  Driver.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        firstName = json['firstName'],
        lastName = json['lastName'],
        firstNameEn = json['firstNameEn'],
        lastNameEn = json['lastNameEn'],
        mobile = json['mobile'],
        photoUrl = json['photoUrl'],
        vehicles = json['vehicles'] != null ? json['vehicles'].map<Vehicle>( (v) => Vehicle.fromJson(v) ).toList() : null
        ;

  Map<String, dynamic> toJson() =>
    {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'firstNameEn': firstNameEn,
      'lastNameEn': lastNameEn,
      'mobile': mobile,
      'photoUrl': photoUrl,
      'vehicles': vehicles
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
        distance = double.parse(json['distance'].toString()),
        time = double.parse(json['time'].toString()),
        price = double.parse(json['price'].toString());
}

enum PaymentType {
  cash,
  credit,
}

findPaymentType(String name) {
  return PaymentType.values.firstWhere( (pt) => pt.toString() == 'PaymentType.$name', orElse: (){
    print('No payment type where found for $name, so I return null.');
    return null;
  });
}

String getPaymentTypeName(PaymentType vt) {
  return vt?.toString()?.replaceFirst('PaymentType.', '');
}

class RideProgress{
  bool onboard;
  Location location;
  int bearing;

  RideProgress({this.onboard, this.location, this.bearing});
}

