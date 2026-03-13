import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationDetails {
  final double latitude;
  final double longitude;
  final String area;
  final String city;
  final String state;
  final String country;
  final String pincode;

  LocationDetails({
    required this.latitude,
    required this.longitude,
    required this.area,
    required this.city,
    required this.state,
    required this.country,
    required this.pincode,
  });
}

class LocationService {
  static Future<LocationDetails?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return null;
    }

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        return LocationDetails(
          latitude: position.latitude,
          longitude: position.longitude,
          area: place.subLocality ?? place.thoroughfare ?? place.name ?? '',
          city: place.locality ?? place.subAdministrativeArea ?? '',
          state: place.administrativeArea ?? '',
          country: place.country ?? '',
          pincode: place.postalCode ?? '',
        );
      }
    } catch (e) {
      // Ignored correctly
    }

    return LocationDetails(
      latitude: position.latitude,
      longitude: position.longitude,
      area: '',
      city: '',
      state: '',
      country: '',
      pincode: '',
    );
  }

  static Future<Map<String, double>?> getCoordinatesFromAddress(String city, String country) async {
    try {
      final address = "$city, $country";
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        return {'latitude': locations.first.latitude, 'longitude': locations.first.longitude};
      }
    } catch (e) {
      return null;
    }
    return null;
  }
}
