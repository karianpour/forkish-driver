import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:for_kish_driver/helpers/number.dart';
import 'package:for_kish_driver/helpers/types.dart';
import 'package:for_kish_driver/models/map_hook.dart';
import 'package:for_kish_driver/models/work.dart';
import 'package:latlong/latlong.dart';
import 'package:functional_widget_annotation/functional_widget_annotation.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io' show Platform;

part 'ride_page.g.dart';

final LatLng center = LatLng(26.532065, 53.977069); // center of kish island
// const leafLetAccessToken = "pk.eyJ1Ijoia2FyaWFucG91ciIsImEiOiJjazZkbGJtMWYwODNzM2VudmVpdzU5dDJhIn0.LCWmMFkfKR_qDeed8Gsnhw";
const leafLetAccessToken = "pk.eyJ1Ijoia2FyaWFucG91ciIsImEiOiJjazZnY21iMW4wMnV0M21wOGFwazl0MXVkIn0.58NkL2VWsgUo16JGBz2CZw";

@widget
Widget ridePage(BuildContext context) {
  final state = useMapControllerHook();
  final work = Provider.of<Work>(context);
  work.setMapController(state);

  return Stack(
    children: <Widget>[
      MapArea(state: state),
      if(work.ride==null) Inactivator(),
      if(work.ride!=null) RideProgressPanel(),
      if(work.ride!=null && (work.accepted ?? false) && !(work.arrived ?? false)) NavigateToPickup(work.ride.pickup),
      if(work.ride!=null && (work.accepted ?? false) && (work.arrived ?? false)) NavigateToDestination(work.ride.destination),
    ],
  );
}

@widget
Widget inactivator(BuildContext context) {
  final processing = useState(false);
  final work = Provider.of<Work>(context);

  return Positioned(
    top: 40,
    left: 20,
    right: 20,
    child: Center(
      child: processing.value ? CircularProgressIndicator() : RaisedButton(
        child: Text(translate('work.inactivate')),
        onPressed: () async{
          processing.value = true;
          await work.inactivate();
          processing.value = false;
        },
      ),
    ),
  );
}

@widget
Widget rideProgressPanel(BuildContext context) {
  final work = Provider.of<Work>(context);

  return Positioned(
    top: 40,
    bottom: 40,
    left: 20,
    right: 20,
    child: Column(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            color: Color.fromRGBO(255, 255, 255, 1),
            borderRadius: BorderRadius.circular(4),
            boxShadow: [BoxShadow(
              color: Colors.grey,
              blurRadius: 5.0,
              spreadRadius: 2.0,
              offset: Offset(5, 5),
            )]
          ),
          child: Column(
            children: <Widget>[
              LocationBar(location: work.ride.pickup, pickup: true),
              LocationBar(location: work.ride.destination, pickup: false),
              PriceBar(
                price: work.ride.price,
                rejectRide:
                  (!(work.accepted ?? false)) ? work.rejectRide :
                  ((work.accepted ?? false) && !(work.accomplished ?? false)) ? work.cancelRide :
                  null, 
              ),
              if((work.accepted ?? false) && !(work.pickedup ?? false)) PassengerPanel(),
            ],
          ),
        ),
        Expanded(
          child: Container()
        ),
        if(!(work.accepted ?? false)) Acceptance(),
        if((work.accepted ?? false) && !(work.arrived ?? false)) Arriving(),
        if((work.arrived ?? false) && !(work.pickedup ?? false)) Pickup(),
        if((work.pickedup ?? false) && !(work.accomplished ?? false)) Accomplishment(),
      ],
    ),
  );
}

@widget
Widget passengerPanel(BuildContext context) {
  final work = Provider.of<Work>(context);
  final passenger = work.passenger;

  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(height: 10,),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // CircleAvatar(
            //   radius: 32,
            //   backgroundImage: AssetImage('assets/sample/brad_pit.jpeg'),
            // ),
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 8),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    '${passenger.firstname} ${passenger.lastname}',
                    style: TextStyle(
                      fontSize: 28,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsetsDirectional.only(start: 8, end: 8),
          alignment: AlignmentDirectional.centerEnd,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              if(work.confirmed) Text(translate('work.comming')),
              SizedBox(width: 16),
              RaisedButton(
                child: Icon(Icons.call),
                onPressed: () async {
                  print('call ${passenger.mobile}');
                  if(await canLaunch("tel:${passenger.mobile}")){
                    var r = await launch("tel:${passenger.mobile}");
                    print("result : $r");
                  }else{
                    print('cant lunch');
                  }
                },
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

@widget
Widget navigateToPickup(BuildContext context, Location location) {
  return Positioned(
    bottom: 100,
    left: 20,
    right: 20,
    child: RaisedButton(
      child: Text(translate('work.go_pickup')),
      onPressed: navigateToLocation(location),
    ),
  );
}

@widget
Widget navigateToDestination(BuildContext context, Location location) {
  return Positioned(
    bottom: 100,
    left: 20,
    right: 20,
    child: RaisedButton(
      child: Text(translate('work.go_destination')),
      onPressed: navigateToLocation(location),
    ),
  );
}

void Function() navigateToLocation(Location location) => () async {
  final url = 
    Platform.isIOS ?
      'https://maps.apple.com/?daddr=${location.lat},${location.lng}':
    Platform.isAndroid?
      'google.navigation:q=${location.lat},${location.lng}':
      'https://maps.google.com/?daddr=${location.lat},${location.lng}'
  ;
// waze url
// String mapRequest = "https://waze.com/ul?q=" + latLng.latitude + "," + latLng.longitude + "&navigate=yes&zoom=17";
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    print('Could not launch $url');
  }
};

@widget
Widget acceptance(BuildContext context) {
  final processing = useState(false);
  final work = Provider.of<Work>(context);

  return Center(
    child: processing.value ? CircularProgressIndicator() : Container(
      width: double.infinity,
      child: RaisedButton(
        child: Text(translate('work.accept')),
        onPressed: () async{
          processing.value = true;
          await work.acceptRide();
          processing.value = false;
        },
      ),
    ),
  );
}

@widget
Widget arriving(BuildContext context) {
  final processing = useState(false);
  final work = Provider.of<Work>(context);

  return Center(
    child: processing.value ? CircularProgressIndicator() : Container(
      width: double.infinity,
      child: RaisedButton(
        child: Text(translate('work.arrived')),
        onPressed: () async{
          processing.value = true;
          await work.declareArrived();
          processing.value = false;
        },
      ),
    ),
  );
}

@widget
Widget pickup(BuildContext context) {
  final processing = useState(false);
  final work = Provider.of<Work>(context);

  return Center(
    child: processing.value ? CircularProgressIndicator() : Container(
      width: double.infinity,
      child: RaisedButton(
        child: Text(translate('work.pickedup')),
        onPressed: () async{
          processing.value = true;
          await work.declarePickedup();
          processing.value = false;
        },
      ),
    ),
  );
}

@widget
Widget accomplishment(BuildContext context) {
  final processing = useState(false);
  final work = Provider.of<Work>(context);

  return Center(
    child: processing.value ? CircularProgressIndicator() : Container(
      width: double.infinity,
      child: RaisedButton(
        child: Text(translate('work.accomplished')),
        onPressed: () async{
          processing.value = true;
          await work.declareAccomplished();
          processing.value = false;
        },
      ),
    ),
  );
}

class PriceBar extends StatelessWidget {
  const PriceBar({
    Key key,
    @required this.price,
    this.rejectRide,
  }) : super(key: key);

  final double price;
  final void Function() rejectRide;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(14.0),
          child: Icon(Icons.attach_money, size: 20,),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 1.0, bottom: 1.0),
            child: Text(
              translate('work.price', args: {'price': formatNumber(context, price) ?? ''}),
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 24,
              ),
            ),
          ),
        ),
        if(rejectRide!=null) RawMaterialButton(
          constraints: BoxConstraints(),
          padding: EdgeInsets.all(0),
          onPressed: (){
            rejectRide();
          },
          child: Icon(Icons.clear, size: 20),
        ),
      ],
    );
  }
}

class LocationBar extends StatelessWidget {
  const LocationBar({
    Key key,
    @required this.location,
    this.pickup = false,
  }) : super(key: key);

  final Location location;
  final bool pickup;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(14.0),
          child: SizedBox(
            height: 20,
            width: 20,
            child: Image.asset('assets/map/${pickup ? 'pickup' : 'destination'}.png'),
          ),
        ),
        Expanded(
          child: Text(
            "${location?.name ?? ''}",
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 18,
            ),
          ),
        ),
      ],
    );
  }
}

class MapArea extends StatelessWidget {
  const MapArea({
    Key key,
    @required this.state,
  }) : super(key: key);

  final MapControllerHookState state;

  @override
  Widget build(BuildContext context) {
    final work = Provider.of<Work>(context);

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
        MarkerLayerOptions(
          markers: [
            if(work.ride?.pickup!=null) Marker(
              width: 40.0,
              height: 40.0,
              point: LatLng(work.ride.pickup.lat, work.ride.pickup.lng),
              builder: (ctx) =>
              Container(
                child: Image.asset('assets/map/pickup.png'),
              ),
              anchorPos: AnchorPos.align(AnchorAlign.top),
            ),
            if(work.ride?.destination!=null) Marker(
              width: 40.0,
              height: 40.0,
              point: LatLng(work.ride.destination.lat, work.ride.destination.lng),
              builder: (ctx) =>
              Container(
                child: Image.asset('assets/map/destination.png'),
              ),
              anchorPos: AnchorPos.align(AnchorAlign.top),
            ),
          ],
        ),
      ],
    );
  }
}
