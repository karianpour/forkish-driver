import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:for_kish/helpers/number.dart';
import 'package:for_kish/helpers/types.dart';
import 'package:for_kish/pages/address/address_query.dart';
import 'package:functional_widget_annotation/functional_widget_annotation.dart';
import 'package:mapir_gl/mapir_gl.dart';

import '../../hooks/map_hook.dart';

part 'taxi_query.g.dart';

final LatLng center = const LatLng(26.532065, 53.977069); // center of kish island

@widget
Widget taxiQuery(BuildContext context) {
  final wrapper = useMapControllerHook();

  return Stack(
    children: <Widget>[
      MapArea(wrapper: wrapper),
      if(wrapper.getPickup()!=null || wrapper.getDestination()!=null) AddressPanel(wrapper: wrapper),
      if(!wrapper.getPickupConfirmed()) PickupAlert(wrapper: wrapper),
      if(wrapper.getPickupConfirmed() && !wrapper.getDestinationConfirmed()) DestinationAlert(wrapper: wrapper),
      if(wrapper.getPickupConfirmed() && wrapper.getDestinationConfirmed() && !wrapper.getRequestingRide() && wrapper.getRide()==null) OfferSelection(wrapper: wrapper),
      if(wrapper.getRequestingRide()) RideQueryPanel(),
      if(wrapper.getRide()!=null) RidePanel(wrapper: wrapper),
    ],
  );
}

class RidePanel extends StatelessWidget {
  const RidePanel({
    Key key,
    @required this.wrapper,
  }) : super(key: key);

  final MapControllerWrapper wrapper;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 40,
      left: 40,
      right: 40,
      // height: 250,
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
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                // mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Row(
                    // crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Expanded(
                        child: buildDriver(),
                      ),
                      buildActions(),
                    ],
                  ),
                  buildRideData(context),
                ],
              ),
            ),
          ),
          SizedBox.fromSize(size: Size.fromHeight(20),),
          SizedBox(
            width: double.infinity,
            child: RaisedButton(
              child: Text(
                translate('taxi_query.cancel_ride'),
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              color: Colors.blue,
              onPressed: (){
                // wrapper.setRequestingRide(true);
              },
            ),
          ),
        ],
      ),
    );
  }

  Container buildActions() {
    return Container(
      padding: EdgeInsets.all(8.0),
      width: 80,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          RaisedButton(
            child: Icon(Icons.call, color: Colors.white,),
            // child: Text(
            //   translate('taxi_query.callDriver'),
            //   style: TextStyle(
            //     color: Colors.white,
            //   ),
            // ),
            color: Colors.blue,
            onPressed: (){
              print('call');
            },
          ),
          RaisedButton(
            child: Icon(Icons.more, color: Colors.white,),
            // child: Text(
            //   translate('taxi_query.options'),
            //   style: TextStyle(
            //     color: Colors.white,
            //   ),
            // ),
            color: Colors.blue,
            onPressed: (){
              print('call');
            },
          ),
        ],
      ),
    );
  }

  Column buildDriver() {
    final score = wrapper.getRide().driver.score;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            CircleAvatar(
              radius: 32,
              backgroundImage: AssetImage('assets/sample/brad_pit.jpeg'),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 8),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(wrapper.getRide().driver.name),
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.star, color: score > 0 ? Colors.yellow: Colors.black54, size: 16),
                        Icon(Icons.star, color: score > 1 ? Colors.yellow: Colors.black54, size: 16),
                        Icon(Icons.star, color: score > 2 ? Colors.yellow: Colors.black54, size: 16),
                        Icon(Icons.star, color: score > 3 ? Colors.yellow: Colors.black54, size: 16),
                        Icon(Icons.star, color: score > 4 ? Colors.yellow: Colors.black54, size: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        Container(
          padding: EdgeInsets.only(top: 8, bottom: 12),
          child: KishVehiclePlate(vehicle: wrapper.getRide().vehicle)
        ),
      ],
    );
  }

  Container buildRideData(BuildContext context) {
    return Container(
      height: 80,
      padding: const EdgeInsets.only(top: 4),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(width: 1, color: Colors.black54))
      ),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: <Widget>[
          RideDatalet(
            label: translate("taxi_query.distance"), 
            data: translate("taxi_query.distanceKilometer", args: {"distance": formatNumber(context, wrapper.getRideApproach().distance / 1000)}),
          ),
          RideDatalet(
            label: translate("taxi_query.eta"), 
            data: translate("taxi_query.etaMinute", args: {"eta": formatNumber(context, (wrapper.getRideApproach().eta / 60).ceil())}),
          ),
          RideDatalet(
            label: translate("taxi_query.figure"), 
            data: translate('taxi_query.price', args: {'price': formatNumber(context, wrapper.getRide().price)}),
          ),
          RideDatalet(
            label: translate("taxi_query.paymentMethod"), 
            data: translate(wrapper.getRide().paymentType.toString()),
          ),
        ],
      ),
    );
  }
}

class KishVehiclePlate extends StatelessWidget {
  const KishVehiclePlate({
    Key key,
    @required this.vehicle,
  }) : super(key: key);

  final Vehicle vehicle;

  @override
  Widget build(BuildContext context) {
    final withClass = vehicle.classNumber!=null && vehicle.classNumber.length>0;
    return Container(
      height: 30,
      width: withClass ? 130 : 105,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        border: Border.all(width: 2),
        color: Colors.orange,
      ),
      child: Row(
        textDirection: TextDirection.ltr,
        children: <Widget>[
          Container(
            width: 40,
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Center(child: Text('Kish')),
          ),
          Container(
            width: 56,
            child: Center(child: Text(vehicle.mainNumber))
          ),
          if(withClass) 
            Container(
              width: 30, 
              decoration: BoxDecoration(
                border: Border(left: BorderSide(width: 1)),
              ),
              child: Center(child: Text(vehicle.classNumber))
            ),
        ],
      ),
    );
  }
}

class RideDatalet extends StatelessWidget {
  const RideDatalet({
    Key key,
    @required this.label,
    @required this.data,
  }) : super(key: key);

  final String label;
  final String data;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              label,
              style: TextStyle(
                color: Colors.black54,
              ),
            ),
          ),
          Text(data),
        ],
      ),
    );
  }
}

class RideQueryPanel extends StatelessWidget {
  const RideQueryPanel({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 40,
      left: 40,
      right: 40,
      child: Column(
        children: <Widget>[
          Container(
            height: 160,
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
            child: Center(child: CircularProgressIndicator()),
          ),
          SizedBox.fromSize(size: Size.fromHeight(20),),
          SizedBox(
            width: double.infinity,
            child: RaisedButton(
              child: Text(
                translate('taxi_query.cancel_request'),
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              color: Colors.blue,
              onPressed: (){
                // wrapper.setRequestingRide(true);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class OfferSelection extends StatelessWidget {
  const OfferSelection({
    Key key,
    @required this.wrapper,
  }) : super(key: key);

  final MapControllerWrapper wrapper;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 40,
      left: 40,
      right: 40,
      child: Container(
        child: Column(
          children: <Widget>[
            Container (
              height: 170,
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
              child: wrapper.getOffers() != null ? ListView(
                scrollDirection: Axis.horizontal,
                children: <Widget>[
                  for(var offer in wrapper.getOffers()) Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 8, bottom: 8),
                    child: TaxiOffer(offer: offer, wrapper: wrapper),
                  ),
                ],
              ) : wrapper.getRequestingOffers() ? 
                SizedBox(width: double.infinity, child: Center(child: CircularProgressIndicator()))
                :
                SizedBox(width: double.infinity, child: Center(child: Text('error'))),
            ),
            SizedBox.fromSize(size: Size.fromHeight(20),),
            SizedBox(
              width: double.infinity,
              child: RaisedButton(
                child: Text(
                  translate('taxi_query.request'),
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                color: Colors.blue,
                onPressed: wrapper.getSelectedOffer() == null ? null : (){
                  wrapper.setRequestingRide(true);
                },
              ),
            ),
          ],
        ),
      )
    );
  }
}

class TaxiOffer extends StatelessWidget {
  final Offer _offer;
  final MapControllerWrapper _wrapper;

  const TaxiOffer({
    Key key,
    Offer offer,
    MapControllerWrapper wrapper,
  }) : this._offer = offer, this._wrapper = wrapper, super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        if(_offer.enabled) _wrapper.setSelectedOffer(_offer);
      },
      child: Container(
        width: 90,
        padding: EdgeInsets.only(left: 8, right: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          border: Border.all(width: _wrapper.getSelectedOffer()!=_offer ? 0 : 2),
        ),
        foregroundDecoration: _offer.enabled ? null : BoxDecoration(
          color: Colors.grey,
          backgroundBlendMode: BlendMode.saturation,
        ),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
              child: Container(
                padding: EdgeInsets.only(bottom: 2, top: 2, left: 10, right: 10),
                decoration: BoxDecoration(
                  color: _offer.enabled ? Colors.black : Colors.grey,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  translate(_offer.vehicleType.toString()),
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            CircleAvatar(
              radius: 32,
              child: CircleAvatar(
                radius: 30,
                child: Image.asset('assets/${_offer.vehicleType.toString().replaceFirst('.', '/')}.png'),
                // child: Image.asset('assets/VehicleType/sedan.png'),
                backgroundColor: _offer.enabled ? Colors.white : Colors.grey,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
              child: Text(
                translate('taxi_query.price', args: {'price': formatNumber(context, _offer.price)}),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MapArea extends StatelessWidget {
  const MapArea({
    Key key,
    @required this.wrapper,
  }) : super(key: key);

  final MapControllerWrapper wrapper;

  @override
  Widget build(BuildContext context) {
    return MapirMap(
      onMapCreated: wrapper.onMapCreated,
      onMapClick: wrapper.onMapClicked,
      // onCameraTrackingChanged: wrapper.onCameraTrackingChanged,
      // onCameraTrackingDismissed: wrapper.onCameraTrackingDismissed,
      initialCameraPosition: CameraPosition(target: center, zoom: 15),
      tiltGesturesEnabled: false,
      trackCameraPosition: true,
      myLocationEnabled: true,
      // myLocationRenderMode: MyLocationRenderMode.GPS,
      // myLocationTrackingMode: MyLocationTrackingMode.TrackingGPS,
      // compassEnabled: true,
      compassViewMargins: Point(20, 580),
      // trackCameraPosition: true,
      logoViewMargins: Point(-300, 0),
      // attributionButtonMargins: Point(100, 100),
      minMaxZoomPreference: const MinMaxZoomPreference(12, 19), // for kish it is good zoom levels
      cameraTargetBounds: CameraTargetBounds(
        LatLngBounds(
          southwest: const LatLng(26.485096, 53.869411),
          northeast: const LatLng(26.604128, 54.059012)
        ),
      ),
    );
  }
}

class DestinationAlert extends StatelessWidget {
  const DestinationAlert({
    Key key,
    @required this.wrapper,
  }) : super(key: key);

  final MapControllerWrapper wrapper;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 80,
      left: 40,
      right: 40,
      height: 40,
      child: Container(
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
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                height: 20,
                width: 20,
                child: Image.asset('assets/map/destination.png'),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsetsDirectional.only(end: 10),
                child: GestureDetector(
                  onTap: () async{
                    final selected = await showSearch(context: context, delegate: AddressSearch(translate('taxi_query.destination.label')));
                    if(selected != null){
                      wrapper.setDestination(selected);
                    }
                  },
                  child: Text(
                    translate('taxi_query.destination.question'),
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PickupAlert extends StatelessWidget {
  const PickupAlert({
    Key key,
    @required this.wrapper,
  }) : super(key: key);

  final MapControllerWrapper wrapper;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 80,
      left: 40,
      right: 40,
      height: 40,
      child: Container(
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
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                height: 20,
                width: 20,
                child: Image.asset('assets/map/pickup.png'),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsetsDirectional.only(end: 10),
                child: GestureDetector(
                  onTap: () async{
                    final selected = await showSearch(context: context, delegate: AddressSearch(translate('taxi_query.pickup.label')));
                    if(selected != null){
                      wrapper.setPickup(selected);
                    }
                  },
                  child: Text(
                    translate('taxi_query.pickup.question'),
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddressPanel extends StatelessWidget {
  const AddressPanel({
    Key key,
    @required this.wrapper,
  }) : super(key: key);

  final MapControllerWrapper wrapper;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 100,
      left: 40,
      right: 40,
      // height: 40,
      child: Container(
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
            if(wrapper.getPickup()!=null) Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    height: 20,
                    width: 20,
                    child: Image.asset('assets/map/pickup.png'),
                  ),
                ),
                Expanded(
                  child: Text(
                    "${wrapper.getPickup()?.name ?? ''}",
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ),
                if(wrapper.getPickup()!=null) RawMaterialButton(
                  constraints: BoxConstraints(),
                  padding: EdgeInsets.all(0),
                  onPressed: (){
                    wrapper.setPickup(null);
                  }, 
                  child: Icon(Icons.clear, size: 20),
                ),
              ],
            ),
            if(wrapper.getDestination()!=null) Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    height: 20,
                    width: 20,
                    child: Image.asset('assets/map/destination.png'),
                  ),
                ),
                Expanded(
                  child: Text(
                    "${wrapper.getDestination().name}",
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ),
                if(wrapper.getDestination()!=null) RawMaterialButton(
                  constraints: BoxConstraints(),
                  padding: EdgeInsets.all(0),
                  onPressed: (){
                    wrapper.setDestination(null);
                  }, 
                  child: Icon(Icons.clear, size: 20),
                ),
              ],
            ),
          ],
        ),
      )
    );
  }
}