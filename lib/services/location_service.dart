import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/country.dart';

class LocationService {
  static const List<Country> countries = [
    Country(name: "United States", code: "US", dialCode: "+1"),
    Country(name: "United Kingdom", code: "GB", dialCode: "+44"),
    Country(name: "India", code: "IN", dialCode: "+91"),
    Country(name: "Canada", code: "CA", dialCode: "+1"),
    // Add more countries as needed
  ];

  static Future<List<String>> fetchCities(String countryCode, String query) async {
    if (query.length < 2) return [];

    final url = Uri.parse(
      'http://geodb-free-service.wirefreethought.com/v1/geo/cities?namePrefix=$query&countryIds=$countryCode&limit=10'
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['data'] as List)
            .map((city) => city['city'].toString())
            .toList();
      }
      return [];
    } catch (e) {
      print('Error fetching cities: $e');
      return [];
    }
  }
}
