import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import "package:http/http.dart" as http;

import 'package:weather_app/key.dart';
import 'package:weather_app/weather.dart';

class API {
  const API._();
  static const API instance = API._();

  final String host = "api.openweathermap.org";

  ///The final URL would look like this:
  ///[https://<host>/data/2.5/weather?lat=<lat>&lon=<lon>&units=metric&appid=<APPI_KEY>]

  Uri uri({String? lat, String? lon}) => Uri(
        scheme: "https",
        host: host,
        pathSegments: {"data", "2.5", "weather"},
        queryParameters: {
          "lat": lat,
          "lon": lon,
          "units": "metric",
          "appid": API_KEY
        },
      );

  /// Determine the current position of the device.
  ///
  /// When the location services are not enabled or permissions
  /// are denied the `Future` will return an error.
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  Future<Weather> getCurrentWeather() async {
    try {
      Position position = await _determinePosition();

      final requestUri = uri(
        lon: position.longitude.toString(),
        lat: position.latitude.toString(),
      );

      ///After we have a uri, we can now send our request using
      ///http package: https://pub.dev/packages/http, and the result
      ///will be stored in a variable [response].
      final response = await http.get(requestUri);

      ///The response, if recieaved correctly. will be in the form of [json]
      ///so in order to read the data inside of it, we first need to decode it,
      ///by using the [json.decode()] method from the built-in [dart:convert] package,
      final decodedJson = json.decode(response.body);

      print(decodedJson);

      return Weather.fromMap(decodedJson);
    } on SocketException catch (e) {
      throw "You don't have connection, try again later.";
    } on PlatformException catch (e) {
      throw "${e.message}, please allow the app to access your current location from the settings.";
    } catch (e) {
      throw "Unknown error, try again.";
    }
  }
}
