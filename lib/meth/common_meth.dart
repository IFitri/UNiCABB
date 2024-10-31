import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class CommonMeth
{
  checkConnectivity(BuildContext context) async
  {
    // Check for a single ConnectivityResult (mobile, wifi, or none)
    var connectionResult = await Connectivity().checkConnectivity();

    // Display a SnackBar only if there's no internet connection
    if (connectionResult != ConnectivityResult.mobile && connectionResult != ConnectivityResult.wifi)
    {
      if (!context.mounted) return;
      displaysSnackBar(
        "Unable to connect to the internet. Check your connection and try again.",
        context,
      );
    }
  }

  displaysSnackBar(String messageText, BuildContext context)
  {
    var snackBar = SnackBar(content: Text(messageText));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}