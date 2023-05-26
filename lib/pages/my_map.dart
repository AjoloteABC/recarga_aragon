import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';

class MyMap extends StatefulWidget {
  const MyMap({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MyMapState();
}

class _MyMapState extends State<MyMap> {


  // final o MapController
  MapController controller = MapController(

    initMapWithUserPosition: false,
    initPosition:
    GeoPoint(latitude: 19.474822, longitude: -99.043149),
    areaLimit: const BoundingBox.world(),
  );


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.black,
        title: const Text(
          'Puntos de recarga',
        ),
      ),
      body: Stack(
        children: <Widget>[
          OSMFlutter(

            controller: controller,

            trackMyPosition: false,
            initZoom: 17,
            minZoomLevel: 17,
            maxZoomLevel: 19,
            stepZoom: 1.0,
            // [01]

            userLocationMarker: UserLocationMaker(
              personMarker: const MarkerIcon(
                icon: Icon(
                  Icons.location_history_rounded,
                  color: Colors.red,
                  size: 100,
                ),
              ),
              directionArrowMarker: const MarkerIcon(
                icon: Icon(
                  Icons.location_history_rounded,
                  size: 100,
                ),
              ),
            ),
            // [02]
            roadConfiguration: const RoadOption(
              roadColor: Colors.yellowAccent,
            ),
            // [03]
            markerOption: MarkerOption(
              defaultMarker: const MarkerIcon(
                icon: Icon(
                  Icons.person_pin_circle,
                  color: Colors.blue,
                  size: 56,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 50.0,
            right: 50.0,
            child: FloatingActionButton(
              onPressed: () async {
                var markerMap= GeoPoint(latitude: 19.473874, longitude:-99.045600);
                await controller.currentLocation();
                await controller.limitAreaMap(BoundingBox( east: -99.040518, north: 19.475940, south: 19.472821, west: -99.048137,));
                await controller.setZoom(zoomLevel:19);
                //await controller.changeLocation(GeoPoint(latitude: 19.473974, longitude:-99.995928));
                await controller.addMarker(markerMap,markerIcon: const MarkerIcon(
                  icon: Icon(Icons.pin_drop,color: Colors.blue,size: 100,),
                ),);


              },
              child: const Icon(Icons.my_location),
              backgroundColor: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
