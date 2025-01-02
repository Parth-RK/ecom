// lib/screens/user_form_screen.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserFormScreen extends StatefulWidget {
  @override
  _UserFormScreenState createState() => _UserFormScreenState();
}

class _UserFormScreenState extends State<UserFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _gender;
  String? _selectedCountry;
  String? _selectedCity;
  List<String> _citySuggestions = [];
  bool _isLoadingCities = false;

  final List<String> _countries = [
    'United States',
    'India',
    'Canada',
    'Australia',
    'Germany',
    'France',
    'United Kingdom',
    'China',
    'Japan',
    'Brazil',
    'Russia',
    'South Africa',
    'Italy',
    'Mexico',
    'Spain',
    // Add all countries here
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('User Form')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Please enter your name';
                return null;
              },
            ),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Please enter your email';
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: 'Phone'),
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Please enter your phone number';
                if (!RegExp(r'^\+?[\d\s-]{10,}$').hasMatch(value!)) {
                  return 'Please enter a valid phone number';
                }
                return null;
              },
            ),
            DropdownButtonFormField<String>(
              value: _gender,
              decoration: InputDecoration(labelText: 'Gender'),
              items: ['Male', 'Female', 'Other']
                  .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                  .toList(),
              onChanged: (value) => setState(() => _gender = value),
              validator: (value) {
                if (value == null) return 'Please select your gender';
                return null;
              },
            ),
            DropdownButtonFormField<String>(
              value: _selectedCountry,
              decoration: InputDecoration(labelText: 'Country'),
              items: _countries
                  .map((country) => DropdownMenuItem(
                        value: country,
                        child: Text(country),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCountry = value;
                  _citySuggestions.clear();
                  _selectedCity = null;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a country';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text.isEmpty || _selectedCountry == null) {
                  return const Iterable<String>.empty();
                }
                fetchCitySuggestions(textEditingValue.text);
                return _citySuggestions;
              },
              onSelected: (String value) {
                setState(() {
                  _selectedCity = value;
                });
              },
              fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                return TextFormField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration: InputDecoration(
                    labelText: 'City',
                    suffixIcon: _isLoadingCities
                        ? Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: CircularProgressIndicator(strokeWidth: 2.0),
                          )
                        : null,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a city';
                    }
                    return null;
                  },
                );
              },
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState?.validate() ?? false) {
                  // Handle form submission
                  print('Form Submitted!');
                }
              },
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  /// Fetches city suggestions based on the query and selected country.
  void fetchCitySuggestions(String query) async {
    if (_isLoadingCities) return;
    setState(() => _isLoadingCities = true);

    try {
      final response = await http.get(
        Uri.parse(
            'http://geodb-free-service.wirefreethought.com/v1/geo/cities?namePrefix=$query&country=$getCountryCode(_selectedCountry!)'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final cities = (data['data'] as List).map((city) => city['name'].toString()).toList();
        setState(() {
          _citySuggestions = cities;
        });
      }
    } catch (error) {
      print('Error fetching cities: $error');
    } finally {
      setState(() => _isLoadingCities = false);
    }
  }

  /// Converts country name to country code.
  String getCountryCode(String country) {
    final countryCodes = {
      'United States': 'US',
      'India': 'IN',
      'Canada': 'CA',
      'Australia': 'AU',
      'Germany': 'DE',
      'France': 'FR',
      'United Kingdom': 'GB',
      'China': 'CN',
      'Japan': 'JP',
      'Brazil': 'BR',
      'Russia': 'RU',
      'South Africa': 'ZA',
      'Italy': 'IT',
      'Mexico': 'MX',
      'Spain': 'ES',
      // Add more country codes as needed
    };

    return countryCodes[country] ?? '';
  }
}
