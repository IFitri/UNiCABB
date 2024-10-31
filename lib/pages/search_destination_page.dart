import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import '../global/var_global.dart';

class SearchDestinationPage extends StatefulWidget {
  final Function(LatLng) onPickupSelected;
  final Function(LatLng) onDropoffSelected;

  const SearchDestinationPage({
    super.key,
    required this.onPickupSelected,
    required this.onDropoffSelected,
  });

  @override
  State<SearchDestinationPage> createState() => _SearchDestinationPageState();
}

class _SearchDestinationPageState extends State<SearchDestinationPage> {
  TextEditingController pickupController = TextEditingController();
  TextEditingController dropoffController = TextEditingController();
  LatLng? selectedPickupLocation;
  LatLng? selectedDropoffLocation;

  void selectPickup(LatLng location, String address) {
    setState(() {
      pickupController.text = address;
      selectedPickupLocation = location;
    });
    widget.onPickupSelected(location); // Call the callback with the pickup location
  }

  void selectDropoff(LatLng location, String address) {
    setState(() {
      dropoffController.text = address;
      selectedDropoffLocation = location;
    });
    widget.onDropoffSelected(location); // Call the callback with the dropoff location
  }

  void confirmSelection() {
    if (selectedPickupLocation != null && selectedDropoffLocation != null) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select both pickup and dropoff locations")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Set Pickup & Dropoff"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Pickup Location",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: pickupController,
              decoration: const InputDecoration(
                hintText: "Search pickup location",
                prefixIcon: Icon(Icons.location_on),
                border: OutlineInputBorder(),
              ),
              onTap: () {
                _showPlaceAutoComplete(pickupController, selectPickup);
              },
            ),
            const SizedBox(height: 20),
            const Text(
              "Dropoff Location",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: dropoffController,
              decoration: const InputDecoration(
                hintText: "Search dropoff location",
                prefixIcon: Icon(Icons.location_on),
                border: OutlineInputBorder(),
              ),
              onTap: () {
                _showPlaceAutoComplete(dropoffController, selectDropoff);
              },
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: confirmSelection,
              child: const Text("Confirm"),
            ),
          ],
        ),
      ),
    );
  }

  void _showPlaceAutoComplete(TextEditingController controller, Function(LatLng, String) onPlaceSelected) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GooglePlaceAutoCompleteTextField(
                  textEditingController: controller,
                  googleAPIKey: googleMapKey,
                  debounceTime: 800,
                  countries: ["MY"],
                  isLatLngRequired: true,
                  getPlaceDetailWithLatLng: (Prediction prediction) {
                    if (prediction.lat != null && prediction.lng != null) {
                      LatLng location = LatLng(prediction.lat! as double, prediction.lng! as double);
                      onPlaceSelected(location, prediction.description!);
                      Navigator.pop(context);
                    }
                  },
                  itemClick: (Prediction prediction) {
                    controller.text = prediction.description!;
                    if (prediction.lat != null && prediction.lng != null) {
                      LatLng location = LatLng(prediction.lat! as double, prediction.lng! as double);
                      onPlaceSelected(location, prediction.description!);
                      Navigator.pop(context);
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
