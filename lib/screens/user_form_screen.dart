// lib/screens/user_form_screen.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async'; // Add this import at the top
import '../services/location_service.dart';
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
  Timer? _debounceTimer;

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
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;
    final formWidth = isSmallScreen ? screenSize.width * 0.9 : 448.0;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: formWidth,
                margin: EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Create your account',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w400,
                                color: Colors.grey[800],
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'to continue to ecom',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(height: 1),
                      Padding(
                        padding: EdgeInsets.all(24),
                        child: Column(
                          children: [
                            _buildTextField(
                              controller: _nameController,
                              label: 'Name',
                              validator: (value) {
                                if (value?.isEmpty ?? true) return 'Please enter your name';
                                return null;
                              },
                            ),
                            SizedBox(height: 24),
                            _buildTextField(
                              controller: _emailController,
                              label: 'Email',
                              validator: (value) {
                                if (value?.isEmpty ?? true) return 'Please enter your email';
                                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 24),
                            _buildTextField(
                              controller: _phoneController,
                              label: 'Phone',
                              validator: (value) {
                                if (value?.isEmpty ?? true) return 'Please enter your phone number';
                                if (!RegExp(r'^\+?[\d\s-]{10,}$').hasMatch(value!)) {
                                  return 'Please enter a valid phone number';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 24),
                            _buildDropdown(
                              value: _gender,
                              label: 'Gender',
                              items: ['Male', 'Female', 'Other'],
                              onChanged: (value) => setState(() => _gender = value),
                            ),
                            SizedBox(height: 24),
                            _buildDropdown(
                              value: _selectedCountry,
                              label: 'Country',
                              items: _countries,
                              onChanged: (value) {
                                setState(() {
                                  _selectedCountry = value;
                                  _citySuggestions.clear();
                                  _selectedCity = null;
                                });
                              },
                            ),
                            SizedBox(height: 24),
                            _buildCityAutocomplete(),
                          ],
                        ),
                      ),
                      Divider(height: 1),
                      Padding(
                        padding: EdgeInsets.all(24),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text('Cancel'),
                            ),
                            SizedBox(width: 16),
                            ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState?.validate() ?? false) {
                                  print('Form Submitted!');
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[700],
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                              ),
                              child: Text('Create account'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      validator: validator,
    );
  }

  Widget _buildDropdown({
    required String? value,
    required String label,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      items: items
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
      onChanged: onChanged,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a $label';
        }
        return null;
      },
    );
  }

  Widget _buildCityAutocomplete() {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty || _selectedCountry == null) {
          return const Iterable<String>.empty();
        }
        
        // Debounce the API calls
        _debounceTimer?.cancel();
        _debounceTimer = Timer(const Duration(milliseconds: 100), () {
          fetchCitySuggestions(textEditingValue.text);
        });
        
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
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
    );
  }

  /// Fetches city suggestions based on the query and selected country.
  void fetchCitySuggestions(String query) async {
    if (_isLoadingCities || query.length < 2) {
      setState(() => _citySuggestions = []);
      return;
    }
    
    setState(() => _isLoadingCities = true);

    try {
      final countryCode = getCountryCode(_selectedCountry!);
      final cities = await LocationService.fetchCities(countryCode, query);
      
      // Only update if the widget is still mounted
      if (mounted) {
        setState(() {
          _citySuggestions = cities;
          _isLoadingCities = false;
        });
      }
    } catch (error) {
      print('Error fetching cities: $error');
      if (mounted) {
        setState(() {
          _citySuggestions = [];
          _isLoadingCities = false;
        });
      }
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
