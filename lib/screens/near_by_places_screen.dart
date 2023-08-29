import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:location/location.dart' as loc;
import 'nearby_response.dart';

const String apiKey = "AIzaSyB_aHvhFjKlFDbtJ1-YeHhE26wewXTlkOc";
const double searchRadius = 1000; // 1000 meters

class NearbyPlacesScreen extends StatefulWidget {
  const NearbyPlacesScreen({Key? key}) : super(key: key);

  @override
  State<NearbyPlacesScreen> createState() => _NearbyPlacesScreenState();
}

class _NearbyPlacesScreenState extends State<NearbyPlacesScreen> {
  GoogleMapController? mapController;
  List<Results>? nearbyPlaces;
  LocationData? currentLocation;
  Set<Marker> markers = {};

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  void _getUserLocation() async {
    loc.Location location = loc.Location();

    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    LocationData locationData = await location.getLocation();
    setState(() {
      currentLocation = locationData;
    });

    if (currentLocation != null) {
      fetchNearbyPlaces();
    }
  }

  void fetchNearbyPlaces() async {
    final String url =
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=' +
            currentLocation!.latitude.toString() +
            ',' +
            currentLocation!.longitude.toString() +
            '&radius=' +
            searchRadius.toString() +
            '&type=mosque&key=' +
            apiKey;

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final nearbyPlacesResponse = NearbyPlacesResponse.fromJson(responseData);
      setState(() {
        nearbyPlaces = nearbyPlacesResponse.results;
        addMarkersOnMap();
      });
    } else {
      // Handle API error
      print('Error: Unable to fetch nearby places');
    }
  }

  void addMarkersOnMap() {
    if (nearbyPlaces != null) {
      for (final place in nearbyPlaces!) {
        final lat = place.geometry?.location?.lat;
        final lng = place.geometry?.location?.lng;
        if (lat != null && lng != null) {
          final marker = Marker(
            markerId: MarkerId(place.placeId ?? 'unknown'),
            position: LatLng(lat, lng),
            infoWindow: InfoWindow(title: place.name ?? 'Unnamed Place'),
          );
          markers.add(marker);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 45,
        elevation: 0,
        backgroundColor: Colors.green,
        title: const Text(
          "Nearby Mosques",
          style: TextStyle(
            fontSize: 18,
          ),
        ),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(
            currentLocation?.latitude ?? 0.0,
            currentLocation?.longitude ?? 0.0,
          ),
          zoom: 15,
        ),
        onMapCreated: (controller) {
          mapController = controller;
        },
        markers: markers,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getUserLocation,
        child: Icon(Icons.my_location),
      ),
    );
  }
}
