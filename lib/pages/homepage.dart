import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:users_interface/auth/login_screen.dart';
import 'package:users_interface/meth/common_meth.dart';
import 'package:users_interface/pages/search_destination_page.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import '../global/var_global.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final Completer<GoogleMapController> googleMapCompleterController = Completer<GoogleMapController>();
  GoogleMapController? controllerGoogleMap;
  Position? currentPositionOfUser;
  GlobalKey<ScaffoldState> sKey = GlobalKey<ScaffoldState>();
  CommonMeth cMeth = CommonMeth();
  double searchContainerHeight = 276;
  double bottomMapPadding = 0;
  String? mapStyle;
  LatLng? pickupLocation;
  LatLng? dropoffLocation;
  List<LatLng> polylineCoordinates = [];
  double estimatedFare = 0.0;
  PolylinePoints polylinePoints = PolylinePoints();
  String? googleMapKey;

  @override
  void initState() {
    super.initState();
    loadMapStyle();
  }

  Future<void> loadMapStyle() async {
    String style = await rootBundle.loadString("Themes/retro_style.json");
    setState(() {
      mapStyle = style;
    });
  }

  Future<void> getCurrentLiveLocationOfUser() async {
    try {
      currentPositionOfUser = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation);
      LatLng positionOfUserInLatLng = LatLng(currentPositionOfUser!.latitude, currentPositionOfUser!.longitude);

      if (controllerGoogleMap != null) {
        CameraPosition cameraPosition = CameraPosition(target: positionOfUserInLatLng, zoom: 15);
        controllerGoogleMap!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
      }

      await getUserInfoAndCheckBlockStatus();
    } catch (e) {
      cMeth.displaysSnackBar("Error getting location: $e", context);
    }
  }

  Future<void> getUserInfoAndCheckBlockStatus() async {
    DatabaseReference userRef = FirebaseDatabase.instance
        .ref()
        .child("users")
        .child(FirebaseAuth.instance.currentUser!.uid);

    try {
      final snap = await userRef.once();
      if (snap.snapshot.value != null) {
        final userData = snap.snapshot.value as Map;
        if (userData["blockStatus"] == "no") {
          setState(() {
            userName = userData["name"];
          });
        } else {
          handleUserBlocked();
        }
      } else {
        handleUserNotRegistered();
      }
    } catch (e) {
      cMeth.displaysSnackBar("Error fetching user info: $e", context);
    }
  }

  void handleUserBlocked() {
    FirebaseAuth.instance.signOut();
    Navigator.push(context, MaterialPageRoute(builder: (c) => const loginScreen()));
    cMeth.displaysSnackBar("You have been blocked. Please contact the admin for further questions.", context);
  }

  void handleUserNotRegistered() {
    FirebaseAuth.instance.signOut();
    cMeth.displaysSnackBar("You haven't signed up as a user.", context);
    Navigator.push(context, MaterialPageRoute(builder: (c) => const loginScreen()));
  }

  void setPickupLocation(LatLng location) {
    setState(() {
      pickupLocation = location;
      polylineCoordinates.clear();
      if (dropoffLocation != null) calculateRoute();
    });
  }

  void setDropoffLocation(LatLng location) {
    setState(() {
      dropoffLocation = location;
      polylineCoordinates.clear();
      calculateRoute();
    });
  }

  Future<void> calculateRoute() async {
    if (pickupLocation != null && dropoffLocation != null) {
      try {
        PointLatLng pickupPoint = PointLatLng(pickupLocation!.latitude, pickupLocation!.longitude);
        PointLatLng dropoffPoint = PointLatLng(dropoffLocation!.latitude, dropoffLocation!.longitude);

        PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
          googleMapKey!,
          pickupPoint,
          dropoffPoint,
          travelMode: TravelMode.driving,
        );

        if (result.points.isNotEmpty) {
          setState(() {
            polylineCoordinates = result.points.map((p) => LatLng(p.latitude, p.longitude)).toList();
            estimatedFare = calculateFare();
          });
        }
      } catch (e) {
        cMeth.displaysSnackBar("Error calculating route: $e", context);
      }
    }
  }

  double calculateFare() {
    return (polylineCoordinates.length * 0.01) * 10; // Replace with actual fare calculation
  }

  void openSearchPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchDestinationPage(
          onPickupSelected: setPickupLocation,
          onDropoffSelected: setDropoffLocation,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: sKey,
      drawer: buildDrawer(),
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            myLocationEnabled: true,
            zoomGesturesEnabled: true,
            zoomControlsEnabled: true,
            initialCameraPosition: const CameraPosition(target: LatLng(3.1319, 101.6841), zoom: 10),
            padding: EdgeInsets.only(bottom: bottomMapPadding),
            onMapCreated: (GoogleMapController controller) {
              controllerGoogleMap = controller;
              controller.setMapStyle(mapStyle);
              getCurrentLiveLocationOfUser();
            },
            polylines: {
              if (polylineCoordinates.isNotEmpty)
                Polyline(
                  polylineId: const PolylineId("route"),
                  points: polylineCoordinates,
                  color: Colors.blue,
                  width: 5,
                ),
            },
            markers: {
              if (pickupLocation != null) Marker(markerId: const MarkerId("pickup"), position: pickupLocation!),
              if (dropoffLocation != null) Marker(markerId: const MarkerId("dropoff"), position: dropoffLocation!),
            },
          ),
          buildBottomSearchContainer(),
        ],
      ),
    );
  }

  Widget buildBottomSearchContainer() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        height: searchContainerHeight,
        padding: const EdgeInsets.all(16.0),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 5),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Select Destination", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: openSearchPage,
              child: Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.search, color: Colors.blue),
                    SizedBox(width: 10),
                    Text("Search pickup & dropoff", style: TextStyle(color: Colors.black54)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Drawer buildDrawer() {
    return Drawer(
      child: ListView(
        children: [
          buildDrawerHeader(),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text("Sign Out"),
            onTap: () {
              FirebaseAuth.instance.signOut();
              Navigator.push(context, MaterialPageRoute(builder: (c) => const loginScreen()));
            },
          ),
        ],
      ),
    );
  }

  DrawerHeader buildDrawerHeader() {
    return const DrawerHeader(
      decoration: BoxDecoration(color: Colors.blue),
      child: Center(
        child: Text(
          "User Menu",
          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
