import 'package:flutter/material.dart';
import 'package:google_map_live_locaton_tracking/screens/near_by_places_screen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GoogleMapController? mapController;
  LocationData? currentLocation;
  Set<Marker> markers = {};

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  void _getUserLocation() async {
    Location location = Location();

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
      _updateMarker();
    });
  }

  void _updateMarker() {
    if (currentLocation != null) {
      markers.clear();
      markers.add(
        Marker(
          markerId: const MarkerId('currentLocation'),
          position:
              LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
          infoWindow: const InfoWindow(title: 'Current Location'),
        ),
      );
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _centerMapOnLocation() {
    if (currentLocation != null) {
      mapController!.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 45,
        elevation: 0,
        backgroundColor: Colors.green,
        title: const Center(
          child: Text(
            "Location Tracking",
            style: TextStyle(
              fontSize: 18,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NearbyPlacesScreen()),
              );
            },
          ),
        ],
      ),
      body: currentLocation == null
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              mapType: MapType.hybrid,
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: LatLng(
                  currentLocation!.latitude!,
                  currentLocation!.longitude!,
                ),
                zoom: 18,
              ),
              markers: markers,
              myLocationEnabled: true,
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        onPressed: _centerMapOnLocation,
        child: const Icon(Icons.location_searching, color: Colors.black),
      ),
    );
  }
}
